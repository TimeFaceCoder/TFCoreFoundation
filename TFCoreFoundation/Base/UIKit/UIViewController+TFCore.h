//
//  UIViewController+TFCore.h
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (TFCore)

@property (nonatomic, assign) BOOL tf_hiddenNavigationBarWhenScrollViewDidScroll;//when set this property to YES, must set scrollView delegate to ViewController and implement scrollViewDidScroll and 
@property (nonatomic, assign) BOOL tf_hiddenTabBarWhenScrollViewDidScroll;//when set this property to YES, must set scrollView delegate to ViewController.

/**
 set navigation bar full translucent automatically,default is NO. When set this property to YES, the navigation bar will become full translucent at viewwillappear, recover navigation bar to normal at viewwilldisappear.
 */
@property (nonatomic, assign) BOOL tf_navigationBarFullTranslucent;

/**
 set navigationbar full translucent.
 */
- (void)tf_setNavigationBarFullTranslucent;

/**
 set navigationbar to nomarl.
 */
- (void)tf_recoverNavigationBarToNormal;

/**
 when click the back item at navigation bar,this method will be called.

 @return a bool value the current viewcontroller shoudld pop.
 */
- (BOOL)tf_navigationBarBackItemDidClick;

@end
