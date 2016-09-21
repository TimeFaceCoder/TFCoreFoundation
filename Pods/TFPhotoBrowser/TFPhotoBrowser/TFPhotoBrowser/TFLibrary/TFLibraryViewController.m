//
//  TFLibraryViewController.m
//  TFPhotoBrowser
//
//  Created by Melvin on 12/15/15.
//  Copyright © 2015 TimeFace. All rights reserved.
//

#import "TFLibraryViewController.h"
#import "TFPhotoBrowserConstants.h"
#import "TFLibraryViewLayout.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "NSIndexSet+TFLibrary.h"
#import "UICollectionView+TFLibrary.h"
#import "TFLibraryCollectionViewCell.h"
#import "TFLibraryCameraCollectionViewCell.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "TFImageCropViewController.h"
#import "TFiCloudDownloadHelper.h"
#import "TFPhotoBrowserBundle.h"

NSString * const FLibraryViewControllerImageTypeJPEG = @"JPEG";
NSString * const FLibraryViewControllerImageTypePNG = @"PNG";

static NSString * const kTFLCollectionIdentifier        = @"kTFLCollectionIdentifier";
static NSString * const kTFLCollectionCameraIdentifier  = @"kTFLCollectionCameraIdentifier";
static NSString * const kTFLCollectionLibraryIdentifier = @"kTFLCollectionLibraryIdentifier";

@interface TFLibraryViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,PHPhotoLibraryChangeObserver,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray            *items;
@property (nonatomic, strong) PHFetchResult             *assetsFetchResults;
@property (nonatomic, strong) PHAssetCollection         *assetCollection;
@property (nonatomic, strong) PHCachingImageManager     *imageManager;
@property (nonatomic, strong) PHImageRequestOptions     *imageOptions;
@property (nonatomic, strong) UICollectionView          *collectionView;
@property (nonatomic, strong) NSMutableArray            *removeAssets;

@property (nonatomic, strong) TFImageCropViewController *editorViewController;

@property (nonatomic, strong) UIButton                  *selectedButton;

@property CGRect previousPreheatRect;

@end

@implementation TFLibraryViewController

static CGSize AssetGridThumbnailSize;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.imageManager = [[PHCachingImageManager alloc] init];
        self.imageOptions = [[PHImageRequestOptions alloc]init];
        self.imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        self.imageOptions.networkAccessAllowed = NO;
        [self resetCachedAssets];
        //        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        _items = [NSMutableArray array];
        _selectedAssets = [NSMutableArray array];
        _allowsMultipleSelection = YES;
        _barButtonColor = [UIColor colorWithRed:6/255.f green:155/255.f blue:242/255.f alpha:1];
    }
    return self;
}
- (void)loadAssets {
    if (NSClassFromString(@"PHAsset")) {
        // Check library permissions
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self performLoadAssets];
                }
            }];
        } else if (status == PHAuthorizationStatusAuthorized) {
            [self performLoadAssets];
        } else if (status == PHAuthorizationStatusDenied) {
            //没有权限
            
            //没有访问权限
            UILabel *label = [[UILabel alloc] init];
            label.backgroundColor = [UIColor clearColor];
            label.text = TFPhotoBrowserLocalizedStrings(@"Open album privacy settings");
            label.textColor = [UIColor colorWithRed:81/255.0f green:81/255.0f blue:81/255.0f alpha:1];
            label.font = [UIFont systemFontOfSize:18];
            label.numberOfLines = 2;
            label.textAlignment = NSTextAlignmentCenter;
            [label sizeToFit];
            CGFloat left = (self.view.frame.size.width - label.frame.size.width) / 2;
            CGFloat top = (self.view.frame.size.height - label.frame.size.height)/ 2;
            label.frame = CGRectMake(left, top, label.frame.size.width,label.frame.size.height);
            [self.view addSubview:label];
            
            UIButton *button = [[UIButton alloc]init];
            button.backgroundColor = [UIColor colorWithRed:6/255.0f green:155/255.0f blue:242/255.0f alpha:1];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:18];
            [button setTitle:TFPhotoBrowserLocalizedStrings(@"Open settings") forState:UIControlStateNormal];
            CGFloat buttonWidth = 100;
            CGFloat buttonHeight = 30;
            CGFloat buttonLeft = (self.view.frame.size.width - buttonWidth) / 2;
            CGFloat buttonTop = label.frame.origin.y + label.frame.size.height + 10;
            button.frame = CGRectMake(buttonLeft, buttonTop, buttonWidth, buttonHeight);
            button.layer.cornerRadius = 4;
            [button addTarget:self action:@selector(actionForSettingButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:button];
            
            self.navigationItem.title = TFPhotoBrowserLocalizedStrings(@"Request album permissions");
            return;
        }
        
    } else {
        // Assets library
        [self performLoadAssets];
        
    }
}

- (void)actionForSettingButton:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}


- (void)performLoadAssets {
    // Load
    self.navigationItem.title = TFPhotoBrowserLocalizedStrings(@"Loading Photos");
    __weak typeof(self) weakSelf = self;
    if ([_items count] > 0) {
        [_items removeAllObjects];
    }
    if (_assetsFetchResults) {
        _assetsFetchResults = nil;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Photos library iOS >= 8
        PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
        allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        weakSelf.assetsFetchResults = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
        [weakSelf.assetsFetchResults indexOfObject:[NSNull null] inRange:NSMakeRange(0, 1)];
        [_items addObject:[NSNull null]];
        for (PHAsset *asset in weakSelf.assetsFetchResults) {
            if (asset.mediaType == PHAssetMediaTypeImage) {
                TFAsset *tfAsset = [TFAsset assetFromPH:asset];
                if ([self fliterWithAsset:tfAsset]) {
                    [_items addObject:tfAsset];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.navigationItem.title = NSLocalizedString(@"All Photos", @"");
            [weakSelf.collectionView reloadData];
            [self updateViewState];
        });
    });
    
    
}

- (BOOL)fliterWithAsset:(TFAsset *)asset {
    for (NSString *imageType in self.filterImageTypes) {
        NSString *propertyName = [@"is" stringByAppendingString:imageType];
        if ([asset valueForKey:propertyName]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupViews];
}

- (void)setupViews {
    [self.view addSubview:self.collectionView];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                     target:self
                                                                                     action:@selector(onRightNavClick:)];
    rightButtonItem.tintColor  = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    [self setupToolBar];
}

- (void)onLeftNavClick:(id)sender {
    
}

- (void)onRightNavClick:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showAlbumList {
    
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Add button to the navigation bar if the asset collection supports adding content.
    if (!self.assetCollection || [self.assetCollection canPerformEditOperation:PHCollectionEditOperationAddContent]) {
        
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadAssets];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(UICollectionView *) collectionView {
    if (!_collectionView) {
        TFLibraryViewLayout *flowLayout = [[TFLibraryViewLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                             collectionViewLayout:flowLayout];
        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];
        [_collectionView setAllowsMultipleSelection:self.allowsMultipleSelection];
        [_collectionView setBackgroundColor:self.view.backgroundColor];
        
        
        [_collectionView registerClass:[TFLibraryCollectionViewCell class]
            forCellWithReuseIdentifier:kTFLCollectionLibraryIdentifier];
        [_collectionView registerClass:[TFLibraryCameraCollectionViewCell class]
            forCellWithReuseIdentifier:kTFLCollectionCameraIdentifier];
        
        
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize cellSize = ((UICollectionViewFlowLayout *)flowLayout).itemSize;
        AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
        
        flowLayout.headerReferenceSize = CGSizeZero;
        flowLayout.footerReferenceSize = CGSizeZero;
    }
    return _collectionView;
}


- (void)setupToolBar {
    // Toolbar items
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedSpace.width = -8; // To balance action button
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.selectedButton];
    UIBarButtonItem *collectionButtonItem = [[UIBarButtonItem alloc] initWithTitle:TFPhotoBrowserLocalizedStrings(@"Album")
                                                                             style:UIBarButtonItemStyleDone
                                                                            target:self
                                                                            action:@selector(showAlbumList)];
    
    [items addObject:fixedSpace];
    [items addObject:collectionButtonItem];
    [items addObject:flexSpace];
    [items addObject:doneButtonItem];
    [items addObject:fixedSpace];
    
    [self setToolbarItems:items
                 animated:YES];
}

- (UIButton *)selectedButton {
    if (!_selectedButton) {
        _selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectedButton setBackgroundImage:[self createImageWithColor:self.barButtonColor] forState:UIControlStateSelected];
        [_selectedButton setBackgroundImage:[self createImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
        [[_selectedButton titleLabel] setFont:[UIFont systemFontOfSize:14]];
        _selectedButton.layer.masksToBounds = YES;
        _selectedButton.layer.cornerRadius = 4;
        [_selectedButton setTitle:TFPhotoBrowserLocalizedStrings(@"Done") forState:UIControlStateNormal];
        [_selectedButton setFrame:CGRectMake(0, 0, 100, 32)];
        [_selectedButton addTarget:self action:@selector(onViewClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectedButton;
}


- (UIImage *)createImageWithColor:(UIColor *)color {
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)onViewClick:(id)sender {
    if ([_libraryControllerDelegate respondsToSelector:@selector(didSelectPHAssets:removeList:infos:)]) {
        [_libraryControllerDelegate didSelectPHAssets:_selectedAssets removeList:_removeAssets infos:nil];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateViewState {
    NSInteger count = [self.selectedAssets count];
    _selectedButton.selected = count > 0;
    
    BOOL isM = count && _maximumNumberOfSelection;
    [_selectedButton setTitle:isM ? [NSString stringWithFormat:@"%@(%ld/%ld)",TFPhotoBrowserLocalizedStrings(@"Done"),[self.selectedAssets count],_maximumNumberOfSelection]:TFPhotoBrowserLocalizedStrings(@"Done")
                     forState:UIControlStateNormal];
}

- (void)updateCollectionViewCell:(NSIndexPath *)indexPath progress:(double)progress {
    
}

- (void)selectItem:(NSIndexPath *)indexPath asset:(TFAsset *)asset {
    if (!_selectedAssets) {
        _selectedAssets = [NSMutableArray array];
    }
    if (!_removeAssets) {
        _removeAssets = [NSMutableArray array];
    }
    [_selectedAssets addObject:asset];
    [_removeAssets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqual:asset.localIdentifier]) {
            [_removeAssets removeObject:obj];
        }
    }];
    [self updateViewState];
}
- (void)deleteItem:(NSIndexPath *)indexPath {
    [self updateViewState];
}


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    // Check if there are changes to the assets we are showing.
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assetsFetchResults];
    if (collectionChanges == nil) {
        return;
    }
    
    /*
     Change notifications may be made on a background queue. Re-dispatch to the
     main queue before acting on the change as we'll be updating the UI.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        // Get the new fetch result.
        self.assetsFetchResults = [collectionChanges fetchResultAfterChanges];
        
        UICollectionView *collectionView = self.collectionView;
        
        if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
            // Reload the collection view if the incremental diffs are not available
            [collectionView reloadData];
            
        } else {
            /*
             Tell the collection view to animate insertions and deletions if we
             have incremental diffs.
             */
            [collectionView performBatchUpdates:^{
                NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                if ([removedIndexes count] > 0) {
                    [collectionView deleteItemsAtIndexPaths:[removedIndexes tfl_indexPathsFromIndexesWithSection:0]];
                }
                
                NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                if ([insertedIndexes count] > 0) {
                    [collectionView insertItemsAtIndexPaths:[insertedIndexes tfl_indexPathsFromIndexesWithSection:0]];
                }
                
                NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                if ([changedIndexes count] > 0) {
                    [collectionView reloadItemsAtIndexPaths:[changedIndexes tfl_indexPathsFromIndexesWithSection:0]];
                }
            } completion:NULL];
        }
        
        [self resetCachedAssets];
    });
}


#pragma mark -
#pragma mark UICollectionView data source.
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0 ) {
        TFLibraryCameraCollectionViewCell *cameraCell = [collectionView dequeueReusableCellWithReuseIdentifier:kTFLCollectionCameraIdentifier forIndexPath:indexPath];
        [cameraCell startCamera];
        return cameraCell;
    }
    TFLibraryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTFLCollectionLibraryIdentifier forIndexPath:indexPath];
    TFAsset *asset = self.items[indexPath.item];
    if (asset.isPHAsset) {
        cell.representedAssetIdentifier = asset.localIdentifier;
        // Add a badge to the cell if the PHAsset represents a Live Photo.
        if (asset.phAsset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
            // Add Badge Image to the cell to denote that the asset is a Live Photo.
            UIImage *badge = [PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent];
            cell.livePhotoBadgeImage = badge;
        }
        // Request an image for the asset from the PHCachingImageManager.
        [self.imageManager requestImageForAsset:asset.phAsset
                                     targetSize:AssetGridThumbnailSize
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      // Set the cell's thumbnail image if it's still showing the same asset.
                                      if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                          [cell setThumbnailImage:result
                                             imageResultIsInCloud:NO];
                                      }
                                  }];
    }
    else {
        [cell setThumbnailImage:asset.thumbnail imageResultIsInCloud:NO];
    }
    if ([_selectedAssets containsObject:asset]) {
        [cell setSelected:YES];
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath; {
    if (indexPath.section == 0 && indexPath.item == 0) {
        return NO;
    }
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.item == 0) {
        return YES;
    }
    return [self validateMaximumNumberOfSelections:([self.selectedAssets count] + 1)];
}
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.item == 0) {
        //打开相机
        if (!self.selectedAssets) {
            _selectedAssets = [NSMutableArray array];
        }
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])  {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.delegate = self;
            
            [self presentViewController:imagePickerController
                               animated:YES
                             completion:^{
                                 TFLibraryCameraCollectionViewCell *item = [collectionView dequeueReusableCellWithReuseIdentifier:kTFLCollectionCameraIdentifier
                                                                                                                     forIndexPath:indexPath];
                                 [item removeCamera];
                             }];
        }
        else {
            [SVProgressHUD showImage:nil status:TFPhotoBrowserLocalizedStrings(@"Can't support camera")];
        }
        
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    } else {
        TFAsset *asset = [self.items objectAtIndex:indexPath.item];
        if (asset.size.width > 0) {
            if (self.allowsMultipleSelection) {
                //多选
                if (asset.isImageResultIsInCloud) {
                    [SVProgressHUD showInfoWithStatus:TFPhotoBrowserLocalizedStrings(@"Photos need download from iCloud")];
                    //图片需要从iCloud下载
                    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
                }
                else {
                    [self selectItem:indexPath asset:asset];
                }
            } else {
                if ( _allowsImageCrop) {
                    //打开裁剪界面
                    TFAsset *asset = [self.items objectAtIndex:indexPath.item];
                    [self cropImageByALAsset:asset];
                } else {
                    //选择完成
                    if ([_libraryControllerDelegate respondsToSelector:@selector(didSelectPHAssets:removeList:infos:)]) {
                        [_libraryControllerDelegate didSelectPHAssets:@[asset] removeList:nil infos:nil];
                    }
                }
            }
            [self updateViewState];
        }
    }
}



- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.item == 0) {
        return;
    }
    TFAsset *asset = [self.items objectAtIndex:indexPath.item];
    if (asset.size.width > 0) {
        if ([_selectedAssets containsObject:asset]) {
            [_selectedAssets removeObject:asset];
        }
        if (!_removeAssets) {
            _removeAssets = [NSMutableArray array];
        }
        [_removeAssets addObject:asset];
        [self updateViewState];
    }
}

- (void)cropImageByALAsset:(TFAsset *)asset {
    //使用图片剪裁功能
    __weak typeof(self) blockSelf = self;
    UIImage *previewImage = nil;
    UIImage *sourceImage = nil;
    if (asset.isPHAsset) {
        previewImage = asset.thumbnail;
        sourceImage = asset.fullScreenImage;
    }else {
        previewImage = [UIImage imageWithCGImage:[asset.alAsset aspectRatioThumbnail]];
        sourceImage = [UIImage imageWithCGImage:[asset.alAsset.defaultRepresentation fullScreenImage]];
    }
    
    
    //    [UIImage imageWithCGImage:[asset.defaultRepresentation fullResolutionImage]
    //                        scale:[asset.defaultRepresentation scale]
    //                  orientation:(UIImageOrientation)[asset.defaultRepresentation orientation]]
    
    
    
    //裁图控件
    if (!_editorViewController) {
        _editorViewController = [[TFImageCropViewController alloc] init];
        _editorViewController.checkBounds = YES;
        _editorViewController.rotateEnabled = YES;
        if ([self.libraryControllerDelegate respondsToSelector:@selector(sizeOfImageCrop)]) {
            CGSize size = [self.libraryControllerDelegate sizeOfImageCrop];
            [_editorViewController setCropSize:size];
        }
        _editorViewController.minimumScale = 0.2;
        _editorViewController.maximumScale = 10;
    }
    _editorViewController.sourceImage = sourceImage;
    _editorViewController.previewImage = previewImage;
    [_editorViewController reset:NO];
    
    
    _editorViewController.doneCallback = ^(UIImage *image ,BOOL canceled) {
        if ([blockSelf.libraryControllerDelegate respondsToSelector:@selector(didSelectImage:)]) {
            [blockSelf.libraryControllerDelegate didSelectImage:image];
        }
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController presentViewController:_editorViewController
                                                animated:YES
                                              completion:^{
                                                  if ([self.libraryControllerDelegate respondsToSelector:@selector(sizeOfImageCrop)])
                                                  {
                                                      CGSize size = [self.libraryControllerDelegate sizeOfImageCrop];
                                                      [_editorViewController setCropSize:size];
                                                  }
                                                  [_editorViewController reset:YES];
                                              }];
    });
    
    
}



#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Update cached assets for the new visible area.
    [self updateCachedAssets];
}

#pragma mark - Asset Caching
- (void)resetCachedAssets {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        [self.imageManager stopCachingImagesForAllAssets];
        self.previousPreheatRect = CGRectZero;
    }
    
}

- (void)updateCachedAssets {
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect.
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    /*
     Check if the collection view is showing an area that is significantly
     different to the last preheated area.
     */
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect
                                   andRect:preheatRect
                            removedHandler:^(CGRect removedRect)
         {
             NSArray *indexPaths = [self.collectionView tfl_indexPathsForElementsInRect:removedRect];
             [removedIndexPaths addObjectsFromArray:indexPaths];
         } addedHandler:^(CGRect addedRect) {
             NSArray *indexPaths = [self.collectionView tfl_indexPathsForElementsInRect:addedRect];
             [addedIndexPaths addObjectsFromArray:indexPaths];
         }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        // Update the assets the PHCachingImageManager is caching.
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:AssetGridThumbnailSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:AssetGridThumbnailSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        // Store the preheat rect to compare against in the future.
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    if (indexPaths.count == 0){
        return nil;
    }
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        if (indexPath.item > 0 && indexPath.item < indexPaths.count) {
            PHAsset *asset = self.assetsFetchResults[indexPath.item];
            [assets addObject:asset];
        }
    }
    return assets;
}

#pragma mark -  UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    __weak typeof(self) blockSelf = self;
    //    if (blockSelf.allowsMultipleSelection) {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    __block PHObjectPlaceholder *placeholderAsset = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *newAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        placeholderAsset = newAssetRequest.placeholderForCreatedAsset;
    } completionHandler:^(BOOL success, NSError *error) {
        if(success){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [blockSelf.navigationController dismissViewControllerAnimated:YES
                                                                   completion:nil];
            });
            
            TFAsset *asset = [TFAsset assetFromLocalIdentifier:placeholderAsset.localIdentifier];
            
            if (blockSelf.allowsMultipleSelection) {
                [_selectedAssets addObject:asset];
            }else {
                if ( _allowsImageCrop) {
                    //打开裁剪界面
                    
                    [self cropImageByALAsset:asset];
                    
                    
                    
                } else {
                    //选择完成
                    if ([_libraryControllerDelegate respondsToSelector:@selector(didSelectPHAssets:removeList:infos:)]) {
                        [_libraryControllerDelegate didSelectPHAssets:@[asset] removeList:nil infos:nil];
                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                    }
                }
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateViewState];
            });
            
            
        } else {
            //            failureBlock(error);
        }
    }];
    
    
}

#pragma mark - Validating Selections

- (BOOL)validateNumberOfSelections:(NSUInteger)numberOfSelections
{
    NSUInteger minimumNumberOfSelection = MAX(1, self.minimumNumberOfSelection);
    BOOL qualifiesMinimumNumberOfSelection = (numberOfSelections >= minimumNumberOfSelection);
    
    BOOL qualifiesMaximumNumberOfSelection = YES;
    if (minimumNumberOfSelection <= self.maximumNumberOfSelection) {
        qualifiesMaximumNumberOfSelection = (numberOfSelections <= self.maximumNumberOfSelection);
    }
    
    return (qualifiesMinimumNumberOfSelection && qualifiesMaximumNumberOfSelection);
}

- (BOOL)validateMaximumNumberOfSelections:(NSUInteger)numberOfSelections
{
    NSUInteger minimumNumberOfSelection = MAX(1, self.minimumNumberOfSelection);
    
    if (minimumNumberOfSelection <= self.maximumNumberOfSelection) {
        return (numberOfSelections <= self.maximumNumberOfSelection);
    }
    
    return YES;
}


#pragma mark - 图片裁剪

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
