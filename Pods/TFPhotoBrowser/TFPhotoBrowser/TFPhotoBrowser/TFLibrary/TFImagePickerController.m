//
//  TFImagePickerController.m
//  TFPhotoBrowser
//
//  Created by Melvin on 2/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFImagePickerController.h"


@import Photos;

#import "TFAsset.h"
#import "TFPhotoBrowserBundle.h"
#import "TFCollectionsTitleButton.h"
#import "TFCollectionPickerController.h"
#import "TFAssetCell.h"
#import "TFAssetImageView.h"
#import "TFMomentHeaderView.h"
#import "TFCollectionViewFloatingHeaderFlowLayout.h"
#import "NSDate+TFFormattedDay.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "TFPhotoBrowser.h"
#import "TFiCloudDownloadHelper.h"

#define TFObjectSpacing 2.0


@interface TFImagePickerController () <UIPopoverPresentationControllerDelegate, TFCollectionPickerControllerDelegate, PHPhotoLibraryChangeObserver, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIViewControllerRestoration,TFPhotoBrowserDelegate,TFAssetCellDelegate>
{
    NSMutableOrderedSet *_selectedAssets;
    
    UIButton *_collectionButton;
    PHFetchResult *_fetchResult;
    PHFetchResult *_moments;
    NSCache *_momentCache;
    BOOL _windowLoaded;
    NSInteger _pasteChangeCount;
    
    TFCollectionPickerController *_collectionPicker;
    CGSize _fullScreenSize;
    UIView *_browserToolBarView;
    NSMutableDictionary  *headerViewDictionary;
    NSArray *_headerModelsArr;
    UIColor *_headerBackColor;
    UIColor *_headerTitleColor;
    
    __block BOOL _loadingQualityImage;
}

@end

@implementation TFImagePickerController

#pragma mark - Properties

- (void)setDelegate:(id<TFImagePickerControllerDelegate>)delegate {
    _delegate = delegate;
    
    [self _updateDoneButton];
}

- (void)setSelectedAssets:(NSArray *)selectedAssets {
    _selectedAssets = [NSMutableOrderedSet orderedSetWithArray:selectedAssets];
    
    [self _updateDoneButton];
    [self _updateSelectAllButton];
    [self _updateSelection];
}

- (NSArray *)selectedAssets {
    // -[NSOrderedSet array] is an array proxy so copy the result
    return [_selectedAssets.array copy];
}

- (void)addSelectedAssets:(NSOrderedSet *)objects {
    [_selectedAssets unionOrderedSet:objects];
    
    [self _updateSelection];
    [self _updateDoneButton];
    [self _updateSelectAllButton];
    if (!self.allowsMultipleSelection) {
        //单选
        [self done:nil];
    }
}

- (void)selectAsset:(PHAsset *)asset {
    if ([_selectedAssets count] >= _maxSelectedCount) {
        [SVProgressHUD showInfoWithStatus:[NSString localizedStringWithFormat:TFPhotoBrowserLocalizedStrings(@"Choose %d photos at most"), _selectedAssets.count]];
        return;
    }
    [self addSelectedAssets:[NSOrderedSet orderedSetWithObject:asset]];
}

- (void)removeSelectedAssets:(NSOrderedSet *)objects {
    [_selectedAssets minusOrderedSet:objects];
    [self _updateSelection];
    [self _updateDoneButton];
    [self _updateSelectAllButton];
}

- (void)deselectAsset:(PHAsset *)asset {
    [self removeSelectedAssets:[NSOrderedSet orderedSetWithObject:asset]];
}

- (PHFetchOptions *)_assetFetchOptions {
    NSMutableArray *assetMediaTypes = [NSMutableArray new];
    if ([self.mediaTypes containsObject:(id)kUTTypeImage]) {
        [assetMediaTypes addObject:@(PHAssetMediaTypeImage)];
    }
    if ([self.mediaTypes containsObject:(id)kUTTypeVideo]) {
        [assetMediaTypes addObject:@(PHAssetMediaTypeVideo)];
    }
    if ([self.mediaTypes containsObject:(id)kUTTypeAudio]) {
        [assetMediaTypes addObject:@(PHAssetMediaTypeAudio)];
    }
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType IN %@", assetMediaTypes];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    options.includeAllBurstAssets = NO;
    
    return options;
}

- (void)setAssetCollection:(PHAssetCollection *)assetCollection {
    _assetCollection = assetCollection;
    
    [self _updateForAssetCollection];
    [self _updateSelectAllButton];
}

- (void)_updateForAssetCollection
{
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status != PHAuthorizationStatusAuthorized) {
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
        CGFloat buttonWidth = 120;
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
    if (_assetCollection == nil) {
        self.title = TFPhotoBrowserLocalizedStrings(@"Moments");
    } else {
        self.title = _assetCollection.localizedTitle;
    }
    [_collectionButton setTitle:self.title forState:UIControlStateNormal];
    [_collectionButton sizeToFit];
    
    
    if (_assetCollection != nil) {
        _fetchResult = [PHAsset fetchAssetsInAssetCollection:_assetCollection options:[self _assetFetchOptions]];
        _moments = nil;
    } else {
        _fetchResult = nil;
        _moments = [PHAssetCollection fetchMomentsWithOptions:nil];
        // 存储头部信息
        [self saveHeaderModels];
    }
    
    if (self.isViewLoaded) {
        [self.collectionView reloadData];
        
        if (_moments != nil) {
            [self.collectionView layoutIfNeeded];
            [self _scrollToBottomAnimated:NO];
        } else {
            [self.collectionView setContentOffset:CGPointMake(0.0, -self.topLayoutGuide.length) animated:NO];
        }
    }
}

#pragma mark 存储头部信息
- (void)saveHeaderModels {
    //储存header显示数据避免重复判断数据转换
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *currentDate = [calendar dateBySettingHour:23 minute:59 second:59 ofDate:[NSDate date] options:NSCalendarWrapComponents];
    NSDateComponents *currentDateComponents = [calendar components:NSCalendarUnitYear fromDate:currentDate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    NSMutableArray *tempArr = [NSMutableArray array];
    for (PHAssetCollection *collection in _moments) {
        TFMomentHeaderModel *model = [[TFMomentHeaderModel alloc] init];
        NSString *dateStr = @"";
        NSDateComponents *startDateComponents = [calendar components:NSCalendarUnitYear fromDate:collection.startDate];
        
        NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:collection.startDate toDate:currentDate options:NSCalendarWrapComponents];
        if (currentDateComponents.year>startDateComponents.year) {
            [formatter setDateFormat:TFPhotoBrowserLocalizedStrings(@"dateFormatterOverYear")];
            
            dateStr = [formatter stringFromDate:collection.startDate];
        }
        else if (components.day>6) {
            
            [formatter setDateFormat:TFPhotoBrowserLocalizedStrings(@"dateFormatterOverWeek")];
            dateStr = [formatter stringFromDate:collection.startDate];
            
        }
        else if (components.day>1) {
            [formatter setDateFormat:TFPhotoBrowserLocalizedStrings(@"dateFormatterOverInWeek")];
            dateStr = [formatter stringFromDate:collection.startDate];
        }
        else if (components.day==1) {
            dateStr = TFPhotoBrowserLocalizedStrings(@"Yesterday");
        }
        else if (components.day==0) {
            dateStr = TFPhotoBrowserLocalizedStrings(@"Today");
        }
        if (collection.localizedTitle) {
            model.reuseIdentifier = TFMomentHeaderViewDetailIdentifier;
            model.primary = collection.localizedTitle;
            model.secondary = [collection.localizedLocationNames componentsJoinedByString:@"、"];
            [formatter setDateFormat:TFPhotoBrowserLocalizedStrings(@"dateFormatterOverWeekDetail")];
            model.detail = [formatter stringFromDate:collection.startDate];
        }
        else {
            model.reuseIdentifier = TFMomentHeaderViewNomalIdentifier;
            model.primary = dateStr;
        }
        [tempArr addObject:model];
    }
    _headerModelsArr = [NSArray arrayWithArray:tempArr];
}

- (void)actionForSettingButton:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)_updateDoneButton {
    _doneButton.enabled = _selectedAssets.count > 0;
    
    NSString *title = nil;
    
    if ([self.delegate respondsToSelector:@selector(imagePickerControllerTitleForDoneButton:)]) {
        title = [self.delegate imagePickerControllerTitleForDoneButton:self];
    } else if (_selectedAssets.count > 0) {
        title = [NSString stringWithFormat:@"%@(%ld/%ld)",TFPhotoBrowserLocalizedStrings(@"Done"),[self.selectedAssets count],_maxSelectedCount];
    } else {
        title = TFPhotoBrowserLocalizedStrings(@"Done");
    }
    
    _doneButton.title = title;
}

- (void)_updateSelectAllButton {
    _selectAllButton.enabled = _moments == nil;
    __block BOOL allSelected = _moments == nil;
    
    PHFetchResult *fetchResult = _fetchResult;
    NSSet *selectedAssets = [_selectedAssets copy];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [fetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
            allSelected &= [selectedAssets containsObject:asset];
            *stop = !allSelected;
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (allSelected) {
                _selectAllButton.title = TFPhotoBrowserLocalizedStrings(@"Deselect All");
                _selectAllButton.action = @selector(deselectAll:);
            } else {
                _selectAllButton.title = TFPhotoBrowserLocalizedStrings(@"Select all");
                _selectAllButton.action = @selector(selectAll:);
            }
        });
    });
}



- (void)_updateToolbarItems:(BOOL)animated {
    NSMutableArray *items = [NSMutableArray new];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [items addObject:_cameraButton];
        if (_showScanButton) {
            UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
            fixedSpace.width = 20; // To balance action button
            [items addObject:fixedSpace];
            [items addObject: _scanButton];
        }
        
    }
    
    
    if ([[UIPasteboard generalPasteboard] containsPasteboardTypes:@[(NSString *)kUTTypeImage]] && [UIPasteboard generalPasteboard].changeCount != _pasteChangeCount) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            space.width = 20.0;
            [items addObject:space];
        }
        [items addObject:_pasteButton];
    }
    
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    
    //    [items addObject:_selectAllButton];
    [items addObject:_doneButton];
    
    [self setToolbarItems:items animated:animated];
}

- (void)_updateSelection {
    if (!self.isViewLoaded) {
        return;
    }
    
    for (TFAssetCell *cell in self.collectionView.visibleCells) {
        cell.assetSelected = [_selectedAssets containsObject:cell.asset];
    }
}

- (void)setSelectedAssetBadgeImage:(UIImage *)selectedAssetBadgeImage
{
    _selectedAssetBadgeImage = selectedAssetBadgeImage ?: TFPhotoBrowserImageNamed(@"TFLibraryCollectionSelected");
}

#pragma mark - Initialization

- (void)_init {
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    _fullScreenSize = CGSizeMake(CGRectGetWidth([[UIScreen mainScreen] bounds]) *scale, CGRectGetHeight([[UIScreen mainScreen] bounds]) *scale);
    _maxSelectedCount = NSIntegerMax;
    _mediaTypes = @[ (NSString *)kUTTypeImage ];
    _selectedAssets = [NSMutableOrderedSet new];
    _selectedAssetBadgeImage = TFPhotoBrowserImageNamed(@"TFLibraryCollectionSelected");
    
    _cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    _cancelButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = _cancelButton;
    
    _doneButton = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    //    self.navigationItem.rightBarButtonItem = _doneButton;
    
//    _cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePicture:)];
    _cameraButton = [[UIBarButtonItem alloc]initWithImage:TFPhotoBrowserImageNamed(@"TFImagePickCameraIcon") style:UIBarButtonItemStylePlain target:self action:@selector(takePicture:)];
    
    _scanButton = [[UIBarButtonItem alloc]initWithImage:TFPhotoBrowserImageNamed(@"TFImagePickScanIcon") style:UIBarButtonItemStylePlain target:self action:@selector(takeScan:)];
    
    _pasteButton = [[UIBarButtonItem alloc] initWithTitle:TFPhotoBrowserLocalizedStrings(@"Paste") style:UIBarButtonItemStylePlain target:self action:@selector(paste:)];
    
    _selectAllButton = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(selectAll:)];
    
    self.hidesBottomBarWhenPushed = NO;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    _collectionButton = [TFCollectionsTitleButton buttonWithType:UIButtonTypeSystem];
    [_collectionButton addTarget:self action:@selector(changeCollection:) forControlEvents:UIControlEventTouchUpInside];
    _collectionButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    _collectionButton.tintColor = [UIColor whiteColor];
    _collectionButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, 3.0, 0.0, 0.0);
    [_collectionButton setImage:[TFPhotoBrowserImageNamed(@"TFLibraryCollectionNavDisclosure") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_collectionButton sizeToFit];
    self.navigationItem.titleView = _collectionButton;
    
    _momentCache = [[NSCache alloc] init];
    [self _updateForAssetCollection];
    [self _updateDoneButton];
    [self _updateSelectAllButton];
    [self _updateToolbarItems:NO];
    headerViewDictionary = [[NSMutableDictionary alloc]init];
    
    _browserToolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    _browserToolBarView.backgroundColor = [UIColor darkTextColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pasteboardChanged:) name:UIPasteboardChangedNotification object:[UIPasteboard generalPasteboard]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[TFCollectionViewFloatingHeaderFlowLayout alloc] init];
    layout.minimumLineSpacing = TFObjectSpacing;
    layout.minimumInteritemSpacing = TFObjectSpacing;
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithScanButton {
    UICollectionViewFlowLayout *layout = [[TFCollectionViewFloatingHeaderFlowLayout alloc] init];
    layout.minimumLineSpacing = TFObjectSpacing;
    layout.minimumInteritemSpacing = 0.0;
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        _showScanButton = YES;
        [self _init];
    }
    return self;
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NOTICE_RELOAD_COLLECTION_INDEXPATH" object:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[TFAssetCell class] forCellWithReuseIdentifier:@"Cell"];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.allowsMultipleSelection = self.allowsMultipleSelection;
    [self.collectionView registerClass:[TFMomentHeaderNomalView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:TFMomentHeaderViewNomalIdentifier];
    [self.collectionView registerClass:[TFMomentHeaderDetailView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:TFMomentHeaderViewDetailIdentifier];

    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showAsset:)];
    recognizer.minimumPressDuration = 0.5;
    [self.collectionView addGestureRecognizer:recognizer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionForReloadNotification:) name:@"NOTICE_RELOAD_COLLECTION_INDEXPATH" object:nil];    
}





- (void)viewDidLayoutSubviews {
    if (self.view.window && !_windowLoaded) {
        _windowLoaded = YES;
        //获取头部颜色信息
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(sectionHeaderTitleColorForImagePickerController:)]) {
                _headerTitleColor = [self.delegate sectionHeaderTitleColorForImagePickerController:self];
            }
            if ([self.delegate respondsToSelector:@selector(sectionHeaderBackColorForImagePickerController:)]) {
                _headerBackColor = [self.delegate sectionHeaderBackColorForImagePickerController:self];
            }
        }
        if (!_headerTitleColor) {
            _headerTitleColor = [UIColor blackColor];
        }
        if (!_headerBackColor) {
            _headerBackColor = [UIColor clearColor];
        }

        [self.collectionView reloadData];
        
        if (_moments != nil) {
            [self.collectionView layoutIfNeeded];
            [self _scrollToBottomAnimated:NO];
        }
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    
    UIFont *font = self.navigationController.navigationBar.titleTextAttributes[NSFontAttributeName];
    if (font != nil) {
        _collectionButton.titleLabel.font = font;
        [_collectionButton sizeToFit];
    }
}


#pragma mark - Actions

- (IBAction)done:(id)sender {
    if ([self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingAssets:)]) {
        [self.delegate imagePickerController:self didFinishPickingAssets:self.selectedAssets];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancel:(id)sender {
    if ([self.delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
        [self.delegate imagePickerControllerDidCancel:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)takePicture:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.mediaTypes = self.mediaTypes;
    imagePicker.videoMaximumDuration = self.videoMaximumDuration ? : 60 * 10.f;
    
    UIViewController *viewController = imagePicker;
    if ([self.delegate respondsToSelector:@selector(imagePickerController:willDisplayCameraViewController:)]) {
        viewController = [self.delegate imagePickerController:self willDisplayCameraViewController:imagePicker];
    }
    
    if (viewController != nil) {
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (void)takeScan:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerControllerDidScan:)]) {
        [self.delegate imagePickerControllerDidScan:self];
    }
}

- (IBAction)paste:(id)sender {
    _pasteChangeCount = [UIPasteboard generalPasteboard].changeCount;
    
    BOOL validAsset = NO;
    
    // this is a private type, so we need to double and tripple check that everything is valid
    NSData *data = [[UIPasteboard generalPasteboard] dataForPasteboardType:@"com.apple.mobileslideshow.asset.localidentifier"];
    NSString *localIdentifier = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (localIdentifier != nil) {
        PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[ localIdentifier ] options:nil];
        
        if (result.firstObject != nil) {
            [self selectAsset:result.firstObject];
            [self _updateSelection];
            validAsset = YES;
        }
    }
    
    
    if (!validAsset) {
        // we can't reference the asset directly, either because of an internal change or because it was coppied from somewhere else
        // create an asset and add it to the library
        NSArray *images = [[UIPasteboard generalPasteboard] images];
        
        [self addImages:images];
    }
    
    [self _updateToolbarItems:YES];
}

- (IBAction)selectAll:(id)sender {
    if (_moments != nil) {
        return;
    }
    
    PHFetchResult *fetchResult = _fetchResult;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableOrderedSet *assets = [NSMutableOrderedSet new];
        
        [fetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
            [assets addObject:asset];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addSelectedAssets:assets];
            [self _updateSelection];
        });
    });
}

- (IBAction)deselectAll:(id)sender
{
    if (_moments != nil) {
        return;
    }
    
    PHFetchResult *fetchResult = _fetchResult;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableOrderedSet *assets = [NSMutableOrderedSet new];
        
        [fetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
            [assets addObject:asset];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeSelectedAssets:assets];
            [self _updateSelection];
        });
    });
}

- (void)showAsset:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint location = [recognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    if (indexPath != nil) {
        TFPhotoBrowser *photoBrowser = [[TFPhotoBrowser alloc] initWithDelegate:self];
        [photoBrowser setCurrentPhotoIndex:indexPath.item];
        [photoBrowser setDisplaySelectionButtons:YES];
        [photoBrowser setDisplayActionButton:YES];
        [photoBrowser setIndexPath:indexPath];
        [self presentViewController:photoBrowser animated:YES completion:NULL];
    }
}

- (IBAction)changeCollection:(id)sender {
    if (_collectionPicker == nil) {
        _collectionPicker = [[TFCollectionPickerController alloc] init];
        _collectionPicker.delegate = self;
    }
    
    _collectionPicker.assetFetchOptions = [self _assetFetchOptions];
    if (_selectedAssets.count > 0) {
        PHAssetCollection *collection = [PHAssetCollection transientAssetCollectionWithAssets:_selectedAssets.array title:TFPhotoBrowserLocalizedStrings(@"Selected")];
        _collectionPicker.additionalAssetCollections = @[ collection ];
    } else {
        _collectionPicker.additionalAssetCollections = @[];
    }
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_collectionPicker];
    navigationController.restorationIdentifier = @"TFCollectionPickerController.NavigationController";
    navigationController.restorationClass = [self class];
    navigationController.navigationBarHidden = YES;
    
    navigationController.modalPresentationStyle = UIModalPresentationPopover;
    navigationController.popoverPresentationController.sourceView = _collectionButton;
    navigationController.popoverPresentationController.sourceRect = _collectionButton.bounds;
    navigationController.popoverPresentationController.delegate = self;
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)addImages:(NSArray<UIImage *> *)images {
    NSMutableArray *localIdentifiers = [NSMutableArray new];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        for (UIImage *image in images) {
            PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            NSString *localIdentifier = createAssetRequest.placeholderForCreatedAsset.localIdentifier;
            [localIdentifiers addObject:localIdentifier];
        }
    } completionHandler:^(BOOL success, NSError *error) {
        if (error != nil) {
            NSLog(@"Error creating asset from pasteboard: %@", error);
        } else if (success) {
            PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:localIdentifiers options:nil];
            
            NSMutableOrderedSet *assets = [NSMutableOrderedSet new];
            [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [assets addObject:obj];
            }];
            
            if (assets.count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self addSelectedAssets:assets];
                    [self _updateSelection];
                });
            }
        }
    }];
}

- (void)addVideos:(NSArray<NSURL *> *)videos {
    NSMutableArray *localIdentifiers = [NSMutableArray new];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        for (NSURL *videoURL in videos) {
            PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoURL];
            NSString *localIdentifier = createAssetRequest.placeholderForCreatedAsset.localIdentifier;
            [localIdentifiers addObject:localIdentifier];
        }
    } completionHandler:^(BOOL success, NSError *error) {
        if (error != nil) {
            NSLog(@"Error creating asset from pasteboard: %@", error);
        } else if (success) {
            PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:localIdentifiers options:nil];
            
            NSMutableOrderedSet *assets = [NSMutableOrderedSet new];
            [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [assets addObject:obj];
            }];
            
            if (assets.count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self addSelectedAssets:assets];
                    [self _updateSelection];
                });
            }
        }
    }];
}

- (void)updateHeaderView:(NSIndexPath*)indexPath {
    //    UICollectionReusableView
    NSLog(@"index.section = %@, item = %@",@(indexPath.section),@(indexPath.row));

    TFMomentHeaderNomalView *headerView = [headerViewDictionary objectForKey:[NSString stringWithFormat:@"%@",@(indexPath.section)]];

    __block BOOL allSelected = _moments[indexPath.section] != nil;
    
    PHAssetCollection *collection = _moments[indexPath.section];
    PHFetchResult *fetchResult = [self _assetsForMoment:collection];
    NSSet *selectedAssets = [_selectedAssets copy];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [fetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
            allSelected &= [selectedAssets containsObject:asset];
            *stop = !allSelected;
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            headerView.selectedButton.selected = allSelected;
        });
        
    });
    
}




#pragma mark - Notifications

- (void)actionForReloadNotification:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSIndexPath *path = (NSIndexPath*)[userInfo objectForKey:@"indexPath"];
    UIButton *selectedAllBtn = (UIButton *)[userInfo objectForKey:@"button"];
    BOOL state = selectedAllBtn.selected;
    selectedAllBtn.selected = !selectedAllBtn.selected;
    PHAssetCollection *collection = _moments[path.section];
    PHFetchResult *fetchResult = [self _assetsForMoment:collection];
    NSMutableArray *array = [NSMutableArray array];
    NSInteger addAssetCount = 0;
    NSInteger orginalCount = _selectedAssets.count;
    for (PHAsset *asset in fetchResult) {
        if (state) {
            if ([_selectedAssets containsObject:asset]) {
                [self deselectAsset:asset];
            }
        }else {
            [array addObject:asset];
            if (![_selectedAssets containsObject:asset]) {
                [self selectAsset:asset];
                addAssetCount ++;
            }
           
        }
        
    }
    if (addAssetCount + orginalCount > _maxSelectedCount && state==NO) {
        selectedAllBtn.selected = NO;
    }
   
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerController:didSelectedPickingAssets:)]) {
        [self.delegate imagePickerController:self didSelectedPickingAssets:array];
    }
}


- (void)pasteboardChanged:(NSNotification *)notification {
    [self _updateToolbarItems:YES];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    // UIPasteboardChangedNotification is not called when we are in the background during the change
    [self _updateToolbarItems:NO];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (_moments != nil) {
        return _moments.count;
    } else {
        return 1;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_moments != nil) {
        PHAssetCollection *collection = _moments[section];
        PHFetchResult *fetchResult = [self _assetsForMoment:collection];
        return fetchResult.count;
    } else {
        return _fetchResult.count;
    }
}

- (PHFetchResult *)_assetsForMoment:(PHAssetCollection *)collection {
    PHFetchResult *result = [_momentCache objectForKey:collection.localIdentifier];
    if (result == nil) {
        result = [PHAsset fetchAssetsInAssetCollection:collection options:[self _assetFetchOptions]];
        [_momentCache setObject:result forKey:collection.localIdentifier];
    }
    
    return result;
}

- (PHAsset *)_assetAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = nil;
    if (_moments != nil) {
        PHAssetCollection *collection = _moments[indexPath.section];
        PHFetchResult *fetchResult = [self _assetsForMoment:collection];
        asset = fetchResult[indexPath.row];
    } else {
        asset = _fetchResult[indexPath.row];
    }
    
    return asset;
}

- (NSIndexPath *)_indexPathForAsset:(PHAsset *)asset {
    if (_moments != nil) {
        PHAssetCollection *collection = [PHAssetCollection fetchAssetCollectionsContainingAsset:asset withType:PHAssetCollectionTypeMoment options:nil].firstObject;
        NSUInteger section = [_moments indexOfObject:collection];
        
        PHFetchResult *fetchResult = [self _assetsForMoment:collection];
        NSUInteger item = [fetchResult indexOfObject:asset];
        
        if (item != NSNotFound && section != NSNotFound) {
            return [NSIndexPath indexPathForItem:item inSection:section];
        }
    } else {
        NSUInteger item = [_fetchResult indexOfObject:asset];
        
        if (item != NSNotFound) {
            return [NSIndexPath indexPathForItem:item inSection:0];
        }
    }
    
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TFAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    PHAsset *asset = [self _assetAtIndexPath:indexPath];
    
    cell.asset = asset;
    cell.assetSelected = [_selectedAssets containsObject:asset];
    cell.indexPath = indexPath;
    cell.tfAssetCellDelegate = self;
//    cell.selectedBadgeImageView.image = _selectedAssetBadgeImage;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width =  (collectionView.bounds.size.width-TFObjectSpacing*3)/4.0;
    return CGSizeMake(width, width);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    TFMomentHeaderModel *model = _headerModelsArr [indexPath.section];
    TFMomentHeaderDetailView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:model.reuseIdentifier forIndexPath:indexPath];
    [headerViewDictionary setObject:headerView forKey:[NSString stringWithFormat:@"%@",@(indexPath.section)]];
    headerView.indexPath = indexPath;
    
    PHAssetCollection *collection = _moments[indexPath.section];
    headerView.backView.backgroundColor = _headerBackColor;
    headerView.primaryLabel.text = model.primary;
    headerView.primaryLabel.textColor = _headerTitleColor;
        if (collection.localizedTitle != nil) {
            headerView.primaryLabel.text = model.primary;
            headerView.secondaryLabel.text = model.secondary;
            headerView.secondaryLabel.textColor = _headerTitleColor;
            headerView.detailLabel.text = model.detail;
            headerView.detailLabel.textColor = _headerTitleColor;
        }
        headerView.selectedButton.hidden = !_showAllSelectButton;
        if (!_showAllSelectButton) {
            return headerView;
        }
        __block BOOL allSelected = _moments[indexPath.section] != nil;
        PHFetchResult *fetchResult = [self _assetsForMoment:collection];
        NSSet *selectedAssets = [_selectedAssets copy];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [fetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
                allSelected &= [selectedAssets containsObject:asset];
                *stop = !allSelected;
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                headerView.selectedButton.selected = allSelected;
            });
            
        });
        
        
    
    return headerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (_moments != nil) {
        PHAssetCollection *collection = _moments[section];
        
        PHFetchResult *fetchResult = [self _assetsForMoment:collection];
        if (fetchResult.count == 0) {
            return CGSizeZero;
        }
        
        return CGSizeMake(collectionView.bounds.size.width, 50.0);
    } else {
        return CGSizeZero;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (_moments != nil) {
        PHAssetCollection *collection = _moments[section];
        
        PHFetchResult *fetchResult = [self _assetsForMoment:collection];
        if (fetchResult.count == 0) {
            return UIEdgeInsetsZero;
        }
        
        return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    } else {
        return UIEdgeInsetsZero;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    PHAsset *asset = [self _assetAtIndexPath:indexPath];
//    if ([_selectedAssets containsObject:asset]) {
//        [self deselectAsset:asset];
//    } else {
//        [self selectAsset:asset];
//    }
//    if (_showAllSelectButton) {
//        [self updateHeaderView:indexPath];
//    }
    TFAssetCell *cell = (TFAssetCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (!cell.assetIsInLocalAblum) {
        // 进行下载
        [self assetCellView:cell didDownloadAtIndexPath:indexPath];
        return;
    }
    
    if (indexPath != nil) {
        TFPhotoBrowser *photoBrowser = [[TFPhotoBrowser alloc] initWithDelegate:self];
        
        [photoBrowser setDisplaySelectionButtons:YES];
        [photoBrowser setDisplayActionButton:YES];
        [photoBrowser setIndexPath:indexPath];
        photoBrowser.zoomPhotosToFill = YES;
        photoBrowser.usePopAnimation = YES;
        photoBrowser.enableSwipeToDismiss = YES;
        [photoBrowser setCurrentPhotoIndex:indexPath.row];
        
        [self presentViewController:photoBrowser animated:YES completion:NULL];
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    [headerViewDictionary removeObjectForKey:[NSString stringWithFormat:@"%@",@(indexPath.section)]];
}

- (void)_scrollToBottomAnimated:(BOOL)animated {
    CGPoint contentOffset = self.collectionView.contentOffset;
    contentOffset.y = self.collectionView.contentSize.height - self.collectionView.bounds.size.height + self.collectionView.contentInset.bottom;
    contentOffset.y = MAX(contentOffset.y, -self.collectionView.contentInset.top);
    contentOffset.y = MAX(self.collectionView.contentSize.height - self.collectionView.bounds.size.height + self.collectionView.contentInset.bottom, -self.collectionView.contentInset.top);
    [self.collectionView setContentOffset:contentOffset animated:animated];
}

#pragma mark - TFAssetCellDelegate

- (void)assetCellView:(TFAssetCell *)cell didDownloadAtIndexPath:(NSIndexPath *)indexPath {
    TFiCloudDownloadHelper *helper = [TFiCloudDownloadHelper sharedHelper];
    
    if (helper.loading) {
        [SVProgressHUD showInfoWithStatus:@"图片正在从iCloud下载，请稍候!"];
        return;
    }
    
    [helper startDownLoadWithAsset:cell.asset
                   progressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           NSLog(@"%lf", progress);
                           NSNumber *progressNumber = @(progress);
                           [[NSNotificationCenter defaultCenter] postNotificationName:TFImagePickeriCloudDownLoading object:progressNumber];
                       });
                   } finined:^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:TFImagePickeriCloudDownLoadFinish object:nil];
                        });
                   }];
}

- (void)assetCellViewClick:(TFAssetCellClickType)type indexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = [self _assetAtIndexPath:indexPath];
    if ([_selectedAssets containsObject:asset]) {
        [self deselectAsset:asset];
    } else {
        [self selectAsset:asset];
        if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerController:didSelectedPickingAssets:)]) {
            [self.delegate imagePickerController:self didSelectedPickingAssets:@[asset]];
        }
    }
    if (_showAllSelectButton) {
        [self updateHeaderView:indexPath];
    }
}

#pragma mark - TFPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(TFPhotoBrowser *)photoBrowser {
    if (_moments != nil) {
        PHAssetCollection *collection = _moments[photoBrowser.indexPath.section];
        PHFetchResult *fetchResult = [self _assetsForMoment:collection];
        return fetchResult.count;
    } else {
        return _fetchResult.count;
    }
}

- (id <TFPhoto>)photoBrowser:(TFPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    
    if (_moments != nil) {
        PHAssetCollection *collection = _moments[photoBrowser.indexPath.section];
        PHFetchResult *fetchResult = [self _assetsForMoment:collection];
        TFPhoto *photo = [TFPhoto photoWithAsset:[fetchResult objectAtIndex:index]
                                      targetSize:_fullScreenSize];
        return photo;
    } else {
        TFPhoto *photo = [TFPhoto photoWithAsset:[_fetchResult objectAtIndex:index]
                                      targetSize:_fullScreenSize];
        return photo;
    }
    

}

- (void)photoBrowser:(TFPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index section:(NSInteger)section selectedChanged:(BOOL)selected {
    PHAsset *asset = [self _assetAtIndexPath:[NSIndexPath indexPathForRow:index inSection:section]];
    if (asset) {
        if (selected) {
            [self selectAsset:asset];
            if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerController:didSelectedPickingAssets:)]) {
                [self.delegate imagePickerController:self didSelectedPickingAssets:@[asset]];
            }
        }
        else {
            [self deselectAsset:asset];
        }
    }
    if (_showAllSelectButton) {
        [self updateHeaderView:[NSIndexPath indexPathForRow:index inSection:section]];
    }
}

- (BOOL)photoBrowser:(TFPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index  section:(NSInteger)section{
    PHAsset *asset = [self _assetAtIndexPath:[NSIndexPath indexPathForItem:index inSection:section]];
    return [_selectedAssets containsObject:asset];
}

- (NSDictionary*)photoBrowserSelecteNum {
    NSDictionary *dic = @{
                          @"total" : [NSString stringWithFormat:@"%@",@(_maxSelectedCount)],
                          @"current" : [NSString stringWithFormat:@"%@",@(_selectedAssets.count)]
                          };
    return dic;
}


#pragma mark - TFCollectionPickerControllerDelegate

- (void)collectionPicker:(TFCollectionPickerController *)collectionPicker didSelectCollection:(PHAssetCollection *)collection {
    self.assetCollection = collection;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_momentCache removeAllObjects];
        
        if (_moments != nil) {
            PHFetchResultChangeDetails *details = [changeInstance changeDetailsForFetchResult:_moments];
            if (details != nil) {
                _moments = [details fetchResultAfterChanges];
                // 存储头部信息
                [self saveHeaderModels];
                // incremental updates throw exceptions too often
                [self.collectionView reloadData];
                
                //                if (details.hasIncrementalChanges) {
                //                    [self.collectionView performBatchUpdates:^{
                //                        if (details.removedIndexes != nil) {
                //                            [self.collectionView deleteSections:details.removedIndexes];
                //                        }
                //
                //                        if (details.insertedIndexes != nil) {
                //                            [self.collectionView insertSections:details.insertedIndexes];
                //                        }
                //
                //                        if (details.changedIndexes != nil) {
                //                            [self.collectionView reloadSections:details.changedIndexes];
                //                        }
                //
                //                        [details enumerateMovesWithBlock:^(NSUInteger fromIndex, NSUInteger toIndex) {
                //                            [self.collectionView moveSection:fromIndex toSection:toIndex];
                //                        }];
                //                    } completion:nil];
                //                } else {
                //                    [self.collectionView reloadData];
                //                }
            }
        } else {
            PHFetchResultChangeDetails *details = [changeInstance changeDetailsForFetchResult:_fetchResult];
            if (details != nil) {
                _fetchResult = [details fetchResultAfterChanges];
                
                if (details.hasIncrementalChanges) {
                    [self.collectionView performBatchUpdates:^{
                        NSMutableArray *removedIndexPaths = [NSMutableArray new];
                        [details.removedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                            [removedIndexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                        }];
                        [self.collectionView deleteItemsAtIndexPaths:removedIndexPaths];
                        
                        
                        NSMutableArray *insertedIndexPaths = [NSMutableArray new];
                        [details.insertedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                            [insertedIndexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                        }];
                        [self.collectionView insertItemsAtIndexPaths:insertedIndexPaths];
                        
                        
                        NSMutableArray *changedIndexPaths = [NSMutableArray new];
                        [details.changedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                            [changedIndexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                        }];
                        [self.collectionView reloadItemsAtIndexPaths:changedIndexPaths];
                        
                        
                        [details enumerateMovesWithBlock:^(NSUInteger fromIndex, NSUInteger toIndex) {
                            NSIndexPath *from = [NSIndexPath indexPathForRow:fromIndex inSection:0];
                            NSIndexPath *to = [NSIndexPath indexPathForRow:fromIndex inSection:0];
                            
                            [self.collectionView moveItemAtIndexPath:from toIndexPath:to];
                        }];
                    } completion:nil];
                } else {
                    [self.collectionView reloadData];
                }
            }
        }
    });
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSURL *videoURL = info[UIImagePickerControllerMediaURL];
    
    if (image != nil) {
        [self addImages:@[image]];
    } else if (videoURL != nil) {
        [self addVideos:@[videoURL]];
    }
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - State Restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:self.mediaTypes forKey:@"mediaTypes"];
    [coder encodeObject:self.assetCollection.localIdentifier forKey:@"assetCollection"];
    [coder encodeObject:[_selectedAssets valueForKey:@"localIdentifier"] forKey:@"selectedAssets"];
    [coder encodeObject:_collectionPicker forKey:@"collectionPicker"];
    [coder encodeObject:_collectionPicker.navigationController forKey:@"collectionPickerNavigationController"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    self.mediaTypes = [coder decodeObjectForKey:@"mediaTypes"];
    
    NSString *assetCollectionIdentifier = [coder decodeObjectForKey:@"assetCollection"];
    if (assetCollectionIdentifier != nil) {
        self.assetCollection = [[PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[ assetCollectionIdentifier ] options:nil] firstObject];
    }
    
    NSOrderedSet *selectedAssetsIdentifiers = [coder decodeObjectForKey:@"selectedAssets"];
    if (selectedAssetsIdentifiers != nil) {
        NSMutableOrderedSet *assets = [NSMutableOrderedSet new];
        for (PHAsset *asset in [PHAsset fetchAssetsWithLocalIdentifiers:selectedAssetsIdentifiers.array options:nil]) {
            [assets addObject:asset];
        }
        [self addSelectedAssets:assets];
    }
    
    TFCollectionPickerController *collectionPicker = [coder decodeObjectForKey:@"collectionPicker"];
    if (collectionPicker != nil) {
        _collectionPicker = collectionPicker;
        _collectionPicker.assetFetchOptions = [self _assetFetchOptions];
        if (_selectedAssets.count > 0) {
            PHAssetCollection *collection = [PHAssetCollection transientAssetCollectionWithAssets:_selectedAssets.array title:TFPhotoBrowserLocalizedStrings(@"Selected")];
            _collectionPicker.additionalAssetCollections = @[ collection ];
        }
        _collectionPicker.delegate = self;
    }
    
    UINavigationController *navigationController = [coder decodeObjectForKey:@"collectionPickerNavigationController"];
    navigationController.modalPresentationStyle = UIModalPresentationPopover;
    navigationController.popoverPresentationController.sourceView = _collectionButton;
    navigationController.popoverPresentationController.sourceRect = _collectionButton.bounds;
    navigationController.popoverPresentationController.delegate = self;
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    if ([identifierComponents.lastObject isEqual:@"TFCollectionPickerController.NavigationController"]) {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[TFCollectionPickerController alloc] init]];
        navigationController.restorationIdentifier = @"TFCollectionPickerController.NavigationController";
        navigationController.restorationClass = self;
        navigationController.navigationBarHidden = YES;
        
        return navigationController;
    }
    
    return nil;
}


@end
