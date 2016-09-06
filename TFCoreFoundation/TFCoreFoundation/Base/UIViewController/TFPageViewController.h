//
//  TFPageNodeDemoViewController.h
//  TimeFaceDemoProject
//
//  Created by zguanyu on 16/8/2.
//  Copyright © 2016年 Summer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>
typedef void(^SegmentViewChangeBlock)(NSInteger currentIndex,NSString *currentItem);


/**
 *  Segment View Delegate.
 */
@protocol SegmentViewDelegate <NSObject>
@required
/**
 *  @brief changeBlock called when segmented view current index is udpated
 */
@property (nonatomic, copy)SegmentViewChangeBlock changeBlock;
@optional

/**
 *  update segment view current selected index by contentoffset (of pageNode) in contentWidth and viewWith.
 *
 *  @param contentOffset contentOffset in pageNode. x of contentOffset
 *  @param contentWidth  contentWidth in pageNode. width of contentSize
 *  @param viewWith      viewWidth in pageNode. width of frame.size
 */
- (void)segmentViewUpdateCurrentSelectedIndexByContentOffset:(CGFloat)contentOffset inContentWidth:(CGFloat)contentWidth viewWidth:(CGFloat)viewWith;
@end

/**
 *  PageController base class. Any one who want to implement 
 *  a segment view with pages of controllers should inherit this class
 *  and implement just two methods:
 * 1. titlesForControllers:
 * 2. controllerForIndex:
 */
@interface TFPageViewController : UIViewController

/**
 *  重设子VC的高度，子类重载设置
 *
 *  @return 子VC的高度
 */
- (CGFloat)heightForViewControllers;

/**
 *  重设segment的高度，子类重载设置
 *
 *  @return segment的高度
 */
- (CGFloat)heightForSegment;

/**
 *  VC的segment title，子类重载设置
 *
 *  @return VC的segment title
 */
- (NSArray*)titlesForViewControllers;

/**
 *  对应index的vc，子类重载设置
 *
 *  @param index
 *
 *  @return 对应index的VC
 */
- (UIViewController *)viewControllerAtIndex:(NSUInteger)index;

- (NSInteger)currentIndex;

- (void)didSelectViewController:(UIViewController *)viewController AtIndex:(NSInteger)index;

- (void)willDisplayViewController:(UIViewController *)viewController AtIndex:(NSInteger)index;

- (void)didEndDisplayingViewController:(UIViewController *)viewController AtIndex:(NSInteger)index;

- (void)scrollToViewControllerAtIndex:(NSInteger)index animated:(BOOL)animated;

- (UIView<SegmentViewDelegate> *)headerSegmentView;
@end
