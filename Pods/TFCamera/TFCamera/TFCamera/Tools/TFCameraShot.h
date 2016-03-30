//
//  TFCameraShot.h
//  TFCamera
//
//  Created by Melvin on 7/16/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

@import Foundation;
@import AVFoundation;
@import UIKit;

@interface TFCameraShot : NSObject

+ (void)takePhotoCaptureView:(UIView *)captureView
            stillImageOutput:(AVCaptureStillImageOutput *)stillImageOutput
            videoOrientation:(AVCaptureVideoOrientation)videoOrientation
                    cropSize:(CGSize)cropSize
                  completion:(void (^)(UIImage *photo))completion;

@end
