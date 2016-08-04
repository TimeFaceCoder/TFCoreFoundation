//
//  TFPageNodeDemoViewController.m
//  TimeFaceDemoProject
//
//  Created by zguanyu on 16/8/2.
//  Copyright © 2016年 Summer. All rights reserved.
//

#import "TFPageViewController.h"
#import "TFSegmentView.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "TFPagerNodeChildViewController.h"
#import "TFViewControllerPageNode.h"


@interface TFPageViewController ()<TFViewControllerPageNodeDelegate>
@property (nonatomic, strong)TFSegmentView* segmentView;
@property (nonatomic, strong)TFViewControllerPageNode* pageNode;
@end

@implementation TFPageViewController

- (TFSegmentView *)segmentView
{
    if (!_segmentView) {
        _segmentView = [[TFSegmentView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, [self heightForSegment]) itemArray:[self titlesForViewControllers]];
        __weak TFPageViewController* wself = self;
        _segmentView.changeBlock = ^(NSInteger currentIndex,NSString *currentItem) {
            [wself.pageNode scrollToViewControllerAtIndex:currentIndex animated:YES];
        };
    }
    return _segmentView;
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
    [self.view addSubview:self.segmentView];
    [self.view addSubnode:self.pageNode];
}



- (void)viewDidLayoutSubviews
{
    self.pageNode.frame = CGRectMake(0, self.segmentView.tf_bottom, self.view.tf_width, [self heightForViewControllers]);
}


-(CGFloat)heightForViewControllers
{
    return self.view.tf_height - self.segmentView.tf_height;
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
    return [self viewControllerAtIndex:index];
}

-(void)viewControllerPageNode:(TFViewControllerPageNode *)viewControllerPageNode didSelectViewControllerAtIndex:(NSUInteger)index
{
    self.segmentView.currentItemIndex = index;
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



@end
