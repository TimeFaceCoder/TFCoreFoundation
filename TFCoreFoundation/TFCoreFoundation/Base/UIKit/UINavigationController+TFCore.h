//
//  UINavigationController+TFCore.h
//  TFCoreFoundation
//
//  Created by Melvin on 4/13/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface UINavigationController (TFCore)

- (UIColor *)tf_containerViewBackgroundColor;

/**
 根据class跳转制定的ViewController.

 @param class viewController对应的class.
 @param animated 是否动画
 */
- (void)popToViewControllerWithClass:(Class)class animated:(BOOL)animated;

@end
NS_ASSUME_NONNULL_END
