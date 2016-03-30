//
//  TFCameraViewController.m
//  TFCamera
//
//  Created by Melvin on 7/17/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "TFCameraViewController.h"
#import "TFPhotoViewController.h"
#import "TFMediaViewController.h"
#import "TFCameraSlideUpView.h"
#import "TFCameraSlideDownView.h"
#import "TFTintedButton.h"
#import "TFCameraColor.h"
#import "TFCameraGridView.h"
#import "TFCameraFocusView.h"
#import "TFCameraRecordProgressView.h"
#import <Masonry/Masonry.h>
#import "UIButton+TFCameraButton.h"
#import "PBJVision.h"
#import "PBJVisionUtilities.h"
#import "TFMediaFileModel.h"

const static CGFloat kToolBarHeight    = 50.0f;

const static CGFloat kBottomHeight     = 100.0f;

const static CGFloat kBottomButtonSize = 70.0f;

const static CGFloat kLeftPadding      = 20.0f;

const static CGFloat kButtonPadding    = 64.0f;

const static CGFloat kProgressHeight   = 8.0f;

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f \
blue:(b)/255.0f alpha:1.0f]

@interface TFCameraViewController ()<UIGestureRecognizerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,PBJVisionDelegate>
/**
 *  顶部工具条
 */
@property (nonatomic ,strong) UIView                       *topView;
/**
 *  视频流区域
 */
@property (nonatomic ,strong) UIView                       *captureView;
/**
 *  预览Layer
 */
@property (nonatomic ,strong) AVCaptureVideoPreviewLayer   *previewLayer;
/**
 *  功能按钮条
 */
@property (nonatomic ,strong) UIView                       *actionsView;
/**
 *  底部工具条
 */
@property (nonatomic ,strong) UIView                       *bottomView;
/**
 *  分割线
 */
@property (nonatomic ,strong) UIView                       *separatorView;
/**
 *  关闭按钮
 */
@property (nonatomic ,strong) UIButton                     *closeButton;
/**
 *  下一步按钮
 */
@property (nonatomic ,strong) UIButton                     *nextButton;
/**
 *  网格按钮
 */
@property (nonatomic ,strong) UIButton                     *gridButton;
/**
 *  前后摄像头切换
 */
@property (nonatomic ,strong) UIButton                     *toggleButton;
/**
 *  闪光灯控制
 */
@property (nonatomic ,strong) TFTintedButton               *flashButton;
/**
 *  拍摄按钮
 */
@property (nonatomic ,strong) UIButton                     *shotButton;
/**
 *  相册按钮
 */
@property (nonatomic ,strong) TFTintedButton               *albumButton;
/**
 *  相机类型切换按钮
 */
@property (nonatomic ,strong) UIButton                     *videoButton;
/**
 *  删除已录视频
 */
@property (nonatomic ,strong) UIButton                     *deleteVideoButton;
/**
 *  遮罩上半部分
 */
@property (nonatomic ,strong) TFCameraSlideUpView          *slideUpView;
/**
 *  遮罩下半部分
 */
@property (nonatomic ,strong) TFCameraSlideDownView        *slideDownView;
/**
 *  网格辅助线
 */
@property (nonatomic ,strong) TFCameraGridView             *gridView;
/**
 *  对焦辅助View
 */
@property (nonatomic ,strong) TFCameraFocusView            *focusView;
/**
 *  录像进度条
 */
@property (nonatomic ,strong) TFCameraRecordProgressView   *recordProgressView;
/**
 *  对焦手势
 */
@property (nonatomic ,strong) UITapGestureRecognizer       *focusTapGestureRecognizer;
/**
 *  长按摄像
 */
@property (nonatomic ,strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

@property (nonatomic ,weak  ) IBOutlet NSLayoutConstraint         *topViewHeight;
@property (nonatomic ,weak  ) IBOutlet NSLayoutConstraint         *toggleButtonWidth;


- (void)closeTapped;
- (void)gridTapped;
- (void)flashTapped;
- (void)shotTapped;
- (void)albumTapped;
- (void)toggleTapped;

- (void)deviceOrientationDidChangeNotification;
- (void)latestPhoto;
- (AVCaptureVideoOrientation)videoOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation;
- (void)showSlideViewWithCompletion:(void (^)(void))completion;


@end

@implementation TFCameraViewController {
    BOOL _recording;
    BOOL _maximumLimitReached;
    BOOL _minimumLimitReached;
    __block NSDictionary *_currentVideo;
    CGFloat _maximumTimeLimit;
    CGFloat _minimumTimeLimit;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBCOLOR(23,23,23);
    
    [self.view addSubview:self.topView];
    [self.view addSubview:self.captureView];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.actionsView];
    
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.width.equalTo(self.view).with.offset(0);
        make.height.mas_equalTo(kToolBarHeight);
    }];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.equalTo(self.view).with.offset(0);
        make.height.mas_equalTo(kBottomHeight);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
    [_actionsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.equalTo(self.view).with.offset(0);
        make.height.mas_equalTo(46.0f);
        make.bottom.mas_equalTo(_bottomView.mas_top);
    }];
    [_captureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.equalTo(self.view).with.offset(0);
        make.top.mas_equalTo(_topView.mas_bottom);
        make.bottom.mas_equalTo(_actionsView.mas_top);
    }];

    //
    [_captureView.layer addSublayer:self.previewLayer];
    
    
    //Buttons
    [_topView addSubview:self.closeButton];
    [_topView addSubview:self.nextButton];
    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_topView.mas_centerY);
        make.leading.mas_equalTo(kLeftPadding);
    }];
    [_nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_topView.mas_centerY);
        make.right.equalTo(_topView.mas_right).offset(- kLeftPadding);
    }];
    
    [_actionsView addSubview:self.gridButton];
    [_actionsView addSubview:self.toggleButton];
    [_actionsView addSubview:self.flashButton];
    [_actionsView addSubview:self.recordProgressView];
    
    [_toggleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_actionsView.mas_centerX);
        make.centerY.mas_equalTo(_actionsView.mas_centerY);
    }];
    [_gridButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_actionsView.mas_centerY);
        make.right.equalTo(_toggleButton.mas_left).with.offset(-kButtonPadding);
    }];
    [_flashButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_actionsView.mas_centerY);
        make.left.equalTo(_toggleButton.mas_right).with.offset(kButtonPadding);
    }];
    [_recordProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.width.mas_equalTo(_actionsView.mas_width);
        make.height.mas_equalTo(kProgressHeight);
        make.bottom.equalTo(_actionsView.mas_bottom);
    }];
    
    [_bottomView addSubview:self.albumButton];
    [_bottomView addSubview:self.shotButton];
    [_bottomView addSubview:self.videoButton];
    
    [_shotButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_bottomView.mas_centerX);
        make.centerY.mas_equalTo(_bottomView.mas_centerY);
    }];
    [_albumButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_bottomView.mas_centerY);
        make.right.equalTo(_bottomView.mas_right).offset(- kLeftPadding);
        make.size.mas_equalTo(CGSizeMake(kBottomButtonSize, kBottomButtonSize));
    }];
    [_videoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kLeftPadding);
        make.centerY.mas_equalTo(_bottomView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(kBottomButtonSize, kBottomButtonSize));
    }];
    if (CGRectGetHeight([[UIScreen mainScreen] bounds]) <= 480) {
        _topViewHeight.constant = 0;
    }
    
    if ([[TFCamera getOption:kTFCameraOptionHiddenToggleButton] boolValue] == YES) {
        _toggleButton.hidden = YES;
        _toggleButtonWidth.constant = 0;
    }
    
    if ([[TFCamera getOption:kTFCameraOptionHiddenAlbumButton] boolValue] == YES) {
        _albumButton.hidden = YES;
    }
    
    [_albumButton.layer setCornerRadius:10.f];
    [_albumButton.layer setMasksToBounds:YES];
    
    _captureView.backgroundColor = [UIColor clearColor];
    
    [self setupCamera];
  
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChangeNotification)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    _separatorView.hidden = NO;
    _actionsView.hidden = YES;
    _topView.hidden = YES;
    
    
    _gridButton.enabled =
    _toggleButton.enabled =
    _videoButton.enabled =
    _shotButton.enabled =
    _albumButton.enabled =
    _flashButton.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self deviceOrientationDidChangeNotification];
    
    [[PBJVision sharedInstance] startPreview];

    
    _separatorView.hidden = YES;
    
    [TFCameraSlideView hideSlideUpView:self.slideUpView
                         slideDownView:self.slideDownView
                                atView:_captureView
                            completion:^
     {
         
         _actionsView.hidden = NO;
         _topView.hidden = NO;
         
         _gridButton.enabled =
         _toggleButton.enabled =
         _videoButton.enabled =
         _shotButton.enabled =
         _albumButton.enabled =
         _flashButton.enabled = YES;
     }];
    // get the latest image from the album
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status != ALAuthorizationStatusDenied) {
        // access to album is authorised
        [self latestPhoto];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[PBJVision sharedInstance] stopPreview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)dealloc {
    _captureView                         = nil;
    _previewLayer                        = nil;
    _separatorView                       = nil;
    _actionsView                         = nil;
    _gridButton                          = nil;
    _toggleButton                        = nil;
    _shotButton                          = nil;
    _albumButton                         = nil;
    _flashButton                         = nil;
    _slideUpView                         = nil;
    _slideDownView                       = nil;
    _focusTapGestureRecognizer.delegate  = nil;
    _focusTapGestureRecognizer           = nil;
    _longPressGestureRecognizer.delegate = nil;
    _longPressGestureRecognizer          = nil;
}

#pragma mark -
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *photo = [TFAlbum imageWithMediaInfo:info];
    
    TFPhotoViewController *viewController = [TFPhotoViewController newWithDelegate:_delegate photo:photo];
    [viewController setAlbumPhoto:YES];
    [self.navigationController pushViewController:viewController animated:NO];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - Actions

- (void)setupCamera {
    PBJVision *vision        = [PBJVision sharedInstance];
    vision.delegate          = self;
    vision.cameraMode        = PBJCameraModePhoto;
    vision.flashMode         = PBJFlashModeOff;
    vision.cameraOrientation = PBJCameraOrientationPortrait;
    vision.focusMode         = PBJFocusModeContinuousAutoFocus;
    vision.outputFormat      = PBJOutputFormatPreset;

    //录像时间设定
    _maximumTimeLimit    = 10;
    _minimumTimeLimit    = 3;
}
- (void)closeTapped {
    if ([_delegate respondsToSelector:@selector(cameraDidCancel)]) {
        [_delegate cameraDidCancel];
    }
}

- (void)gridTapped {
    [TFCameraGridView disPlayGridView:self.gridView];
}

- (void)flashTapped
{
    PBJVision *vision = [PBJVision sharedInstance];
    PBJFlashMode mode = PBJFlashModeAuto;
    switch ([vision flashMode]) {
        case PBJFlashModeAuto:
            mode = PBJFlashModeOn;
            break;
            
        case PBJFlashModeOn:
            mode = PBJFlashModeOff;
            break;
            
        case PBJFlashModeOff:
            mode = PBJFlashModeAuto;
            break;
    }
    
    [[PBJVision sharedInstance] setFlashMode:mode];
    UIImage *image = UIImageFromAVCaptureFlashMode2(mode);
    UIColor *tintColor = TintColorFromAVCaptureFlashMode2(mode);
    _flashButton.enabled = [[PBJVision sharedInstance] isFlashAvailable];
    
    [_flashButton setCustomTintColorOverride:tintColor];
    [_flashButton setImage:image forState:UIControlStateNormal];
    
}



- (void)shotTapped {
    if ([[PBJVision sharedInstance] cameraMode] != PBJCameraModePhoto) {
        return;
    }
    
    _videoButton.enabled =
    _shotButton.enabled =
    _albumButton.enabled = NO;
    
    [self showSlideViewWithCompletion:^{
        [[PBJVision sharedInstance] capturePhoto];
    }];
    
}

- (void)albumTapped {
    _videoButton.enabled =
    _shotButton.enabled =
    _albumButton.enabled = NO;
    
    [self showSlideViewWithCompletion:^{
        UIImagePickerController *pickerController = [TFAlbum imagePickerControllerWithDelegate:self];
        [self presentViewController:pickerController animated:YES completion:nil];
    }];
}

- (void)toggleTapped {
    PBJVision *vision = [PBJVision sharedInstance];
    vision.cameraDevice = vision.cameraDevice == PBJCameraDeviceBack ? PBJCameraDeviceFront : PBJCameraDeviceBack;
}

- (void)videoTapped {
    //
    PBJCameraMode cameraMode = PBJCameraModePhoto;
    if ([[PBJVision sharedInstance] cameraMode] == cameraMode) {
        cameraMode = PBJCameraModeVideo;
    }
    [self showSlideViewWithCompletion:^{
        [UIView animateWithDuration:.35
                              delay:0
                            options:UIViewAnimationOptionTransitionFlipFromBottom
                         animations:^{
                             _bottomView.frame = _bottomView.frame;
        } completion:^(BOOL finished) {
            
        }];
        [[PBJVision sharedInstance] setCameraMode:cameraMode];
    }];
}

- (void)deleteVideoTapped {
    
}

- (void)nextTapped {
    
}

#pragma mark - UIGestureRecognizer

- (void)handleFocusTapGesterRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint tapPoint = [gestureRecognizer locationInView:_captureView];
    
    // auto focus is occuring, display focus view
    self.focusView.center = tapPoint;
    
    [_captureView addSubview:self.focusView];
    
    [self.focusView startAnimation];
    
    CGPoint adjustPoint = [PBJVisionUtilities convertToPointOfInterestFromViewCoordinates:tapPoint
                                                                                  inFrame:_captureView.frame];
    [[PBJVision sharedInstance] focusExposeAndAdjustWhiteBalanceAtAdjustedPoint:adjustPoint];
}

- (void)handleLongPressGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            if ([[PBJVision sharedInstance] cameraMode] == PBJCameraModePhoto) {
                //当前拍照模式
                [self shotTapped];
            }
            else {
                _shotButton.enabled = NO;
                if (!_recording) {
                    [self _startCapture];
                }
                else {
                    [self _resumeCapture];
                }
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            [self _pauseCapture];
            _shotButton.enabled = YES;
            break;
        }
        default:
            break;
    }
}




#pragma mark -
#pragma mark - Views

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = RGBCOLOR(23,23,23);
        _topView.layer.borderWidth = 1;
    }
    return _topView;
}

- (UIView *)captureView {
    if (!_captureView) {
        _captureView = [[UIView alloc] init];
        _captureView.contentMode = UIViewContentModeScaleToFill;
        _captureView.userInteractionEnabled = YES;
        _captureView.multipleTouchEnabled = YES;
        
        _focusTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFocusTapGesterRecognizer:)];
        _focusTapGestureRecognizer.delegate = self;
        _focusTapGestureRecognizer.numberOfTapsRequired = 1;
        [_captureView addGestureRecognizer:_focusTapGestureRecognizer];
    }
    return _captureView;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [[PBJVision sharedInstance] previewLayer];
        _previewLayer.frame = _captureView.bounds;
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

- (UIView *)actionsView {
    if (!_actionsView) {
        _actionsView = [[UIView alloc] init];
        _actionsView.backgroundColor = RGBCOLOR(23,23,23);
        _actionsView.userInteractionEnabled = YES;
    }
    return _actionsView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = RGBCOLOR(16,16,16);
        _bottomView.userInteractionEnabled = YES;
    }
    return _bottomView;
}

- (TFCameraSlideUpView *)slideUpView {
    if (!_slideUpView) {
        _slideUpView = [[TFCameraSlideUpView alloc] init];
        _slideUpView.backgroundColor = RGBCOLOR(23,23,23);
    }
    return _slideUpView;
}

- (UIView *)separatorView {
    if (!_separatorView) {
        _separatorView = [[UIView alloc] init];
    }
    return _separatorView;
}

- (TFCameraSlideDownView *)slideDownView {
    if (!_slideDownView) {
        _slideDownView = [[TFCameraSlideDownView alloc] init];
        _slideDownView.backgroundColor = RGBCOLOR(23,23,23);
    }
    return _slideDownView;
}

- (TFCameraGridView *)gridView {
    if (_gridView == nil) {
        _gridView = [[TFCameraGridView alloc] initWithFrame:_previewLayer.bounds];
        _gridView.numberOfColumns = 2;
        _gridView.numberOfRows = 2;
        _gridView.alpha = 0;
        [_captureView addSubview:_gridView];
    }
    return _gridView;
}


- (TFCameraFocusView *)focusView {
    if (!_focusView) {
        _focusView = [[TFCameraFocusView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    }
    return _focusView;
}

- (TFCameraRecordProgressView *)recordProgressView {
    if (!_recordProgressView) {
        _recordProgressView = [[TFCameraRecordProgressView alloc] initWithFrame:CGRectZero];
        _recordProgressView.backgroundColor = RGBCOLOR(16,16,16);
        _recordProgressView.hidden = YES;
    }
    return _recordProgressView;
}

#pragma mark - Buttons

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton tfcCreateButtonWithImage:@"CameraClose.png"
                                             imagePressed:@"CameraClose.png"
                                                   target:self
                                                 selector:@selector(closeTapped)];
        _closeButton.showsTouchWhenHighlighted = YES;
    }
    return _closeButton;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [UIButton tfcCreateButtonWithTitle:@"下一步"
                                                  target:self
                                                selector:@selector(nextTapped)];
        _nextButton.tintColor = [TFCameraColor tintColor];
        _nextButton.hidden = YES;
        _nextButton.enabled = NO;
    }
    return _nextButton;
}

- (UIButton *)gridButton {
    if (!_gridButton) {
        _gridButton = [UIButton tfcCreateButtonWithImage:@"CameraGrid.png"
                                            imagePressed:@"CameraGrid.png"
                                                  target:self
                                                selector:@selector(gridTapped)];
        _gridButton.showsTouchWhenHighlighted = YES;
    }
    return _gridButton;
}

- (UIButton *)toggleButton {
    if (!_toggleButton) {
        _toggleButton = [UIButton tfcCreateButtonWithImage:@"CameraToggle.png"
                                              imagePressed:@"CameraToggle.png"
                                                    target:self
                                                  selector:@selector(toggleTapped)];
        _toggleButton.showsTouchWhenHighlighted = YES;
    }
    return _toggleButton;
}

- (TFTintedButton *)flashButton {
    if (!_flashButton) {
        _flashButton = [TFTintedButton buttonWithType:UIButtonTypeCustom];
        [_flashButton setImage:[UIImage imageNamed:@"CameraFlashOff.png"]
                      forState:UIControlStateNormal];
        [_flashButton addTarget:self
                         action:@selector(flashTapped)
               forControlEvents:UIControlEventTouchUpInside];
        [_flashButton setCustomTintColorOverride:[UIColor grayColor]];
        _flashButton.showsTouchWhenHighlighted = YES;

    }
    return _flashButton;
}

- (UIButton *)shotButton {
    if (!_shotButton) {
        _shotButton = [UIButton tfcCreateButtonWithImage:@"CameraShot.png"
                                            imagePressed:@"CameraShot.png"
                                                  target:self
                                                selector:@selector(shotTapped)];
        // touch to record
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleLongPressGestureRecognizer:)];
        _longPressGestureRecognizer.delegate             = self;
        _longPressGestureRecognizer.minimumPressDuration = 0.5f;
        _longPressGestureRecognizer.allowableMovement    = 10.0f;
        [_shotButton addGestureRecognizer:_longPressGestureRecognizer];
    }
    return _shotButton;
}

- (TFTintedButton *)albumButton {
    if (!_albumButton) {
        _albumButton = [TFTintedButton buttonWithType:UIButtonTypeCustom];
        [_albumButton setImage:[UIImage imageNamed:@"CameraRoll.png"] forState:UIControlStateNormal];
        [_albumButton addTarget:self action:@selector(albumTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _albumButton;
}

- (UIButton *)videoButton {
    if (!_videoButton) {
        _videoButton = [UIButton tfcCreateButtonWithImage:@"CameraHandleVideo.png"
                                             imagePressed:@"CameraHandleVideo.png"
                                                   target:self
                                                 selector:@selector(videoTapped)];
    }
    return _videoButton;
}

- (UIButton *)deleteVideoButton {
    if (!_deleteVideoButton) {
        _deleteVideoButton = [UIButton tfcCreateButtonWithImage:@"CameraHandleVideo.png"
                                                   imagePressed:@"CameraHandleVideo.png"
                                                         target:self
                                                       selector:@selector(deleteVideoTapped)];
    }
    return _deleteVideoButton;
}

#pragma mark - Private methods

- (void)deviceOrientationDidChangeNotification
{
    UIDeviceOrientation orientation = [UIDevice.currentDevice orientation];
    NSInteger degress;
    
    switch (orientation) {
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationUnknown:
            degress = 0;
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            degress = 90;
            break;
            
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationPortraitUpsideDown:
            degress = 180;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            degress = 270;
            break;
    }
    
    CGFloat radians = degress * M_PI / 180;
    CGAffineTransform transform = CGAffineTransformMakeRotation(radians);
    
    [UIView animateWithDuration:.5f animations:^{
        _gridButton.transform =
        _toggleButton.transform =
        _albumButton.transform =
        _flashButton.transform = transform;
    }];
}

-(void)latestPhoto {
    TFAssetsLibrary *library = [TFAssetsLibrary defaultAssetsLibrary];
    __weak __typeof(self)wSelf = self;
    [library latestPhotoWithCompletion:^(UIImage *photo) {
        wSelf.albumButton.disableTint = YES;
        [wSelf.albumButton setImage:photo forState:UIControlStateNormal];
    }];
}

- (AVCaptureVideoOrientation)videoOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation) deviceOrientation;
    
    switch (deviceOrientation) {
        case UIDeviceOrientationLandscapeLeft:
            result = AVCaptureVideoOrientationLandscapeRight;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            result = AVCaptureVideoOrientationLandscapeLeft;
            break;
            
        default:
            break;
    }
    
    return result;
}


- (void)hiddenSlideViewWithCompletion:(void (^)(void))completion {
    
    [TFCameraSlideView hideSlideUpView:self.slideUpView
                         slideDownView:self.slideDownView
                                atView:_captureView
                            completion:^
     {
         _actionsView.hidden = NO;
         _topView.hidden = NO;
         if ([[PBJVision sharedInstance] cameraMode] == PBJCameraModePhoto) {
             //拍照模式
             _gridButton.hidden =
             _flashButton.hidden = NO;
             _recordProgressView.hidden = YES;
             _nextButton.hidden = YES;
             [_videoButton tfcUpdateButtonImage:@"CameraHandleVideo.png"
                                   imagePressed:@"CameraHandleVideo.png"];
         }
         else {
             //视频模式
             _gridButton.hidden =
             _flashButton.hidden = YES;
             _recordProgressView.hidden = NO;
             _nextButton.hidden = NO;
             [_videoButton tfcUpdateButtonImage:@"CameraHandlePhoto.png"
                                   imagePressed:@"CameraHandlePhoto.png"];
         }
         completion();
     }];
}

- (void)showSlideViewWithCompletion:(void (^)(void))completion {
    _actionsView.hidden = YES;
    _topView.hidden = YES;
    
    [TFCameraSlideView showSlideUpView:self.slideUpView
                         slideDownView:self.slideDownView
                                atView:_captureView
                            completion:^{
                                completion();
                            }];
}

#pragma mark - private start/stop helper methods

- (void)_startCapture {
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [[PBJVision sharedInstance] startVideoCapture];
}

- (void)_pauseCapture {
    [[PBJVision sharedInstance] pauseVideoCapture];
}

- (void)_resumeCapture {
    [[PBJVision sharedInstance] resumeVideoCapture];
//    _effectsViewController.view.hidden = YES;
}

- (void)_endCapture
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[PBJVision sharedInstance] endVideoCapture];
}

- (void)_resetCapture
{
    _longPressGestureRecognizer.enabled = YES;
    
    PBJVision *vision = [PBJVision sharedInstance];
    vision.delegate = self;
    
    if ([vision isCameraDeviceAvailable:PBJCameraDeviceBack]) {
        vision.cameraDevice = PBJCameraDeviceBack;
//        _flipButton.hidden = NO;
    } else {
        vision.cameraDevice = PBJCameraDeviceFront;
//        _flipButton.hidden = YES;
    }
    
    vision.cameraOrientation = PBJCameraOrientationPortrait;
    vision.focusMode = PBJFocusModeContinuousAutoFocus;
    vision.outputFormat = PBJOutputFormatPreset;
    vision.videoRenderingEnabled = YES;
    
    // specify a maximum duration with the following property
     vision.maximumCaptureDuration = CMTimeMakeWithSeconds(_maximumTimeLimit, 600); // ~ 5 seconds
}



#pragma mark - PBJVisionDelegate

// session

- (void)visionSessionWillStart:(PBJVision *)vision {
    
}

- (void)visionSessionDidStart:(PBJVision *)vision {
    _previewLayer.frame = _captureView.bounds;
    NSLog(@"visionSessionDidStart");
}

- (void)visionSessionDidStop:(PBJVision *)vision {
    NSLog(@"%s",__func__);
}

- (void)visionSessionDidStartPreview:(PBJVision *)vision {
    NSLog(@"%s",__func__);
}
- (void)visionSessionDidStopPreview:(PBJVision *)vision {
    NSLog(@"%s",__func__);
}
- (void)visionCameraDeviceWillChange:(PBJVision *)vision {
    NSLog(@"%s",__func__);
}
- (void)visionCameraDeviceDidChange:(PBJVision *)vision {
    NSLog(@"%s",__func__);
}

- (void)visionCameraModeWillChange:(PBJVision *)vision {
    _videoButton.enabled =
    _shotButton.enabled =
    _albumButton.enabled = NO;
}
- (void)visionCameraModeDidChange:(PBJVision *)vision {
    [self hiddenSlideViewWithCompletion:^{
        _videoButton.enabled =
        _shotButton.enabled =
        _albumButton.enabled = YES;
    }];
}


- (void)visionWillCapturePhoto:(PBJVision *)vision {
    
}
- (void)visionDidCapturePhoto:(PBJVision *)vision {
    
}
- (void)vision:(PBJVision *)vision capturedPhoto:(nullable NSDictionary *)photoDict error:(nullable NSError *)error {
    
    TFMediaFileModel *mediaFile = [[TFMediaFileModel alloc] init];
    mediaFile.fileType = TFMediaFileTypePhoto;
    mediaFile.image = [photoDict objectForKey:PBJVisionPhotoImageKey];
    TFMediaViewController *viewController = [TFMediaViewController newWithDelegate:_delegate
                                                                         mediaFile:mediaFile];
    [self.navigationController pushViewController:viewController animated:YES];
}

// focus / exposure

- (void)visionWillStartFocus:(PBJVision *)vision
{
}

- (void)visionDidStopFocus:(PBJVision *)vision
{
    if (_focusView && [_focusView superview]) {
        [_focusView stopAnimation];
    }
}

- (void)visionWillChangeExposure:(PBJVision *)vision
{
}

- (void)visionDidChangeExposure:(PBJVision *)vision
{
    if (_focusView && [_focusView superview]) {
        [_focusView stopAnimation];
    }
}

// video capture

- (void)visionDidStartVideoCapture:(PBJVision *)vision
{
    _recording = YES;
    [_recordProgressView startRecord];
}

- (void)visionDidPauseVideoCapture:(PBJVision *)vision
{
    [_recordProgressView stopRecord];
}

- (void)visionDidResumeVideoCapture:(PBJVision *)vision {
    [_recordProgressView startRecord];
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error
{
    _recording = NO;
    
    if (error && [error.domain isEqual:PBJVisionErrorDomain] && error.code == PBJVisionErrorCancelled) {
        NSLog(@"recording session cancelled");
        return;
    } else if (error) {
        NSLog(@"encounted an error in video capture (%@)", error);
        return;
    }
    [_recordProgressView setProgressWidth:CGRectGetWidth(_recordProgressView.frame)];
    _currentVideo = videoDict;
    NSString *videoPath = [_currentVideo  objectForKey:PBJVisionVideoPathKey];
    NSLog(@"videoPath:%@",videoPath);
}

// progress

- (void)vision:(PBJVision *)vision didCaptureVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
//    NSLog(@"captured audio (%f) seconds", vision.capturedAudioSeconds);
    [self updateProgress:vision.capturedVideoSeconds];
}

- (void)vision:(PBJVision *)vision didCaptureAudioSample:(CMSampleBufferRef)sampleBuffer
{
//    NSLog(@"captured video (%f) seconds", vision.capturedVideoSeconds);
}


- (void)updateProgress:(Float64)capturedVideoSeconds {
    CGFloat increment = self.view.frame.size.width/_maximumTimeLimit;
    if (capturedVideoSeconds <= _maximumTimeLimit) {
        [_recordProgressView setProgressWidth:ceil(increment * capturedVideoSeconds)];
    }
    else {
        [self _endCapture];
    }
}


#pragma mark -
#pragma mark - Flash Button methods

UIImage *UIImageFromAVCaptureFlashMode2(PBJFlashMode mode)
{
    NSArray *array = @[@"CameraFlashOff", @"CameraFlashOn", @"CameraFlashAuto"];
    NSString *imageName = [array objectAtIndex:mode];
    return [UIImage imageNamed:imageName];
}

UIColor *TintColorFromAVCaptureFlashMode2(PBJFlashMode mode)
{
    NSArray *array = @[[UIColor grayColor], [TFCameraColor tintColor], [TFCameraColor tintColor]];
    UIColor *color = [array objectAtIndex:mode];
    return color;
}

@end
