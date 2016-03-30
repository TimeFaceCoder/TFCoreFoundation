//
//  TFCamera.h
//  TFCamera
//
//  Created by Melvin on 7/16/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

@import Foundation;
@import AVFoundation;
@import UIKit;
#import "TFCameraProtocol.h"
#define kTFCameraOptionHiddenToggleButton @"TFCameraOptionHiddenToggleButton"
#define kTFCameraOptionHiddenAlbumButton  @"TFCameraOptionHiddenAlbumButton"
#define kTFCameraOptionHiddenFilterButton @"TFCameraOptionHiddenFilterButton"
#define kTFCameraOptionSaveImageToAlbum   @"TFCameraOptionSaveImageToAlbum"

@protocol TFCameraDelegate;


@interface TFCamera : NSObject

+ (instancetype)new __attribute__
((unavailable("[+new] is not allowed, use [+cameraWithRootView:andCaptureView:]")));

- (instancetype) init __attribute__
((unavailable("[-init] is not allowed, use [+cameraWithRootView:andCaptureView:]")));

+ (instancetype)cameraWithFlashButton:(UIButton *)flashButton;
+ (instancetype)cameraWithFlashButton:(UIButton *)flashButton devicePosition:(AVCaptureDevicePosition)devicePosition;

+ (void)setOption:(NSString*)option value:(id)value;
+ (id)getOption:(NSString*)option;

- (void)startRunning;
- (void)stopRunning;

- (AVCaptureVideoPreviewLayer *)previewLayer;
- (AVCaptureStillImageOutput *)stillImageOutput;

- (void)insertSublayerWithCaptureView:(UIView *)captureView atRootView:(UIView *)rootView;

- (void)disPlayGridView;

- (void)changeFlashModeWithButton:(UIButton *)button;

- (void)focusView:(UIView *)focusView inTouchPoint:(CGPoint)touchPoint;

- (void)takePhotoWithCaptureView:(UIView *)captureView
                videoOrientation:(AVCaptureVideoOrientation)videoOrientation
                        cropSize:(CGSize)cropSize
                      completion:(void (^)(UIImage *))completion;

- (void)toogleWithFlashButton:(UIButton *)flashButton;



@end


