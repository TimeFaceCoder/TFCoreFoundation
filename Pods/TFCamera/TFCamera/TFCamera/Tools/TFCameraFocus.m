//
//  TFCameraFocus.m
//  TFCamera
//
//  Created by Melvin on 7/16/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "TFCameraFocus.h"
#import "TFCameraFocusView.h"

@interface TFCameraFocus ()

+ (CGPoint)pointOfInterestWithTouchPoint:(CGPoint)touchPoint;
+ (void)showFocusView:(UIView *)focusView withTouchPoint:(CGPoint)touchPoint andDevice:(AVCaptureDevice *)device;

@end

@implementation TFCameraFocus

#pragma mark -
#pragma mark - Public methods

+ (void)focusWithCaptureSession:(AVCaptureSession *)session touchPoint:(CGPoint)touchPoint inFocusView:(UIView *)focusView
{
    AVCaptureDevice *device = [session.inputs.lastObject device];
    
    [self showFocusView:focusView withTouchPoint:touchPoint andDevice:device];
    
    if ([device lockForConfiguration:nil]) {
        CGPoint pointOfInterest = [self pointOfInterestWithTouchPoint:touchPoint];
        
        if (device.focusPointOfInterestSupported) {
            device.focusPointOfInterest = pointOfInterest;
        }
        
        if (device.exposurePointOfInterestSupported) {
            device.exposurePointOfInterest = pointOfInterest;
        }
        
        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
        
        if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        }
        
        [device unlockForConfiguration];
    }
}

#pragma mark -
#pragma mark - Private methods

+ (CGPoint)pointOfInterestWithTouchPoint:(CGPoint)touchPoint
{
    CGSize screenSize = [UIScreen.mainScreen bounds].size;
    
    CGPoint pointOfInterest;
    pointOfInterest.x = touchPoint.x / screenSize.width;
    pointOfInterest.y = touchPoint.y / screenSize.height;
    
    return pointOfInterest;
}

+ (void)showFocusView:(UIView *)focusView withTouchPoint:(CGPoint)touchPoint andDevice:(AVCaptureDevice *)device
{
    
    //
    // add focus view animated
    //
    TFCameraFocusView *cameraFocusView = [[TFCameraFocusView alloc] init];
    cameraFocusView.center = touchPoint;
    [focusView addSubview:cameraFocusView];
    [cameraFocusView startAnimation];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [NSThread sleepForTimeInterval:.5f];
        
        while ([device isAdjustingFocus] ||
               [device isAdjustingExposure] ||
               [device isAdjustingWhiteBalance]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //
            // remove focus view and focus subview animated
            //
            [cameraFocusView stopAnimation];
        });
    });
}

@end
