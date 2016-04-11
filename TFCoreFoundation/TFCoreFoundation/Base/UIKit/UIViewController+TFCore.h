//
//  UIViewController+TFCore.h
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface UIViewController (TFCore)
- (void)showNavigationBar:(BOOL)animated;
- (void)hideNavigationBar:(BOOL)animated;
- (void)moveNavigationBar:(CGFloat)deltaY animated:(BOOL)animated;
- (void)setNavigationBarOriginY:(CGFloat)y animated:(BOOL)animated;

- (void)showToolbar:(BOOL)animated;
- (void)hideToolbar:(BOOL)animated;
- (void)moveToolbar:(CGFloat)deltaY animated:(BOOL)animated;
- (void)setToolbarOriginY:(CGFloat)y animated:(BOOL)animated;

- (void)showTabBar:(BOOL)animated;
- (void)hideTabBar:(BOOL)animated;
- (void)moveTabBar:(CGFloat)deltaY animated:(BOOL)animated;
- (void)setTabBarOriginY:(CGFloat)y animated:(BOOL)animated;
@end
NS_ASSUME_NONNULL_END