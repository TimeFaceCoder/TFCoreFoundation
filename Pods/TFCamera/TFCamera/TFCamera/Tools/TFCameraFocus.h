//
//  TFCameraFocus.h
//  TFCamera
//
//  Created by Melvin on 7/16/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

@import AVFoundation;
@import UIKit;

@interface TFCameraFocus : NSObject

+ (void)focusWithCaptureSession:(AVCaptureSession *)session
                     touchPoint:(CGPoint)touchPoint
                    inFocusView:(UIView *)focusView;

@end
