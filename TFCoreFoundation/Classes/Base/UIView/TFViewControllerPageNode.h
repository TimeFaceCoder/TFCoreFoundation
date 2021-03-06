//
//  TFViewControllerNode.h
//  TimeFaceDemoProject
//
//  Created by zguanyu on 16/8/3.
//  Copyright © 2016年 Summer. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

@class TFViewControllerPageNode;
@protocol TFViewControllerPageNodeDelegate <NSObject>

@required

- (UIViewController*)viewControllerPageNode:(TFViewControllerPageNode*)viewControllerPageNode viewControllerAtIndex:(NSUInteger)index;

- (NSUInteger)numberOfPagesInViewControllerPageNode:(TFViewControllerPageNode *)viewControllerPageNode;

@optional
/**
 *  选中某个viewcontroller回调
 *
 *  @param viewControllerPageNode
 *  @param index
 *  注：手动调用scrollToViewControllerAtIndex:animated:方法时，该回调不会调用
 */
- (void)viewControllerPageNode:(TFViewControllerPageNode*)viewControllerPageNode didSelectViewControllerAtIndex:(NSUInteger)index;

- (void)viewControllerPageNode:(TFViewControllerPageNode *)viewControllerPageNode willDisplayViewControllerAtIndex:(NSUInteger)index;

- (void)viewControllerPageNode:(TFViewControllerPageNode *)viewControllerPageNode didEndDisplayingViewControllerAtIndex:(NSUInteger)index;

-(void)viewControllerPageNode:(TFViewControllerPageNode *)viewControllerPageNode didScrollContentOffset:(CGFloat)contentOffset inContentWidth:(CGFloat)contentWidth viewWidth:(CGFloat)viewWidth isDragging:(BOOL)isDragging;

- (void)viewControllerPageNode:(TFViewControllerPageNode *)viewControllerPageNode scrollTo:(NSInteger)index byPercent:(CGFloat)percent;

@end


@interface TFViewControllerPageNode : ASDisplayNode

/**
 *  当前页
 */
@property (nonatomic, assign, readonly) NSInteger currentPageIndex;

@property (nonatomic, weak) id<TFViewControllerPageNodeDelegate> delegate;

/**
 * 滚动到某个viewcontroller
 */
- (void)scrollToViewControllerAtIndex:(NSInteger)index animated:(BOOL)aniamted;

/**
 * 根据索引获取viewcontroller
 */
- (UIViewController *)viewControllerForPageAtIndex:(NSInteger)index;



/**
 重载pageNode数据
 */
- (void)reloadDataWithCompletion:(void(^)(void))completion;

@end
