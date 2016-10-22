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
#import "TFDefaultStyle.h"
#import <objc/runtime.h>
#import "TFSwizzleMethod.h"
#import "UINavigationController+TFCore.h"

@interface UIViewController ()

@property (nonatomic, assign) BOOL scrollUp;

@end

TFSYNTH_DUMMY_CLASS(UIViewController_TFCore)

#define kNearZero 0.000001f

@implementation UIViewController (TFCore)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TFSwizzleMethod([self class],
                        @selector(viewWillLayoutSubviews),
                        @selector(tf_viewWillLayoutSubviews));
        
        TFSwizzleMethod([self class],
                        @selector(viewDidAppear:),
                        @selector(tf_viewDidAppear:));
        
        TFSwizzleMethod([self class], @selector(viewDidLoad), @selector(tf_viewDidLoad));
        
    });
}

- (void)tf_scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.tf_hiddenTabBarWhenScrollViewDidScroll | self.tf_hiddenNavigationBarWhenScrollViewDidScroll) {
        CGFloat currentOffset = scrollView.contentOffset.y;
        static CGFloat _lastOffset = 0.0;
        CGFloat diff = (currentOffset -_lastOffset);
        if (scrollView.tracking) {
            self.scrollUp = (diff>=0);
            if (self.tf_hiddenTabBarWhenScrollViewDidScroll) {
                CGFloat tabBarY = self.tabBarController.tabBar.transform.ty;
                CGFloat newTabBarY = tabBarY += diff;
                tabBarY = MAX(MIN(CGRectGetHeight(self.tabBarController.tabBar.frame), newTabBarY), 0.0);
                self.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0.0,tabBarY);
            }
            
            if (self.tf_hiddenNavigationBarWhenScrollViewDidScroll) {
                CGFloat navigationBarY = self.navigationController.navigationBar.transform.ty;
                CGFloat newNavigationBarY = navigationBarY -= diff;
                navigationBarY = MAX(MIN(0.0, newNavigationBarY), -CGRectGetHeight(self.navigationController.navigationBar.frame)-20.0);
                self.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(0.0,navigationBarY);
            }
           
        }
        _lastOffset = scrollView.contentOffset.y;
    }
    [self tf_scrollViewDidScroll:scrollView];
}

- (void)tf_scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.tf_hiddenTabBarWhenScrollViewDidScroll | self.tf_hiddenNavigationBarWhenScrollViewDidScroll) {
        [UIView beginAnimations:@"BarHidden" context:nil];
        if (self.tf_hiddenNavigationBarWhenScrollViewDidScroll) {
            if (self.scrollUp) {
                self.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(0.0, -CGRectGetHeight(self.navigationController.navigationBar.frame)-20.0);
            }
            else {
                self.navigationController.navigationBar.transform = CGAffineTransformIdentity;
            }
        }
        if (self.tf_hiddenTabBarWhenScrollViewDidScroll) {
            if (self.scrollUp) {
                self.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.tabBarController.tabBar.frame));
            }
            else {
                self.tabBarController.tabBar.transform = CGAffineTransformIdentity;
            }
        }
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView commitAnimations];
    }
    [self tf_scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
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

- (void)tf_viewDidLoad {
    NSString *backTitle = TFSTYLEVAR(navBarDefaultBackTitle);
    if ([self respondsToSelector:@selector(scrollViewDidScroll:)]) {
        TFSwizzleMethod([self class], @selector(scrollViewDidScroll:), @selector(tf_scrollViewDidScroll:));
    };
    if ([self respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        TFSwizzleMethod([self class], @selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:), @selector(tf_scrollViewWillEndDragging:withVelocity:targetContentOffset:));
    }
    if (backTitle) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:backTitle style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    [self tf_viewDidLoad];
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

- (BOOL)tf_hiddenNavigationBarWhenScrollViewDidScroll {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setTf_hiddenNavigationBarWhenScrollViewDidScroll:(BOOL)tf_hiddenNavigationBarWhenScrollViewDidScroll {
    objc_setAssociatedObject(self, @selector(tf_hiddenNavigationBarWhenScrollViewDidScroll), @(tf_hiddenNavigationBarWhenScrollViewDidScroll), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)tf_hiddenTabBarWhenScrollViewDidScroll {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setTf_hiddenTabBarWhenScrollViewDidScroll:(BOOL)tf_hiddenTabBarWhenScrollViewDidScroll {
    objc_setAssociatedObject(self, @selector(tf_hiddenTabBarWhenScrollViewDidScroll), @(tf_hiddenTabBarWhenScrollViewDidScroll), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)scrollUp {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setScrollUp:(BOOL)scrollUp {
    objc_setAssociatedObject(self, @selector(scrollUp), @(scrollUp), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
