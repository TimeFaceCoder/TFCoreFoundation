//
//  TFPageNodeDemoViewController.m
//  TimeFaceDemoProject
//
//  Created by zguanyu on 16/8/2.
//  Copyright © 2016年 Summer. All rights reserved.
//

#import "TFPageViewController.h"
#import "TFSegmentView.h"
#import "TFViewControllerPageNode.h"
#import "UIView+TFCore.h"
#import "TFCGUtilities.h"

@interface TFPageViewController ()<TFViewControllerPageNodeDelegate>
@property (nonatomic, strong)TFViewControllerPageNode* pageNode;
@property (nonatomic, strong)TFSegmentView* headerView;
@end

@implementation TFPageViewController



- (UIView<SegmentViewDelegate> *)headerSegmentView {
    if (!_headerView) {
        _headerView = [[TFSegmentView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, [self heightForSegment]) configModel:nil itemArray:[self titlesForViewControllers]];
        __weak TFPageViewController* wself = self;
        _headerView.changeBlock = ^(NSInteger currentIndex,NSString *currentItem) {
            [wself.pageNode scrollToViewControllerAtIndex:currentIndex animated:YES];
        };
    }
    return _headerView;
}
- (TFViewControllerPageNode *)pageNode
{
    if (!_pageNode) {
        _pageNode = [[TFViewControllerPageNode alloc]init];
        _pageNode.delegate = self;
    }
    return _pageNode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //当在UINavigationController里使用SegmentView时，上面两行必须使用一行，否则SegmentView会不显示，因为SegmentView包含一个CollectionView
    [self.view addSubview:self.headerSegmentView];
    [self.view addSubnode:self.pageNode];
}



- (void)viewDidLayoutSubviews
{
//    self.headerSegmentView.frame = CGRectMake(0, 0, self.view.tf_width, [self heightForSegment]);
    self.pageNode.frame = CGRectMake(0, self.headerSegmentView.tf_bottom, self.view.tf_width, [self heightForViewControllers]);
}

-(CGFloat)heightForViewControllers
{
    return self.view.tf_height - self.headerSegmentView.tf_bottom;
}

- (CGFloat)heightForSegment {
    return 44.0;
}

- (NSArray *)titlesForViewControllers
{
    NSAssert(NO, @"子类需要重载此函数");
    return nil;
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    NSAssert(NO, @"子类需要重载此函数");
    return nil;
}

#pragma mark TFViewControllerPageNodeDelegate
- (NSUInteger)numberOfPagesInViewControllerPageNode:(TFViewControllerPageNode *)viewControllerPageNode{
    return [self titlesForViewControllers].count;
}

- (UIViewController *)viewControllerPageNode:(TFViewControllerPageNode *)viewControllerPageNode viewControllerAtIndex:(NSUInteger)index{
    UIViewController* vc = [self viewControllerAtIndex:index];
    [self addChildViewController:vc];
    return vc;
}

-(void)viewControllerPageNode:(TFViewControllerPageNode *)viewControllerPageNode didSelectViewControllerAtIndex:(NSUInteger)index
{
//    self.segmentView.currentItemIndex = index;
    [self.headerSegmentView didScrollToIndex:index];
    [self didSelectViewController:[self.pageNode viewControllerForPageAtIndex:index] AtIndex:index];
}

- (void)didSelectViewController:(UIViewController *)viewController AtIndex:(NSInteger)index {
    
}

- (void)viewControllerPageNode:(TFViewControllerPageNode *)viewControllerPageNode willDisplayViewControllerAtIndex:(NSUInteger)index {
    [self willDisplayViewController:[self.pageNode viewControllerForPageAtIndex:index] AtIndex:index];
}

- (void)willDisplayViewController:(UIViewController *)viewController AtIndex:(NSInteger)index {
    
}

- (void)viewControllerPageNode:(TFViewControllerPageNode *)viewControllerPageNode didEndDisplayingViewControllerAtIndex:(NSUInteger)index {
    [self didEndDisplayingViewController:[self.pageNode viewControllerForPageAtIndex:index] AtIndex:index];
}

- (void)didEndDisplayingViewController:(UIViewController *)viewController AtIndex:(NSInteger)index {
    
}

- (void)viewControllerPageNode:(TFViewControllerPageNode *)viewControllerPageNode scrollTo:(NSInteger)index byPercent:(CGFloat)percent {
    if (self.headerSegmentView && [self.headerSegmentView respondsToSelector:@selector(segmentViewUpdateToIndex:byPercent:)]) {
        [self.headerSegmentView segmentViewUpdateToIndex:index byPercent:percent];
    }
}

- (void)scrollToViewControllerAtIndex:(NSInteger)index animated:(BOOL)animated{
    [self.pageNode scrollToViewControllerAtIndex:index animated:animated];
}

- (NSInteger)currentIndex {
    return self.pageNode.currentPageIndex;
}

@end
