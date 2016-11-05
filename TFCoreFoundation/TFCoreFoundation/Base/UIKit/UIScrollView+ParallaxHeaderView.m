//
//  UIScrollView+ParallaxHeaderView.m
//  ScrollViewParallaxHeaderDemo
//
//  Created by Summer on 2016/9/28.
//  Copyright © 2016年 Summer. All rights reserved.
//

#import "UIScrollView+ParallaxHeaderView.h"
#import <objc/runtime.h>

const void *_ARSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWOFFSET =
&_ARSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWOFFSET;


@class TFScrollViewParallaxHeaderHandler;
@protocol TFScrollViewParallaxHeaderHandlerDelegate <NSObject>

@optional;
- (void)parallaxHeaderHandler:(TFScrollViewParallaxHeaderHandler *)handler headerRatio:(float)headerRatio;

@end

@interface TFScrollViewParallaxHeaderHandler : NSObject

/**
 parallax header view you added.
 */
@property (nonatomic, weak) UIView *parallaxHeaderView;

@property (nonatomic, weak) id<TFScrollViewParallaxHeaderHandlerDelegate> delegate;

@property (nonatomic, assign) CGFloat originParallaxHeaderHeight; // origin height of parallax heade view.

@property (nonatomic, assign) CGFloat minParallaxHeaderHeight;// min height of parallax header view, default is 0.0.

/**
 Initialization a TFScrollViewParallaxHandler with parallax header view.
 
 @param scrollView want to add parallax header.
 @param headerView      headerView header view want to be parallactic.
 @param minHeaderHeight constant min height of header view.
 
 @return TFScrollViewParallaxHandler.
 */
- (instancetype)initParallaxHeaderHandlerWithScrollView:(__kindof UIScrollView *)scrollView
                                  headerView:(__kindof UIView *)headerView
                             minHeaderHeight:(CGFloat)minHeaderHeight;


@end


@implementation TFScrollViewParallaxHeaderHandler

#pragma mark - init methods.

- (instancetype)initParallaxHeaderHandlerWithScrollView:(__kindof UIScrollView *)scrollView headerView:(__kindof UIView *)headerView minHeaderHeight:(CGFloat)minHeaderHeight {
    self = [super init];
    if (self) {
        self.parallaxHeaderView = headerView;
        self.delegate = scrollView;
        headerView.clipsToBounds = YES;
        headerView.contentMode = UIViewContentModeScaleAspectFill;
        //设置默认常量和变量
        self.originParallaxHeaderHeight = CGRectGetHeight(headerView.frame);
        self.minParallaxHeaderHeight = minHeaderHeight;
        scrollView.contentInset = UIEdgeInsetsMake(self.originParallaxHeaderHeight, 0, 0, 0);
        [scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:&_ARSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWOFFSET];
        
        [scrollView addSubview:headerView];
    }
    return self;
}

#pragma mark - ObserScrollViewContentOffset

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (self.parallaxHeaderView && context == _ARSEGMENTPAGE_CURRNTPAGE_SCROLLVIEWOFFSET) {
        CGRect lastHeaderFrame = self.parallaxHeaderView.frame;
        CGFloat currentOffsetY = [change[NSKeyValueChangeNewKey] CGPointValue].y;
        CGFloat currentHeaderHeight = - currentOffsetY;
        if (currentHeaderHeight <= self.minParallaxHeaderHeight) {
            currentHeaderHeight = self.minParallaxHeaderHeight;
        }
        lastHeaderFrame.size.height = currentHeaderHeight;
        lastHeaderFrame.origin.y = currentOffsetY;
        CGFloat ratio = (currentHeaderHeight - self.minParallaxHeaderHeight)/(self.originParallaxHeaderHeight - self.minParallaxHeaderHeight);
        if ([self.delegate respondsToSelector:@selector(parallaxHeaderHandler:headerRatio:)]) {
            [self.delegate parallaxHeaderHandler:self headerRatio:ratio];
        }
        self.parallaxHeaderView.frame = lastHeaderFrame;
    }
}

- (void)dealloc {
    NSLog(@"\n******************************************\n %s---line:%d \n******************************************",__func__,__LINE__);
}

@end


static char *kParallaxHeaderHandlerKey = "ParallaxHeaderHandler";

static char *kParallaxChangeBlockKey = "ParallaxChangeBlockKey";

static char *kParallaxHeaderViewKey = "ParallaxHeaderViewKey";


@interface UIScrollView ()<TFScrollViewParallaxHeaderHandlerDelegate>

@property (nonatomic, strong) TFScrollViewParallaxHeaderHandler *headerHandler;

@property (nonatomic, strong, readwrite) UIView *parallaxHeaderView;

@end

@implementation UIScrollView (ParallaxHeaderView)

- (void)addParallaxHeaderView:(__kindof UIView *)headerView {
    [self addParallaxHeaderView:headerView minHeaderHeight:0.0];
}

- (void)addParallaxHeaderWithImageName:(NSString *)imageName{
    [self addParallaxHeaderWithImageName:imageName minHeaderHeight:0.0];
}

- (void)addParallaxHeaderWithImageName:(NSString *)imageName minHeaderHeight:(CGFloat)minHeaderHeight {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    CGFloat imageViewWidth = CGRectGetWidth(self.frame);
    CGSize imageSize = imageView.image.size;
    imageView.frame = CGRectMake(0, 0, imageViewWidth, (imageSize.height * imageViewWidth)/imageSize.width);
    [self addParallaxHeaderView:imageView minHeaderHeight:minHeaderHeight];
}

- (void)addParallaxHeaderView:(__kindof UIView *)headerView minHeaderHeight:(CGFloat)minHeaderHeight{
    self.parallaxHeaderView = headerView;
    self.headerHandler = [[TFScrollViewParallaxHeaderHandler alloc] initParallaxHeaderHandlerWithScrollView:self headerView:headerView minHeaderHeight:minHeaderHeight];
    
    // use swizzle to remove observer of scrollView.
    [self _swizzleRemoveFromeSuperViewMethodToRemoveObserver];
}

- (void)_swizzleRemoveFromeSuperViewMethodToRemoveObserver {
    SEL originalSelector = @selector(removeFromSuperview);
    SEL swizzledSelector = @selector(removeFromSuperviewAndObserver);
    
    Class cls = [self class];
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(cls,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(cls,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)removeFromSuperviewAndObserver {
    
    if (self.headerHandler) {
        [self removeObserver:self.headerHandler forKeyPath:NSStringFromSelector(@selector(contentOffset))];
    }
    [self removeFromSuperviewAndObserver];
}

#pragma mark - TFScrollViewParallaxHeaderHandlerDelegate

- (void)parallaxHeaderHandler:(TFScrollViewParallaxHeaderHandler *)handler headerRatio:(float)headerRatio {
    if (self.headerHeightChangeBlock) {
        self.headerHeightChangeBlock(self.headerHandler.parallaxHeaderView,handler.originParallaxHeaderHeight,headerRatio);
    }
}


#pragma mark - custom properties.

- (void)setHeaderHandler:(TFScrollViewParallaxHeaderHandler *)headerHandler {
    objc_setAssociatedObject(self, kParallaxHeaderHandlerKey, headerHandler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TFScrollViewParallaxHeaderHandler *)headerHandler {
    return objc_getAssociatedObject(self, kParallaxHeaderHandlerKey);
}

- (void)setHeaderHeightChangeBlock:(TFParallaxHeaderChangeBlock )headerHeightChangeBlock {
    objc_setAssociatedObject(self, kParallaxChangeBlockKey, headerHeightChangeBlock, OBJC_ASSOCIATION_COPY);
}

- (TFParallaxHeaderChangeBlock)headerHeightChangeBlock {
    return objc_getAssociatedObject(self, kParallaxChangeBlockKey);
}

- (void)setParallaxHeaderView:(UIView *)parallaxHeaderView {
    objc_setAssociatedObject(self, kParallaxHeaderViewKey, parallaxHeaderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)parallaxHeaderView {
    return objc_getAssociatedObject(self, kParallaxHeaderViewKey);
}

@end
