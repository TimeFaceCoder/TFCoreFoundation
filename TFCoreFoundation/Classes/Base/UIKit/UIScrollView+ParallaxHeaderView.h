//
//  UIScrollView+ParallaxHeaderView.h
//  ScrollViewParallaxHeaderDemo
//
//  Created by Summer on 2016/9/28.
//  Copyright © 2016年 Summer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TFParallaxHeaderChangeBlock)(__kindof UIView *parallaxHeaderView,CGFloat originalHeight ,float headerRatio);

@interface UIScrollView (ParallaxHeaderView)

/**
 parallax header view you added.
 */
@property (nonatomic, strong, readonly) UIView *parallaxHeaderView;

/**
 when set this block, it will return the current height ratio to original height.
 */
@property (nonatomic, copy) TFParallaxHeaderChangeBlock headerHeightChangeBlock;

/**
 add parallax header view to scrollView, header height will be get from headerView.frame.size.height.

 @param headerView   header view.
 */
- (void)addParallaxHeaderView:(__kindof UIView *)headerView;

/**
 add parallax header view with minHeaderHeight to scrollView,header height will be get from headerView.frame.size.height.

 @param headerView      header view.
 @param minHeaderHeight constant min height of header view.
 */
- (void)addParallaxHeaderView:(__kindof UIView *)headerView
              minHeaderHeight:(CGFloat)minHeaderHeight;


/**
 add parallax view fast with an image, the height of header view is image.size.height, the width of header view is scrollView.frame.size.width.

 @param imageName is dispalyed in header view.
 */
- (void)addParallaxHeaderWithImageName:(NSString *)imageName;


/**
 add parallax view fast with an image, the height of header view is image.size.height, the width of header view is scrollView.frame.size.width.

 @param imageName       imageName is dispalyed in header view.
 @param minHeaderHeight constant min height of header view.
 */
- (void)addParallaxHeaderWithImageName:(NSString *)imageName minHeaderHeight:(CGFloat)minHeaderHeight;

@end

