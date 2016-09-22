//
//  ASDisplayNode+TFCore.m
//  TFCoreFoundation
//
//  Created by Summer on 2016/9/22.
//  Copyright © 2016年 TimeFace. All rights reserved.
//

#import "ASDisplayNode+TFCore.h"

@implementation ASDisplayNode (TFCore)
#pragma mark get tf_width
- (CGFloat)tf_width {
    return CGRectGetWidth(self.frame);
}

#pragma mark set tf_width
- (void)setTf_width:(CGFloat)tf_width {
    
    CGRect frame = self.frame;
    frame.size.width = tf_width;
    self.frame = frame;
}

#pragma mark get tf_height
- (CGFloat)tf_height {
    return CGRectGetHeight(self.frame);
}

#pragma mark set tf_height
- (void)setTf_height:(CGFloat)tf_height {
    CGRect frame = self.frame;
    frame.size.height = tf_height;
    self.frame = frame;
}

#pragma mark get tf_size
-(CGSize)tf_size {
    return self.frame.size;
}

#pragma mark set tf_size
-(void)setTf_size:(CGSize)tf_size {
    CGRect frame = self.frame;
    frame.size = tf_size;
    self.frame = frame;
}

#pragma mark get tf_left
- (CGFloat)tf_left {
    return CGRectGetMinX(self.frame);
}

#pragma mark set tf_left
- (void)setTf_left:(CGFloat)tf_left {
    CGRect frame = self.frame;
    frame.origin.x = tf_left;
    self.frame = frame;
}

#pragma mark get tf_top
- (CGFloat)tf_top {
    return CGRectGetMinY(self.frame);
}

#pragma mark set tf_top
- (void)setTf_top:(CGFloat)tf_top {
    CGRect frame = self.frame;
    frame.origin.y = tf_top;
    self.frame = frame;
}

#pragma mark get tf_right
- (CGFloat)tf_right {
    return CGRectGetMaxX(self.frame);
}

#pragma mark set tf_right
- (void)setTf_right:(CGFloat)tf_right {
    CGRect frame = self.frame;
    frame.origin.x = tf_right-CGRectGetWidth(frame);
    self.frame = frame;
}

#pragma mark get tf_bottom
- (CGFloat)tf_bottom {
    return CGRectGetMaxY(self.frame);
}

#pragma mark set tf_bottom
- (void)setTf_bottom:(CGFloat)tf_bottom {
    CGRect frame = self.frame;
    frame.origin.y = tf_bottom - CGRectGetHeight(frame);
    self.frame = frame;
}

#pragma mark get tf_origin
- (CGPoint)tf_origin {
    return self.frame.origin;
}

#pragma mark set tf_origin
- (void)setTf_origin:(CGPoint)tf_origin {
    CGRect frame = self.frame;
    frame.origin = tf_origin;
    self.frame = frame;
}

#pragma mark get tf_rightTop
- (CGPoint)tf_rightTop {
    CGRect frame = self.frame;
    return CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame));
}

#pragma mark set tf_rightTop
- (void)setTf_rightTop:(CGPoint)tf_rightTop {
    CGRect frame = self.frame;
    frame.origin.x = tf_rightTop.x-CGRectGetWidth(frame);
    frame.origin.y = tf_rightTop.y;
    self.frame = frame;
}

#pragma mark get tf_leftBottom
- (CGPoint)tf_leftBottom {
    CGRect frame = self.frame;
    return CGPointMake(CGRectGetMinX(frame),CGRectGetMaxY(frame));
}

#pragma mark set tf_leftBottom
- (void)setTf_leftBottom:(CGPoint)tf_leftBottom {
    CGRect frame = self.frame;
    frame.origin.x = tf_leftBottom.x;
    frame.origin.y = tf_leftBottom.y - CGRectGetHeight(frame);
    self.frame = frame;
}

#pragma mark get tf_rightBottom
- (CGPoint)tf_rightBottom {
    CGRect frame = self.frame;
    return CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame));
}

#pragma mark set tf_rightBottom
- (void)setTf_rightBottom:(CGPoint)tf_rightBottom{
    CGRect frame = self.frame;
    frame.origin.x = tf_rightBottom.x - CGRectGetWidth(frame);
    frame.origin.y = tf_rightBottom.y - CGRectGetHeight(frame);
    self.frame = frame;
}

#pragma mark get tf_centerX
- (CGFloat)tf_centerX {
    return CGRectGetMidX(self.frame);
}

#pragma mark set tf_centerX
- (void)setTf_centerX:(CGFloat)tf_centerX {
    CGRect frame = self.frame;
    frame.origin.x = tf_centerX - CGRectGetWidth(frame)/2.0;
    self.frame = frame;
}

#pragma mark get centerY
- (CGFloat)tf_centerY {
    return CGRectGetMidY(self.frame);
}

#pragma mark set centerY
- (void)setTf_centerY:(CGFloat)tf_centerY {
    CGRect frame = self.frame;
    frame.origin.y = tf_centerY - CGRectGetHeight(frame)/2.0;
    self.frame = frame;
}

@end
