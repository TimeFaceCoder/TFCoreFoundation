//
//  TFCameraSlideView.m
//  TFCamera
//
//  Created by Melvin on 7/17/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "TFCameraSlideView.h"

@interface TFCameraSlideView () <TFCameraSlideViewProtocol>

- (void)showWithAnimationAtView:(UIView *)view completion:(void (^)(void))completion;
- (void)hideWithAnimationAtView:(UIView *)view completion:(void (^)(void))completion;

- (void)addSlideToView:(UIView *)view withOriginY:(CGFloat)originY;

- (void)hideWithAnimationAtView:(UIView *)view
               withTimeInterval:(CGFloat)timeInterval
                     completion:(void (^)(void))completion;

- (void)removeSlideFromSuperview:(BOOL)remove
                    withDuration:(CGFloat)duration
                         originY:(CGFloat)originY
                      completion:(void (^)(void))completion;

@end

@implementation TFCameraSlideView

static NSString* const kExceptionName = @"TFCameraSlideViewException";
static NSString* const kExceptionMessage = @"Invoked abstract method";

#pragma mark -
#pragma mark - Public methods

+ (void)showSlideUpView:(TFCameraSlideView *)slideUpView slideDownView:(TFCameraSlideView *)slideDownView atView:(UIView *)view completion:(void (^)(void))completion
{
    [slideUpView addSlideToView:view withOriginY:[slideUpView finalPosition]];
    [slideDownView addSlideToView:view withOriginY:[slideDownView finalPosition]];
    
    [slideUpView removeSlideFromSuperview:NO withDuration:.15f originY:[slideUpView initialPositionWithView:view] completion:nil];
    [slideDownView removeSlideFromSuperview:NO withDuration:.15f originY:[slideDownView initialPositionWithView:view] completion:completion];
}

+ (void)hideSlideUpView:(TFCameraSlideView *)slideUpView slideDownView:(TFCameraSlideView *)slideDownView atView:(UIView *)view completion:(void (^)(void))completion
{
    [slideUpView hideWithAnimationAtView:view withTimeInterval:.6 completion:nil];
    [slideDownView hideWithAnimationAtView:view withTimeInterval:.6 completion:completion];
}

- (void)showWithAnimationAtView:(UIView *)view completion:(void (^)(void))completion
{
    [self addSlideToView:view
             withOriginY:[self finalPosition]];
    
    [self removeSlideFromSuperview:NO
                      withDuration:.15f
                           originY:[self initialPositionWithView:view]
                        completion:completion];
}

- (void)hideWithAnimationAtView:(UIView *)view completion:(void (^)(void))completion
{
    [self hideWithAnimationAtView:view
                 withTimeInterval:.6
                       completion:completion];
}

#pragma mark -
#pragma mark - TFCameraSlideViewProtocol

- (CGFloat)initialPositionWithView:(UIView *)view
{
    [NSException exceptionWithName:kExceptionName
                            reason:kExceptionMessage
                          userInfo:nil];
    
    return 0.;
}

- (CGFloat)finalPosition
{
    [NSException exceptionWithName:kExceptionName
                            reason:kExceptionMessage
                          userInfo:nil];
    
    return 0.;
}

#pragma mark -
#pragma mark - Private methods

- (void)addSlideToView:(UIView *)view withOriginY:(CGFloat)originY
{
    CGFloat width = CGRectGetWidth(view.frame);
    CGFloat height = CGRectGetHeight(view.frame)/2;
    
    CGRect frame = self.frame;
    frame.size.width = width;
    frame.size.height = height;
    frame.origin.y = originY;
    self.frame = frame;
    
    [view addSubview:self];
}

- (void)hideWithAnimationAtView:(UIView *)view withTimeInterval:(CGFloat)timeInterval completion:(void (^)(void))completion
{
    [self addSlideToView:view withOriginY:[self initialPositionWithView:view]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [NSThread sleepForTimeInterval:timeInterval];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeSlideFromSuperview:YES
                              withDuration:.5
                                   originY:[self finalPosition]
                                completion:completion];
        });
    });
}

- (void)removeSlideFromSuperview:(BOOL)remove withDuration:(CGFloat)duration originY:(CGFloat)originY completion:(void (^)(void))completion
{
    CGRect frame = self.frame;
    frame.origin.y = originY;
    
    [UIView animateWithDuration:duration animations:^{
        self.frame = frame;
    } completion:^(BOOL finished) {
        if (finished) {
            if (remove) {
                [self removeFromSuperview];
            }
            
            if (completion) {
                completion();
            }
        }
    }];
}


@end
