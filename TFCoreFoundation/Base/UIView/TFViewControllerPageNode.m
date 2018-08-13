//
//  TFViewControllerNode.m
//  TimeFaceDemoProject
//
//  Created by zguanyu on 16/8/3.
//  Copyright © 2016年 Summer. All rights reserved.
//

#import "TFViewControllerPageNode.h"
#import <objc/objc.h>
#import <objc/runtime.h>


@interface TFViewControllerPageNode ()<ASPagerDelegate, ASPagerDataSource>
@property (nonatomic, strong) ASPagerNode* pagerNode;
@property (nonatomic, assign) CGRect savedFrame;
@property (nonatomic, assign, readwrite) NSInteger currentPageIndex;
@property (nonatomic, strong) ASDisplayNode* finishedNode;
@property (nonatomic, strong) NSIndexPath* finishedIndexPath;
@property (nonatomic, strong) UIView* finishedSuperView;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (nonatomic, assign)NSInteger operatingPageIndex;
@property (nonatomic, assign)NSInteger targetPageIndex;
@end




@implementation TFViewControllerPageNode

-(ASPagerNode *)pagerNode
{
    if (!_pagerNode) {
        _pagerNode = [[ASPagerNode alloc]init];
        _pagerNode.delegate = self;
        _pagerNode.dataSource = self;
        
        ASRangeTuningParameters minimumRenderParams = { .leadingBufferScreenfuls = 0.0, .trailingBufferScreenfuls = 0.0 };
        ASRangeTuningParameters minimumPreloadParams = { .leadingBufferScreenfuls = 0.0, .trailingBufferScreenfuls = 0.0 };
        [_pagerNode setTuningParameters:minimumRenderParams forRangeMode:ASLayoutRangeModeMinimum rangeType:ASLayoutRangeTypeDisplay];
        [_pagerNode setTuningParameters:minimumPreloadParams forRangeMode:ASLayoutRangeModeMinimum rangeType:ASLayoutRangeTypePreload];
        
        ASRangeTuningParameters fullRenderParams = { .leadingBufferScreenfuls = 0.0, .trailingBufferScreenfuls = 0.0 };
        ASRangeTuningParameters fullPreloadParams = { .leadingBufferScreenfuls = 0.0, .trailingBufferScreenfuls = 0.0 };
        [_pagerNode setTuningParameters:fullRenderParams forRangeMode:ASLayoutRangeModeFull rangeType:ASLayoutRangeTypeDisplay];
        [_pagerNode setTuningParameters:fullPreloadParams forRangeMode:ASLayoutRangeModeFull rangeType:ASLayoutRangeTypePreload];
    }
    return _pagerNode;
}

-(instancetype)init
{
    if (self = [super init]) {
        
        [self addSubnode:self.pagerNode];
    }
    return self;
}


-(void)layout
{
    [super layout];
    self.savedFrame = self.frame;
    self.pagerNode.frame = self.bounds;
}

-(NSInteger)currentPageIndex
{
    return self.pagerNode.currentPageIndex;
}

-(void)scrollToViewControllerAtIndex:(NSInteger)index animated:(BOOL)aniamted
{
    NSAssert([self numberOfPagesInPagerNode:self.pagerNode] >= index, @"out of range");
    [self.pagerNode scrollToPageAtIndex:index animated:aniamted];
}

- (UIViewController *)viewControllerForPageAtIndex:(NSInteger)index {
    ASCellNode *cellNode = [self.pagerNode nodeForPageAtIndex:index];
    return [cellNode valueForKey:@"_viewController"];
}


#pragma mark - ASPagerNodeDelegate
- (NSInteger)numberOfPagesInPagerNode:(ASPagerNode *)pagerNode
{
    if (self.delegate!=nil&&[self.delegate respondsToSelector:@selector(numberOfPagesInViewControllerPageNode:)]) {
        return [self.delegate numberOfPagesInViewControllerPageNode:self];
    }
    return 0;
}

- (ASCellNodeBlock)pagerNode:(ASPagerNode *)pagerNode nodeBlockAtIndex:(NSInteger)index
{
    
    typeof(self) __weak weakSelf = self;
    return ^{
        //1. ASCellNode->ASDisplayNode(UIViewController.view) : VC的root view会被包装成一个node,然后被加入到cellNode中
        //2. UIViewController的生命周期:基本上跟CollectionView的cell重用机制一样，只有当前显示的,刚才显示的和将要显示的才会被加载
        ASCellNode *page = [[ASCellNode alloc] initWithViewControllerBlock:^UIViewController * _Nonnull{
            if (weakSelf.delegate!=nil&&[weakSelf.delegate respondsToSelector:@selector(viewControllerPageNode:viewControllerAtIndex:)]) {
                return [weakSelf.delegate viewControllerPageNode:weakSelf viewControllerAtIndex:index];
            }
            else{
                return nil;
            }
        } didLoadBlock:^(ASDisplayNode * _Nonnull node) {
            
        }];
        //3. 设置page的大小，如果设置为pagerNode大小，那么每页一个VC，如果设置为一半大小，那么每页两个
        page.preferredFrameSize = weakSelf.savedFrame.size;
        return page;
    };
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGSize viewSize = scrollView.frame.size;
    
    CGFloat contentCurrentOffset = scrollView.contentOffset.x;

    if (scrollView.dragging || scrollView.decelerating) {
        
        CGFloat contentOffsetForCurrentIndex = self.operatingPageIndex * viewSize.width;
        NSInteger scrollToIndex = self.operatingPageIndex;
        CGFloat percent = 0.0f;
        if (contentCurrentOffset < contentOffsetForCurrentIndex) {
            //向左滚
            if (scrollView.dragging) {
                scrollToIndex = scrollToIndex - 1;
            }
            if (scrollView.decelerating) {
                scrollToIndex = self.targetPageIndex;
            }
            percent = (contentOffsetForCurrentIndex - contentCurrentOffset) / viewSize.width;
        }
        else if(contentCurrentOffset > contentOffsetForCurrentIndex){
            //向右滚
            percent = (contentCurrentOffset - contentOffsetForCurrentIndex) / viewSize.width;
            if (scrollView.dragging) {
                scrollToIndex = scrollToIndex + 1;
            }
            if (scrollView.decelerating) {
                scrollToIndex = self.targetPageIndex;
            }
        }
        else {
            
        }
        if (scrollToIndex != self.operatingPageIndex) {
            percent = percent / fabs(scrollToIndex - self.operatingPageIndex);
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(viewControllerPageNode:scrollTo:byPercent:)]) {
            NSLog(@"targetIndex:%zd, percent:%f", scrollToIndex, percent);
            [self.delegate viewControllerPageNode:self scrollTo:scrollToIndex byPercent:percent];
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    self.targetPageIndex = (*targetContentOffset).x / scrollView.frame.size.width;
    
    self.currentPageIndex = self.targetPageIndex;
    if (self.delegate!=nil&&[self.delegate respondsToSelector:@selector(viewControllerPageNode:didSelectViewControllerAtIndex:)]) {
        [self.delegate viewControllerPageNode:self didSelectViewControllerAtIndex:self.targetPageIndex];
    }
}



- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.operatingPageIndex = self.pagerNode.currentPageIndex;
}

- (void)collectionView:(ASCollectionView *)collectionView willDisplayNodeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.delegate!=nil&&[self.delegate respondsToSelector:@selector(viewControllerPageNode:willDisplayViewControllerAtIndex:)]) {
        [self.delegate viewControllerPageNode:self willDisplayViewControllerAtIndex:indexPath.item];
    }
    
//    if (self.finishedNode && [indexPath compare:self.finishedIndexPath] == NSOrderedSame) {
//        
//        [self.finishedSuperView addSubnode:self.finishedNode];
//    }
}

-(void)collectionView:(ASCollectionView *)collectionView didEndDisplayingNode:(ASCellNode *)node forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate!=nil&&[self.delegate respondsToSelector:@selector(viewControllerPageNode:didEndDisplayingViewControllerAtIndex:)]) {
        [self.delegate viewControllerPageNode:self didEndDisplayingViewControllerAtIndex:indexPath.item];
    }
//    self.finishedNode = node;
//    self.finishedIndexPath = indexPath;
//    self.finishedSuperView = node.view.superview;
//    [node removeFromSupernode];
}

- (void)reloadDataWithCompletion:(void (^)(void))completion {
    NSInteger previousIndex = self.currentPageIndex;
    [self.pagerNode reloadDataWithCompletion:completion];
}
@end
