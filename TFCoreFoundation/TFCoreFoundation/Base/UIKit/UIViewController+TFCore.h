//
//  UIViewController+TFCore.h
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIViewController (TFCore)

@property (nonatomic, strong) UINavigationBar *tf_transitionNavigationBar;
@property (nonatomic, assign) BOOL tf_prefersNavigationBarBackgroundViewHidden;
@property (nonatomic, assign) BOOL tf_hiddenNavigationBarWhenScrollViewDidScroll;//when set this property to YES, must set scrollView delegate to ViewController and implement scrollViewDidScroll and 
@property (nonatomic, assign) BOOL tf_hiddenTabBarWhenScrollViewDidScroll;//when set this property to YES, must set scrollView delegate to ViewController.

- (void)tf_addTransitionNavigationBarIfNeeded;



@end
