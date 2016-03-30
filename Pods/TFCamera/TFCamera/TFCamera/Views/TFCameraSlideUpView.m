//
//  TFCameraSlideUpView.m
//  TFCamera
//
//  Created by Melvin on 7/17/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "TFCameraSlideUpView.h"

@interface TFCameraSlideUpView () <TFCameraSlideViewProtocol>

@end

@implementation TFCameraSlideUpView

#pragma mark -
#pragma mark - TGCameraSlideViewProtocol

- (CGFloat)initialPositionWithView:(UIView *)view
{
    return 0;
}

- (CGFloat)finalPosition
{
    return -CGRectGetHeight(self.frame);
}

@end
