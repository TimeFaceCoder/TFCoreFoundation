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

@end
