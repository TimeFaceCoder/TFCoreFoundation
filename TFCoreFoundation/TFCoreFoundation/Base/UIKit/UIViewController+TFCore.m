//
//  UIViewController+TFCore.m
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "UIViewController+TFCore.h"
#import "TFCoreFoundationMacro.h"
#import "UIDevice+TFCore.h"
#import <objc/runtime.h>
#import "TFSwizzleMethod.h"
#import "UINavigationController+TFCore.h"

TFSYNTH_DUMMY_CLASS(UIViewController_TFCore)

#define kNearZero 0.000001f

@implementation UIViewController (TFCore)

- (void)showNavigationBar:(BOOL)animated
{
    CGFloat statusBarHeight = [self statusBarHeight];
    
    UIWindow *appKeyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *appBaseView = appKeyWindow.rootViewController.view;
    CGRect viewControllerFrame =  [appBaseView convertRect:appBaseView.bounds toView:appKeyWindow];
    
    CGFloat overwrapStatusBarHeight = statusBarHeight - viewControllerFrame.origin.y;
    
    [self setNavigationBarOriginY:overwrapStatusBarHeight animated:animated];
}

- (void)hideNavigationBar:(BOOL)animated
{
    CGFloat statusBarHeight = [self statusBarHeight];
    
    UIWindow *appKeyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *appBaseView = appKeyWindow.rootViewController.view;
    CGRect viewControllerFrame =  [appBaseView convertRect:appBaseView.bounds toView:appKeyWindow];
    
    CGFloat overwrapStatusBarHeight = statusBarHeight - viewControllerFrame.origin.y;
    
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat top = kiOS7Later ? -navigationBarHeight + overwrapStatusBarHeight : -navigationBarHeight;
    
    [self setNavigationBarOriginY:top animated:animated];
}

- (void)moveNavigationBar:(CGFloat)deltaY animated:(BOOL)animated
{
    CGRect frame = self.navigationController.navigationBar.frame;
    CGFloat nextY = frame.origin.y + deltaY;
    [self setNavigationBarOriginY:nextY animated:animated];
}

- (void)setNavigationBarOriginY:(CGFloat)y animated:(BOOL)animated
{
    CGFloat statusBarHeight = [self statusBarHeight];
    
    UIWindow *appKeyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *appBaseView = appKeyWindow.rootViewController.view;
    CGRect viewControllerFrame =  [appBaseView convertRect:appBaseView.bounds toView:appKeyWindow];
    
    CGFloat overwrapStatusBarHeight = statusBarHeight - viewControllerFrame.origin.y;
    
    CGRect frame = self.navigationController.navigationBar.frame;
    CGFloat navigationBarHeight = frame.size.height;
    
    CGFloat topLimit = kiOS7Later ? -navigationBarHeight + overwrapStatusBarHeight : -navigationBarHeight;
    CGFloat bottomLimit = overwrapStatusBarHeight;
    
    frame.origin.y = fmin(fmax(y, topLimit), bottomLimit);
    
    CGFloat navBarHiddenRatio = overwrapStatusBarHeight > 0 ? (overwrapStatusBarHeight - frame.origin.y) / overwrapStatusBarHeight : 0;
    CGFloat alpha = MAX(1.f - navBarHiddenRatio, kNearZero);
    [UIView animateWithDuration:animated ? 0.1 : 0 animations:^{
        self.navigationController.navigationBar.frame = frame;
        NSUInteger index = 0;
        for (UIView *view in self.navigationController.navigationBar.subviews) {
            index++;
            if (index == 1 || view.hidden || view.alpha <= 0.0f) continue;
            view.alpha = alpha;
        }
        if (kiOS7Later) {
            // fade bar buttons
            UIColor *tintColor = self.navigationController.navigationBar.tintColor;
            if (tintColor) {
                self.navigationController.navigationBar.tintColor = [tintColor colorWithAlphaComponent:alpha];
            }
        }
    }];
}

- (CGFloat)statusBarHeight {
    CGSize statuBarFrameSize = [UIApplication sharedApplication].statusBarFrame.size;
    if (kiOS8Later) {
        return statuBarFrameSize.height;
    }
    return UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? statuBarFrameSize.height : statuBarFrameSize.width;
}

#pragma mark -
#pragma mark manage ToolBar

- (void)showToolbar:(BOOL)animated
{
    CGSize viewSize = self.navigationController.view.frame.size;
    CGFloat viewHeight = [self bottomBarViewControlleViewHeightFromViewSize:viewSize];
    CGFloat toolbarHeight = self.navigationController.toolbar.frame.size.height;
    [self setToolbarOriginY:viewHeight - toolbarHeight animated:animated];
}

- (void)hideToolbar:(BOOL)animated
{
    CGSize viewSize = self.navigationController.view.frame.size;
    CGFloat viewHeight = [self bottomBarViewControlleViewHeightFromViewSize:viewSize];
    [self setToolbarOriginY:viewHeight animated:animated];
}

- (void)moveToolbar:(CGFloat)deltaY animated:(BOOL)animated
{
    CGRect frame = self.navigationController.toolbar.frame;
    CGFloat nextY = frame.origin.y + deltaY;
    [self setToolbarOriginY:nextY animated:animated];
}

- (void)setToolbarOriginY:(CGFloat)y animated:(BOOL)animated
{
    CGRect frame = self.navigationController.toolbar.frame;
    CGFloat toolBarHeight = frame.size.height;
    CGSize viewSize = self.navigationController.view.frame.size;
    CGFloat viewHeight = [self bottomBarViewControlleViewHeightFromViewSize:viewSize];
    
    CGFloat topLimit = viewHeight - toolBarHeight;
    CGFloat bottomLimit = viewHeight;
    
    frame.origin.y = fmin(fmax(y, topLimit), bottomLimit); // limit over moving
    
    [UIView animateWithDuration:animated ? 0.1 : 0 animations:^{
        self.navigationController.toolbar.frame = frame;
    }];
}

#pragma mark -
#pragma mark manage TabBar

- (void)showTabBar:(BOOL)animated
{
    CGSize viewSize = self.tabBarController.view.frame.size;
    CGFloat viewHeight = [self bottomBarViewControlleViewHeightFromViewSize:viewSize];
    CGFloat toolbarHeight = self.tabBarController.tabBar.frame.size.height;
    [self setTabBarOriginY:viewHeight - toolbarHeight animated:animated];
}

- (void)hideTabBar:(BOOL)animated
{
    CGSize viewSize = self.tabBarController.view.frame.size;
    CGFloat viewHeight = [self bottomBarViewControlleViewHeightFromViewSize:viewSize];
    [self setTabBarOriginY:viewHeight animated:animated];
}

- (void)moveTabBar:(CGFloat)deltaY animated:(BOOL)animated
{
    CGRect frame =  self.tabBarController.tabBar.frame;
    CGFloat nextY = frame.origin.y + deltaY;
    [self setTabBarOriginY:nextY animated:animated];
}

- (void)setTabBarOriginY:(CGFloat)y animated:(BOOL)animated
{
    CGRect frame = self.tabBarController.tabBar.frame;
    CGRect viewFrame = self.view.frame;
    
    CGFloat toolBarHeight = frame.size.height;
    CGSize viewSize = self.tabBarController.view.frame.size;
    
    CGFloat viewHeight = [self bottomBarViewControlleViewHeightFromViewSize:viewSize];
    
    CGFloat topLimit = viewHeight - toolBarHeight;
    CGFloat bottomLimit = viewHeight;
    
    frame.origin.y = fmin(fmax(y, topLimit), bottomLimit); // limit over moving
    
    viewFrame.size.height = frame.origin.y;
    
    [UIView animateWithDuration:animated ? 0.1 : 0
                     animations:^{
                         self.tabBarController.tabBar.frame = frame;
                         if (self.tabBarController.tabBar) {
                             self.view.frame = viewFrame;
                         }
                     }];
}

- (CGFloat)bottomBarViewControlleViewHeightFromViewSize:(CGSize)viewSize
{
    CGFloat viewHeight = 0.f;
    if (kiOS8Later) {
        // starting from iOS8, tabBarViewController.view.frame respects interface orientation
        viewHeight = viewSize.height;
    } else {
        viewHeight = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? viewSize.height : viewSize.width;
    }
    
    return viewHeight;
}


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TFSwizzleMethod([self class],
                        @selector(viewWillLayoutSubviews),
                        @selector(tf_viewWillLayoutSubviews));
        
        TFSwizzleMethod([self class],
                        @selector(viewDidAppear:),
                        @selector(tf_viewDidAppear:));
    });
}

- (void)tf_viewDidAppear:(BOOL)animated {
    if (self.tf_transitionNavigationBar) {
        self.navigationController.navigationBar.barTintColor = self.tf_transitionNavigationBar.barTintColor;
        [self.navigationController.navigationBar setBackgroundImage:[self.tf_transitionNavigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:self.tf_transitionNavigationBar.shadowImage];
        
        [self.tf_transitionNavigationBar removeFromSuperview];
        self.tf_transitionNavigationBar = nil;
    }
    self.tf_prefersNavigationBarBackgroundViewHidden = NO;
    [self tf_viewDidAppear:animated];
}

- (void)tf_viewWillLayoutSubviews {
    id<UIViewControllerTransitionCoordinator> tc = self.transitionCoordinator;
    UIViewController *fromViewController = [tc viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [tc viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if ([self isEqual:self.navigationController.viewControllers.lastObject] && [toViewController isEqual:self]) {
        if (self.navigationController.navigationBar.translucent) {
            [tc containerView].backgroundColor = [self.navigationController tf_containerViewBackgroundColor];
        } else {
            fromViewController.view.clipsToBounds = NO;
            toViewController.view.clipsToBounds = NO;
        }
        if (!self.tf_transitionNavigationBar) {
            [self tf_addTransitionNavigationBarIfNeeded];
            
            self.tf_prefersNavigationBarBackgroundViewHidden = YES;
        }
        [self tf_resizeTransitionNavigationBarFrame];
    }
    [self tf_viewWillLayoutSubviews];
}

- (void)tf_resizeTransitionNavigationBarFrame {
    if (!self.view.window) {
        return;
    }
    UIView *backgroundView = [self.navigationController.navigationBar valueForKey:@"_backgroundView"];
    CGRect rect = [backgroundView.superview convertRect:backgroundView.frame toView:self.view];
    self.tf_transitionNavigationBar.frame = rect;
}

- (void)tf_addTransitionNavigationBarIfNeeded {
    if (!self.view.window) {
        return;
    }
    if (!self.navigationController.navigationBar) {
        return;
    }
    UINavigationBar *bar = [[UINavigationBar alloc] init];
    bar.barStyle = self.navigationController.navigationBar.barStyle;
    if (bar.translucent != self.navigationController.navigationBar.translucent) {
        bar.translucent = self.navigationController.navigationBar.translucent;
    }
    bar.barTintColor = self.navigationController.navigationBar.barTintColor;
    [bar setBackgroundImage:[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
    bar.shadowImage = self.navigationController.navigationBar.shadowImage;
    [self.tf_transitionNavigationBar removeFromSuperview];
    self.tf_transitionNavigationBar = bar;
    [self tf_resizeTransitionNavigationBarFrame];
    if (!self.navigationController.navigationBarHidden) {
        [self.view addSubview:self.tf_transitionNavigationBar];
    }
}

- (UINavigationBar *)tf_transitionNavigationBar {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTf_transitionNavigationBar:(UINavigationBar *)navigationBar {
    objc_setAssociatedObject(self, @selector(tf_transitionNavigationBar), navigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)tf_prefersNavigationBarBackgroundViewHidden {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setTf_prefersNavigationBarBackgroundViewHidden:(BOOL)hidden {
    [[self.navigationController.navigationBar valueForKey:@"_backgroundView"]
     setHidden:hidden];
    objc_setAssociatedObject(self, @selector(tf_prefersNavigationBarBackgroundViewHidden), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
