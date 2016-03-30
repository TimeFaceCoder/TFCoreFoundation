//
//  TFCamera.m
//  TFCamera
//
//  Created by Melvin on 7/16/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "TFCamera.h"
#import "TFCameraGridView.h"
#import "TFCameraFlash.h"
#import "TFCameraFocus.h"
#import "TFCameraShot.h"
#import "TFCameraToggle.h"


NSMutableDictionary *optionDictionary;



@interface TFCamera ()

@property (nonatomic ,strong) AVCaptureSession           *session;
@property (nonatomic ,strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic ,strong) AVCaptureStillImageOutput  *stillImageOutput;
@property (nonatomic ,strong) TFCameraGridView           *gridView;

+ (instancetype)newCamera;
+ (void)initOptions;

- (void)setupWithFlashButton:(UIButton *)flashButton;

@end

@implementation TFCamera

+ (instancetype)cameraWithFlashButton:(UIButton *)flashButton
{
    TFCamera *camera = [TFCamera newCamera];
    [camera setupWithFlashButton:flashButton];
    
    return camera;
}

+ (instancetype)cameraWithFlashButton:(UIButton *)flashButton devicePosition:(AVCaptureDevicePosition)devicePosition
{
    TFCamera *camera = [TFCamera newCamera];
    [camera setupWithFlashButton:flashButton devicePosition:devicePosition];
    
    return camera;
}


+ (void)setOption:(NSString *)option value:(id)value
{
    if (optionDictionary == nil) {
        [TFCamera initOptions];
    }
    
    if (option != nil && value != nil) {
        optionDictionary[option] = value;
    }
}

+ (id)getOption:(NSString *)option
{
    if (optionDictionary == nil) {
        [TFCamera initOptions];
    }
    
    if (option != nil) {
        return optionDictionary[option];
    }
    
    return nil;
}

- (void)dealloc
{
    _session = nil;
    _previewLayer = nil;
    _stillImageOutput = nil;
    _gridView = nil;
}

#pragma mark -
#pragma mark - Public methods

- (void)startRunning
{
    [_session startRunning];
}

- (void)stopRunning
{
    [_session stopRunning];
}

- (void)insertSublayerWithCaptureView:(UIView *)captureView atRootView:(UIView *)rootView
{
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    CALayer *rootLayer = [rootView layer];
    rootLayer.masksToBounds = YES;
    
    CGRect frame = captureView.frame;
    _previewLayer.frame = frame;
    
    [rootLayer insertSublayer:_previewLayer atIndex:0];
    
    NSInteger index = [captureView.subviews count]-1;
    [captureView insertSubview:self.gridView atIndex:index];
}

- (void)disPlayGridView {
    [TFCameraGridView disPlayGridView:self.gridView];
}

- (void)changeFlashModeWithButton:(UIButton *)button
{
    [TFCameraFlash changeModeWithCaptureSession:_session andButton:button];
}

- (void)focusView:(UIView *)focusView inTouchPoint:(CGPoint)touchPoint
{
    [TFCameraFocus focusWithCaptureSession:_session touchPoint:touchPoint inFocusView:focusView];
}

- (void)takePhotoWithCaptureView:(UIView *)captureView videoOrientation:(AVCaptureVideoOrientation)videoOrientation cropSize:(CGSize)cropSize completion:(void (^)(UIImage *))completion
{
    [TFCameraShot takePhotoCaptureView:captureView
                      stillImageOutput:_stillImageOutput
                      videoOrientation:videoOrientation
                              cropSize:cropSize
                            completion:^(UIImage *photo) {
                                completion(photo);
                            }];
}

- (void)toogleWithFlashButton:(UIButton *)flashButton
{
    [TFCameraToggle toogleWithCaptureSession:_session];
    [TFCameraFlash flashModeWithCaptureSession:_session andButton:flashButton];
}

#pragma mark -
#pragma mark - Private methods

+ (instancetype)newCamera
{
    return [super new];
}

- (TFCameraGridView *)gridView
{
    if (_gridView == nil) {
        CGRect frame = _previewLayer.frame;
        frame.origin.x = frame.origin.y = 0;
        
        _gridView = [[TFCameraGridView alloc] initWithFrame:frame];
        _gridView.numberOfColumns = 2;
        _gridView.numberOfRows = 2;
        _gridView.alpha = 0;
    }
    
    return _gridView;
}

- (void)setupWithFlashButton:(UIButton *)flashButton
{
    //
    // create session
    //
    
    _session = [AVCaptureSession new];
    _session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    //
    // setup device
    //
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device lockForConfiguration:nil]) {
        if (device.autoFocusRangeRestrictionSupported) {
            device.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionNear;
        }
        
        if (device.smoothAutoFocusSupported) {
            device.smoothAutoFocusEnabled = YES;
        }
        
        if([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]){
            device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
        
        device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        
        [device unlockForConfiguration];
    }
    
    //
    // add device input to session
    //
    
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (!deviceInput) {
        return;
    }
    [_session addInput:deviceInput];
    
    //
    // add output to session
    //
    
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    
    _stillImageOutput = [AVCaptureStillImageOutput new];
    _stillImageOutput.outputSettings = outputSettings;
    
    [_session addOutput:_stillImageOutput];
    
    //
    // setup flash button
    //
    
    [TFCameraFlash flashModeWithCaptureSession:_session andButton:flashButton];
}

- (void)setupWithFlashButton:(UIButton *)flashButton devicePosition:(AVCaptureDevicePosition)devicePosition
{
    //
    // create session
    //
    
    _session = [AVCaptureSession new];
    _session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    //
    // setup device
    //
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *device;
    for (AVCaptureDevice *aDevice in devices) {
        if (aDevice.position == devicePosition) {
            device = aDevice;
        }
    }
    if (!device) {
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    if ([device lockForConfiguration:nil]) {
        if (device.autoFocusRangeRestrictionSupported) {
            device.autoFocusRangeRestriction = AVCaptureAutoFocusRangeRestrictionNear;
        }
        
        if (device.smoothAutoFocusSupported) {
            device.smoothAutoFocusEnabled = YES;
        }
        
        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
        
        device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        
        [device unlockForConfiguration];
    }
    
    //
    // add device input to session
    //
    
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    [_session addInput:deviceInput];
    
    //
    // add output to session
    //
    
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    
    _stillImageOutput = [AVCaptureStillImageOutput new];
    _stillImageOutput.outputSettings = outputSettings;
    
    [_session addOutput:_stillImageOutput];
    
    //
    // setup flash button
    //
    
    [TFCameraFlash flashModeWithCaptureSession:_session andButton:flashButton];
}

+ (void)initOptions
{
    optionDictionary = [NSMutableDictionary dictionary];
}

@end
