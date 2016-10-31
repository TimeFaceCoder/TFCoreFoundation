//
//  UINavigationController+TFCore.m
//  TFCoreFoundation
//
//  Created by Melvin on 4/13/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "UINavigationController+TFCore.h"
#import "UIViewController+TFCore.h"
#import <objc/runtime.h>
#import "TFSwizzleMethod.h"
#import "TFCoreFoundationMacro.h"

TFSYNTH_DUMMY_CLASS(UINavigationController_TFCore)

@implementation UINavigationController (TFCore)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TFSwizzleMethod([self class],
                        @selector(pushViewController:animated:),
                        @selector(tf_pushViewController:animated:));
        
        TFSwizzleMethod([self class],
                        @selector(popViewControllerAnimated:),
                        @selector(tf_popViewControllerAnimated:));
        
        TFSwizzleMethod([self class],
                        @selector(popToViewController:animated:),
                        @selector(tf_popToViewController:animated:));
        
        TFSwizzleMethod([self class],
                        @selector(popToRootViewControllerAnimated:),
                        @selector(tf_popToRootViewControllerAnimated:));
    });
}

- (UIColor *)tf_containerViewBackgroundColor {
    return [UIColor whiteColor];
}

- (void)tf_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    if (!disappearingViewController) {
        return [self tf_pushViewController:viewController animated:animated];
    }
    [disappearingViewController tf_addTransitionNavigationBarIfNeeded];
    if (animated) {
        disappearingViewController.tf_prefersNavigationBarBackgroundViewHidden = YES;
    }
    return [self tf_pushViewController:viewController animated:animated];
}

- (UIViewController *)tf_popViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count < 2) {
        return [self tf_popViewControllerAnimated:animated];
    }
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    [disappearingViewController tf_addTransitionNavigationBarIfNeeded];
    UIViewController *appearingViewController = self.viewControllers[self.viewControllers.count - 2];
    if (appearingViewController.tf_transitionNavigationBar) {
        UINavigationBar *appearingNavigationBar = appearingViewController.tf_transitionNavigationBar;
        self.navigationBar.barTintColor = appearingNavigationBar.barTintColor;
        [self.navigationBar setBackgroundImage:[appearingNavigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = appearingNavigationBar.shadowImage;
    }
    if (animated) {
        disappearingViewController.tf_prefersNavigationBarBackgroundViewHidden = YES;
    }
    return [self tf_popViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)tf_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (![self.viewControllers containsObject:viewController] || self.viewControllers.count < 2) {
        return [self tf_popToViewController:viewController animated:animated];
    }
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    [disappearingViewController tf_addTransitionNavigationBarIfNeeded];
    if (viewController.tf_transitionNavigationBar) {
        UINavigationBar *appearingNavigationBar = viewController.tf_transitionNavigationBar;
        self.navigationBar.barTintColor = appearingNavigationBar.barTintColor;
        [self.navigationBar setBackgroundImage:[appearingNavigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = appearingNavigationBar.shadowImage;
    }
    if (animated) {
        disappearingViewController.tf_prefersNavigationBarBackgroundViewHidden = YES;
    }
    return [self tf_popToViewController:viewController animated:animated];
}

- (NSArray<UIViewController *> *)tf_popToRootViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count < 2) {
        return [self tf_popToRootViewControllerAnimated:animated];
    }
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    [disappearingViewController tf_addTransitionNavigationBarIfNeeded];
    UIViewController *rootViewController = self.viewControllers.firstObject;
    if (rootViewController.tf_transitionNavigationBar) {
        UINavigationBar *appearingNavigationBar = rootViewController.tf_transitionNavigationBar;
        self.navigationBar.barTintColor = appearingNavigationBar.barTintColor;
        [self.navigationBar setBackgroundImage:[appearingNavigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = appearingNavigationBar.shadowImage;
    }
    if (animated) {
        disappearingViewController.tf_prefersNavigationBarBackgroundViewHidden = YES;
    }
    return [self tf_popToRootViewControllerAnimated:animated];
}

- (void)popToViewControllerWithClass:(Class)class animated:(BOOL)animated{
    NSArray *viewControllers = self.navigationController.viewControllers;
    for (NSInteger i=0; i < viewControllers.count-1; i++) {
        UIViewController *viewController = viewControllers[i];
        if ([viewController isKindOfClass:class]) {
            [self.navigationController popToViewController:viewController animated:animated];
            return;
        }
    }
}


@end
