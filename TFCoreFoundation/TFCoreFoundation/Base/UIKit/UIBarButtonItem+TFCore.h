//
//  UIBarButtonItem+TFCore.h
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface UIBarButtonItem (TFCore)

+ (instancetype)barButtonItemWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage target:(nullable id)target action:(nullable SEL)action;


@property (nullable, nonatomic, copy) void (^actionBlock)(id);
@end
NS_ASSUME_NONNULL_END