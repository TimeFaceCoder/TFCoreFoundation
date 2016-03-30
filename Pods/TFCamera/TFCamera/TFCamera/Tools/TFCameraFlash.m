//
//  TFCameraFlash.m
//  TFCamera
//
//  Created by Melvin on 7/16/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "TFCameraFlash.h"
#import "TFCameraColor.h"
#import "TFTintedButton.h"

@implementation TFCameraFlash

#pragma mark -
#pragma mark - Public methods

+ (void)changeModeWithCaptureSession:(AVCaptureSession *)session andButton:(UIButton *)button
{
    AVCaptureDevice *device = [session.inputs.lastObject device];
    AVCaptureFlashMode mode = [device flashMode];
    
    [device lockForConfiguration:nil];
    
    switch ([device flashMode]) {
        case AVCaptureFlashModeAuto:
            mode = AVCaptureFlashModeOn;
            break;
            
        case AVCaptureFlashModeOn:
            mode = AVCaptureFlashModeOff;
            break;
            
        case AVCaptureFlashModeOff:
            mode = AVCaptureFlashModeAuto;
            break;
    }
    
    if ([device isFlashModeSupported:mode]) {
        device.flashMode = mode;
    }
    
    [device unlockForConfiguration];
    
    [self flashModeWithCaptureSession:session andButton:button];
}

+ (void)flashModeWithCaptureSession:(AVCaptureSession *)session andButton:(UIButton *)button
{
    AVCaptureDevice *device = [session.inputs.lastObject device];
    AVCaptureFlashMode mode = [device flashMode];
    UIImage *image = UIImageFromAVCaptureFlashMode(mode);
    UIColor *tintColor = TintColorFromAVCaptureFlashMode(mode);
    button.enabled = [device isFlashModeSupported:mode];
    
    if ([button isKindOfClass:[TFTintedButton class]]) {
        [(TFTintedButton*)button setCustomTintColorOverride:tintColor];
    }
    
    [button setImage:image forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark - Private methods

UIImage *UIImageFromAVCaptureFlashMode(AVCaptureFlashMode mode)
{
    NSArray *array = @[@"CameraFlashOff", @"CameraFlashOn", @"CameraFlashAuto"];
    NSString *imageName = [array objectAtIndex:mode];
    return [UIImage imageNamed:imageName];
}

UIColor *TintColorFromAVCaptureFlashMode(AVCaptureFlashMode mode)
{
    NSArray *array = @[[UIColor grayColor], [TFCameraColor tintColor], [TFCameraColor tintColor]];
    UIColor *color = [array objectAtIndex:mode];
    return color;
}

@end
