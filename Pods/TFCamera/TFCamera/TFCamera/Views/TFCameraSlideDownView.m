//
//  TFCameraSlideDownView.m
//  TFCamera
//
//  Created by Melvin on 7/17/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "TFCameraSlideDownView.h"

@interface TFCameraSlideDownView () <TFCameraSlideViewProtocol>

@end

@implementation TFCameraSlideDownView

#pragma mark -
#pragma mark - TGCameraSlideViewProtocol

- (CGFloat)initialPositionWithView:(UIView *)view
{
    return CGRectGetHeight(view.frame)/2;
}

- (CGFloat)finalPosition
{
    return CGRectGetMaxY(self.frame);
}

@end
