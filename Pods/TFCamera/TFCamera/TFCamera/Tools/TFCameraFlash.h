//
//  TFCameraFlash.h
//  TFCamera
//
//  Created by Melvin on 7/16/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

@import Foundation;
@import AVFoundation;
@import UIKit;

@interface TFCameraFlash : NSObject

+ (void)changeModeWithCaptureSession:(AVCaptureSession *)session andButton:(UIButton *)button;
+ (void)flashModeWithCaptureSession:(AVCaptureSession *)session andButton:(UIButton *)button;

@end
