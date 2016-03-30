//
//  TFCameraSlideView.h
//  TFCamera
//
//  Created by Melvin on 7/17/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TGCameraSlideViewProtocol;

@interface TFCameraSlideView : UIView

+ (void)showSlideUpView:(TFCameraSlideView *)slideUpView
          slideDownView:(TFCameraSlideView *)slideDownView
                 atView:(UIView *)view
             completion:(void (^)(void))completion;

+ (void)hideSlideUpView:(TFCameraSlideView *)slideUpView
          slideDownView:(TFCameraSlideView *)slideDownView
                 atView:(UIView *)view
             completion:(void (^)(void))completion;

@end

@protocol TFCameraSlideViewProtocol <NSObject>

- (CGFloat)initialPositionWithView:(UIView *)view;
- (CGFloat)finalPosition;

@end