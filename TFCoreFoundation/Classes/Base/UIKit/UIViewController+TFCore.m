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
#import "UIImage+TFCore.h"

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
        
        TFSwizzleMethod([self class], @selector(viewWillAppear:), @selector(tf_viewWillAppear:));
                        
        TFSwizzleMethod([self class], @selector(viewWillDisappear:), @selector(tf_viewWillDisappear:));

        if ([self respondsToSelector:@selector(scrollViewDidScroll:)]) {
            TFSwizzleMethod([self class], @selector(scrollViewDidScroll:), @selector(tf_scrollViewDidScroll:));
        };
        if ([self respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
            TFSwizzleMethod([self class], @selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:), @selector(tf_scrollViewWillEndDragging:withVelocity:targetContentOffset:));
        }
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

- (BOOL)tf_navigationBarBackItemDidClick {
    return YES;
}

- (void)tf_viewWillAppear:(BOOL)animated {
    if (self.tf_navigationBarFullTranslucent) {
        [self tf_setNavigationBarFullTranslucent];
    }
    [self tf_viewWillAppear:animated];
}

- (void)tf_viewWillDisappear:(BOOL)animated {
    if (self.tf_navigationBarFullTranslucent) {
        [self tf_recoverNavigationBarToNormal];
    }
    [self tf_viewWillDisappear:animated];
}

- (void)tf_viewDidLoad {
    NSString *backTitle = nil;
    if ([[TFStyle globalStyleSheet] respondsToSelector:@selector(navBarDefaultBackTitle)]) {
        backTitle = TFSTYLEVAR(navBarDefaultBackTitle);
    }
    if (backTitle) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:backTitle style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    [self tf_viewDidLoad];
}

- (void)tf_setNavigationBarFullTranslucent {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)tf_recoverNavigationBarToNormal {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:TFSTYLEVAR(navBarBackgroundColor)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
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

- (BOOL)tf_navigationBarFullTranslucent {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setTf_navigationBarFullTranslucent:(BOOL)tf_navigationBarFullTranslucent {
    objc_setAssociatedObject(self, @selector(tf_navigationBarFullTranslucent), @(tf_navigationBarFullTranslucent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)scrollUp {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setScrollUp:(BOOL)scrollUp {
    objc_setAssociatedObject(self, @selector(scrollUp), @(scrollUp), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
