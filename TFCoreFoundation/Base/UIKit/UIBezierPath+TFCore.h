//
//  UIBezierPath+TFCore.h
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface UIBezierPath (TFCore)
+ (nullable UIBezierPath *)bezierPathWithText:(NSString *)text font:(UIFont *)font;
@end
NS_ASSUME_NONNULL_END