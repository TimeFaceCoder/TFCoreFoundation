//
//  TFStateView.h
//  TFCoreFoundation
//
//  Created by Melvin on 4/11/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FLAnimatedImage;
@class FLAnimatedImageView;

@protocol TFStateViewDataSource <NSObject>

@optional
- (NSAttributedString *)titleForStateView:(UIView *)view;
- (NSAttributedString *)descriptionForStateView:(UIView *)view;
- (UIImage *)imageForStateView:(UIView *)view;
- (FLAnimatedImage *)animationImageForStateView:(UIView *)view;
- (NSArray *)imagesForStateView:(UIView *)view;
- (UIView *)customViewForStateView:(UIView *)view;


- (NSAttributedString *)buttonTitleForStateView:(UIView *)view forState:(UIControlState)state;
- (UIImage *)buttonBackgroundImageForStateView:(UIView *)view forState:(UIControlState)state;
- (UIColor *)buttonBackgroundColorForStateView:(UIView *)view;
- (CGFloat)buttonCornerRadiusForStateView:(UIView *)view;
- (UIColor *)buttonBorderColorForStateView:(UIView *)view;
- (CGSize)buttonSizeForStateView:(UIView *)view;
- (UIColor *)backgroundColorForStateView:(UIView *)view;
- (CGPoint)offsetForStateView:(UIView *)view;
- (CGRect)frameForStateView:(UIView *)view;
- (CGFloat)spaceHeightForStateView:(UIView *)view;


@end

@protocol TFStateViewDelegate <NSObject>
@optional

- (BOOL)stateViewShouldDisplay:(UIView *)view;
- (BOOL)stateViewShouldAllowTouch:(UIView *)view;
- (BOOL)stateViewShouldAllowScroll:(UIView *)view;
- (void)stateViewDidTapView:(UIView *)view;
- (void)stateViewDidTapButton:(UIView *)view;
- (void)stateViewWillAppear:(UIView *)view;
- (void)stateViewWillDisappear:(UIView *)view;

@end


@interface TFStateView : UIView

@property (nonatomic, weak) id <TFStateViewDataSource> stateDataSource;

@property (nonatomic, weak) id <TFStateViewDelegate> stateDelegate;

@property (nonatomic, readonly, getter = isStateVisible) BOOL stateVisible;


/**
 *  显示 StateView
 */
- (void)showStateView;
/**
 *  移除 StateView
 */
- (void)removeStateView;

@end
