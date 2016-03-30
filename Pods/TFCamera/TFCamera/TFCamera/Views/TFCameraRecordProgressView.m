//
//  TFCameraRecordProgressView.m
//  TFCamera
//
//  Created by Melvin on 7/22/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "TFCameraRecordProgressView.h"
#import "TFCameraColor.h"
#import <Masonry/Masonry.h>
#import <pop/POP.h>

@implementation TFCameraRecordProgressView {
    UIView      *_statusView;
    UIView      *_progressBarView;
    NSTimeInterval _barAnimationDuration;
    NSTimeInterval _fadeAnimationDuration;
    NSTimeInterval _fadeOutDelay;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureViews];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self configureViews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

-(void)configureViews {
    self.userInteractionEnabled = NO;
    _progressBarView = [[UIView alloc] init];
    _progressBarView.backgroundColor = [TFCameraColor tintColor];
    [self addSubview:_progressBarView];
    [_progressBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(self);
        make.height.mas_equalTo(self);
    }];
    
    _statusView = [[UIView alloc] init];
    _statusView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_statusView];
    [_statusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(self);
        make.width.height.equalTo(self.mas_height);
    }];
    
    _barAnimationDuration = 0.27f;
    _fadeAnimationDuration = 0.27f;
    _fadeOutDelay = 0.1f;
    [self statusAnimation];
}


- (void)setProgressWidth:(CGFloat)progressWidth {
    [UIView animateWithDuration:_barAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         
         CGRect frame = _progressBarView.frame;
         frame.size.width = progressWidth;
         _progressBarView.frame = frame;
         
         CGRect statusFrame = _statusView.frame;
         statusFrame.origin.x = progressWidth;
         _statusView.frame = statusFrame;
     } completion:^(BOOL finished) {
         if (finished) {
             _statusView.alpha = 1;
             CGFloat width = CGRectGetWidth(_progressBarView.frame);
             NSLog(@"self width:%@ progress width:%@",@(CGRectGetWidth(self.frame)),@(width));
             if (width >= CGRectGetWidth(self.frame)) {
                 [_statusView setHidden:YES];
                 for (UIView *blockView in _progressBarView.subviews) {
                     [blockView removeFromSuperview];
                 }
             }
             else {
                 [_statusView setHidden:NO];
             }
         }
     }];
}

- (void)setMinimumWidthLimit:(CGFloat)minimumWidthLimit {
    
}


- (UIView *)blockView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, CGRectGetHeight(self.frame))];
    view.backgroundColor = [UIColor colorWithRed:16/255 green:16/255 blue:16/266 alpha:1];
    return view;
}

- (void)statusAnimation {
    
    POPBasicAnimation *animation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
    animation.toValue = @(!_statusView.alpha);
    animation.duration = 1;
    [animation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
        if (finished) {
            [self statusAnimation];
        }
    }];
    [_statusView pop_addAnimation:animation forKey:@"statusAlphaAnimation"];
}

- (void)startRecord {
    [_statusView pop_removeAnimationForKey:@"statusAlphaAnimation"];
    _statusView.alpha = 1;
}

- (void)stopRecord {
    [self statusAnimation];
    [self insertBlockView];
}

- (void)insertBlockView {
    UIView *blockView = [self blockView];
    CGRect blockFrame = blockView.frame;
    blockFrame.origin.x = _statusView.frame.origin.x;
    blockView.frame = blockFrame;
    NSLog(@"%s",__func__);
    [_progressBarView addSubview:blockView];
}

@end
