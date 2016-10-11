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
@end




@implementation TFViewControllerPageNode

-(ASPagerNode *)pagerNode
{
    if (!_pagerNode) {
        _pagerNode = [[ASPagerNode alloc]init];
        _pagerNode.delegate = self;
        _pagerNode.dataSource = self;
        ASRangeTuningParameters fullRenderParams = { .leadingBufferScreenfuls = 0.0, .trailingBufferScreenfuls = 0.0 };
        ASRangeTuningParameters fullPreloadParams = { .leadingBufferScreenfuls = 0.0, .trailingBufferScreenfuls = 0.0 };
        [_pagerNode setTuningParameters:fullRenderParams forRangeType:ASLayoutRangeTypeDisplay];
        [_pagerNode setTuningParameters:fullPreloadParams forRangeType:ASLayoutRangeTypePreload];
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
    return ^{
        //1. ASCellNode->ASDisplayNode(UIViewController.view) : VC的root view会被包装成一个node,然后被加入到cellNode中
        //2. UIViewController的生命周期:基本上跟CollectionView的cell重用机制一样，只有当前显示的,刚才显示的和将要显示的才会被加载
        ASCellNode *page = [[ASCellNode alloc] initWithViewControllerBlock:^UIViewController * _Nonnull{
            if (self.delegate!=nil&&[self.delegate respondsToSelector:@selector(viewControllerPageNode:viewControllerAtIndex:)]) {
                return [self.delegate viewControllerPageNode:self viewControllerAtIndex:index];
            }
            else{
                return nil;
            }
        } didLoadBlock:^(ASDisplayNode * _Nonnull node) {
            
        }];
        //3. 设置page的大小，如果设置为pagerNode大小，那么每页一个VC，如果设置为一半大小，那么每页两个
        page.preferredFrameSize = self.savedFrame.size;
        return page;
    };
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.currentPageIndex = self.pagerNode.currentPageIndex;
    if (self.delegate!=nil&&[self.delegate respondsToSelector:@selector(viewControllerPageNode:didSelectViewControllerAtIndex:)]) {
        [self.delegate viewControllerPageNode:self didSelectViewControllerAtIndex:self.currentPageIndex];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGSize contentSize = scrollView.contentSize;
    CGSize viewSize = scrollView.frame.size;
    
    CGFloat contentCurrentOffset = scrollView.contentOffset.x;
    
    if (self.delegate!=nil&&[self.delegate respondsToSelector:@selector(viewControllerPageNode:didScrollContentOffset:inContentWidth:viewWidth:)]) {
        [self.delegate viewControllerPageNode:self didScrollContentOffset:contentCurrentOffset inContentWidth:contentSize.width viewWidth:viewSize.width];
    }
    
}

- (void)collectionView:(ASCollectionView *)collectionView willDisplayNodeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.delegate!=nil&&[self.delegate respondsToSelector:@selector(viewControllerPageNode:willDisplayViewControllerAtIndex:)]) {
        [self.delegate viewControllerPageNode:self willDisplayViewControllerAtIndex:indexPath.item];
    }
    if (self.finishedNode && [indexPath compare:self.finishedIndexPath] == NSOrderedSame) {
        //        UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
        [self.finishedSuperView addSubnode:self.finishedNode];
    }
}

-(void)collectionView:(ASCollectionView *)collectionView didEndDisplayingNode:(ASCellNode *)node forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate!=nil&&[self.delegate respondsToSelector:@selector(viewControllerPageNode:willDisplayViewControllerAtIndex:)]) {
        [self.delegate viewControllerPageNode:self didEndDisplayingViewControllerAtIndex:indexPath.item];
    }
    self.finishedNode = node;
    self.finishedIndexPath = indexPath;
    self.finishedSuperView = node.view.superview;
    [node removeFromSupernode];
}

- (void)dealloc {
    
}

@end
