//
//  TFPhotoViewController.m
//  TFCamera
//
//  Created by Melvin on 7/17/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "TFPhotoViewController.h"

#import "TFPhotoViewController.h"
#import "TFAssetsLibrary.h"
#import "TFCameraColor.h"
#import "TFCameraFilterView.h"
#import "UIImage+CameraFilters.h"
#import "TFTintedButton.h"

static NSString* const kTFCacheSatureKey   = @"TFCacheSatureKey";
static NSString* const kTFCacheCurveKey    = @"TFCacheCurveKey";
static NSString* const kTFCacheVignetteKey = @"TFCacheVignetteKey";


@interface TFPhotoViewController ()

@property (nonatomic ,strong) IBOutlet UIImageView        *photoView;
@property (nonatomic ,strong) IBOutlet UIView             *bottomView;
@property (nonatomic ,strong) IBOutlet TFCameraFilterView *filterView;
@property (nonatomic ,strong) IBOutlet UIButton           *defaultFilterButton;
@property (nonatomic ,strong) IBOutlet TFTintedButton     *filterWandButton;
@property (nonatomic ,strong) IBOutlet NSLayoutConstraint *topViewHeight;
@property (nonatomic ,strong) UIView             *detailFilterView;
@property (nonatomic ,strong) UIImage            *photo;
@property (nonatomic ,strong) NSCache            *cachePhoto;

@property (weak) id<TFCameraDelegate> delegate;
@property (nonatomic) BOOL albumPhoto;

- (IBAction)backTapped;
- (IBAction)confirmTapped;
- (IBAction)filtersTapped;

- (IBAction)defaultFilterTapped:(UIButton *)button;
- (IBAction)satureFilterTapped:(UIButton *)button;
- (IBAction)curveFilterTapped:(UIButton *)button;
- (IBAction)vignetteFilterTapped:(UIButton *)button;

- (void)addDetailViewToButton:(UIButton *)button;
+ (instancetype)newController;

@end



@implementation TFPhotoViewController

+ (instancetype)newWithDelegate:(id<TFCameraDelegate>)delegate photo:(UIImage *)photo
{
    TFPhotoViewController *viewController = [TFPhotoViewController newController];
    
    if (viewController) {
        viewController.delegate = delegate;
        viewController.photo = photo;
        viewController.cachePhoto = [[NSCache alloc] init];
    }
    
    return viewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (CGRectGetHeight([[UIScreen mainScreen] bounds]) <= 480) {
        _topViewHeight.constant = 0;
    }
    
    _photoView.clipsToBounds = YES;
    _photoView.image = _photo;
    
    if ([[TFCamera getOption:kTFCameraOptionHiddenFilterButton] boolValue] == YES) {
        _filterWandButton.hidden = YES;
    }
    
    [self addDetailViewToButton:_defaultFilterButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)dealloc
{
    _photoView = nil;
    _bottomView = nil;
    _filterView = nil;
    _defaultFilterButton = nil;
    _detailFilterView = nil;
    _photo = nil;
    _cachePhoto = nil;
}

#pragma mark -
#pragma mark - Controller actions

- (IBAction)backTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmTapped
{
    if ( [_delegate respondsToSelector:@selector(cameraWillTakePhoto)]) {
        [_delegate cameraWillTakePhoto];
    }
    
    if ([_delegate respondsToSelector:@selector(cameraDidTakePhoto:)]) {
        _photo = _photoView.image;
        
        if (_albumPhoto) {
            [_delegate cameraDidSelectAlbumPhoto:_photo];
        } else {
            [_delegate cameraDidTakePhoto:_photo];
        }
        
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        TFAssetsLibrary *library = [TFAssetsLibrary defaultAssetsLibrary];
        
        void (^saveJPGImageAtDocumentDirectory)(UIImage *) = ^(UIImage *photo) {
            [library saveJPGImageAtDocumentDirectory:_photo resultBlock:^(NSURL *assetURL) {
                [_delegate cameraDidSavePhotoAtPath:assetURL];
            } failureBlock:^(NSError *error) {
                if ([_delegate respondsToSelector:@selector(cameraDidSavePhotoWithError:)]) {
                    [_delegate cameraDidSavePhotoWithError:error];
                }
            }];
        };
        
        if ([[TFCamera getOption:kTFCameraOptionSaveImageToAlbum] boolValue] && status != ALAuthorizationStatusDenied) {
            [library saveImage:_photo resultBlock:^(NSURL *assetURL) {
                if ([_delegate respondsToSelector:@selector(cameraDidSavePhotoAtPath:)]) {
                    [_delegate cameraDidSavePhotoAtPath:assetURL];
                }
            } failureBlock:^(NSError *error) {
                saveJPGImageAtDocumentDirectory(_photo);
            }];
        } else {
            if ([_delegate respondsToSelector:@selector(cameraDidSavePhotoAtPath:)]) {
                saveJPGImageAtDocumentDirectory(_photo);
            }
        }
    }
}

- (IBAction)filtersTapped
{
    if ([_filterView isDescendantOfView:self.view]) {
        [_filterView removeFromSuperviewAnimated];
    } else {
        [_filterView addToView:self.view aboveView:_bottomView];
        [self.view sendSubviewToBack:_filterView];
        [self.view sendSubviewToBack:_photoView];
    }
}

#pragma mark -
#pragma mark - Filter view actions

- (IBAction)defaultFilterTapped:(UIButton *)button
{
    [self addDetailViewToButton:button];
    _photoView.image = _photo;
}

- (IBAction)satureFilterTapped:(UIButton *)button
{
    [self addDetailViewToButton:button];
    
    if ([_cachePhoto objectForKey:kTFCacheSatureKey]) {
        _photoView.image = [_cachePhoto objectForKey:kTFCacheSatureKey];
    } else {
        [_cachePhoto setObject:[_photo saturateImage:1.8 withContrast:1] forKey:kTFCacheSatureKey];
        _photoView.image = [_cachePhoto objectForKey:kTFCacheSatureKey];
    }
    
}

- (IBAction)curveFilterTapped:(UIButton *)button
{
    [self addDetailViewToButton:button];
    
    if ([_cachePhoto objectForKey:kTFCacheCurveKey]) {
        _photoView.image = [_cachePhoto objectForKey:kTFCacheCurveKey];
    } else {
        [_cachePhoto setObject:[_photo curveFilter] forKey:kTFCacheCurveKey];
        _photoView.image = [_cachePhoto objectForKey:kTFCacheCurveKey];
    }
}

- (IBAction)vignetteFilterTapped:(UIButton *)button
{
    [self addDetailViewToButton:button];
    
    if ([_cachePhoto objectForKey:kTFCacheVignetteKey]) {
        _photoView.image = [_cachePhoto objectForKey:kTFCacheVignetteKey];
    } else {
        [_cachePhoto setObject:[_photo vignetteWithRadius:0 intensity:6] forKey:kTFCacheVignetteKey];
        _photoView.image = [_cachePhoto objectForKey:kTFCacheVignetteKey];
    }
}


#pragma mark -
#pragma mark - Private methods

- (void)addDetailViewToButton:(UIButton *)button
{
    [_detailFilterView removeFromSuperview];
    
    CGFloat height = 2.5;
    
    CGRect frame = button.frame;
    frame.size.height = height;
    frame.origin.x = 0;
    frame.origin.y = CGRectGetMaxY(button.frame) - height;
    
    _detailFilterView = [[UIView alloc] initWithFrame:frame];
    _detailFilterView.backgroundColor = [TFCameraColor tintColor];
    _detailFilterView.userInteractionEnabled = NO;
    
    [button addSubview:_detailFilterView];
}

+ (instancetype)newController
{
    return [super new];
}

@end
