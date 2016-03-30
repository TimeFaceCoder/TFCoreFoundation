//
//  TFCameraColor.m
//  TFCamera
//
//  Created by Melvin on 7/16/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "TFCameraColor.h"

static UIColor *staticTintColor = nil;

@interface TFCameraColor()

+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;

@end

@implementation TFCameraColor

+(void)setTintColor:(UIColor*)tintColor {
    staticTintColor = tintColor;
}

+ (UIColor *)grayColor {
    return [self colorWithRed:200 green:200 blue:200];
}

+ (UIColor *)tintColor {
    return staticTintColor != nil ? staticTintColor : [self colorWithRed:255 green:91 blue:1];
}

+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    CGFloat divisor = 255.f;
    return [self colorWithRed:red/divisor green:green/divisor blue:blue/divisor alpha:1];
}

+ (UIColor *)toolBarColor {
    return [self colorWithRed:0 green:0 blue:0];
}

+ (UIColor *)bottomBgColor {
    CGFloat divisor = 255.f;
    return [self colorWithRed:16/divisor green:16/divisor blue:16/divisor alpha:1];
}
+ (UIColor *)topBgColor {
    CGFloat divisor = 255.f;
    return [self colorWithRed:23/divisor green:23/divisor blue:23/divisor alpha:1];
}

@end
