//
//  UIViewController+EmptyState.m
//  TimeFaceDemoProject
//
//  Created by zguanyu on 16/8/25.
//  Copyright © 2016年 Summer. All rights reserved.
//

#import "UIViewController+EmptyState.h"
#import "NSObject+TFCore.h"
#import "TFStyle.h"
#import "TFCoreFoundationMacro.h"
#import "TFDefaultStyle.h"

@implementation UIViewController (EmptyState)

#pragma mark - View State Getter
- (void)setTf_viewState:(NSInteger)tf_viewState {
    [self tf_setAssociateValue:@(tf_viewState) withKey:@selector(setTf_viewState:)];
}
- (NSInteger)tf_viewState {
    return [[self tf_getAssociatedValueForKey:@selector(setTf_viewState:)] integerValue];
}


- (void)tf_showStateView:(NSInteger)viewState inView:(UIView *)view{
    if (!view.emptyDataSetDelegate) {
        view.emptyDataSetSource = self;
        view.emptyDataSetDelegate = self;
    }
    if (self.tf_viewState == viewState) {
        return;
    }
    self.tf_viewState = viewState;
    [view reloadEmptyDataSet];
}

- (void)tf_showStateView:(NSInteger)viewState {
    [self tf_showStateView:viewState inView:self.view];
}

- (void)tf_removeStateViewInView:(UIView *)view {
    self.tf_viewState = kTFViewStateNone;
    [view.emptyDataSetView removeFromSuperview];
}

- (void)tf_removeStateView {
    self.tf_viewState = kTFViewStateNone;
    [self.view.emptyDataSetView removeFromSuperview];
}

- (BOOL)emptyDataSetShouldDisplay:(UIView *)view {
    if (self.tf_viewState == kTFViewStateNone) {
        return NO;
    }
    return YES;
}

#pragma mark - Default EmptyDataSetSource Methods

- (UIImage *)imageForEmptyDataSet:(UIView *)view
{
    UIImage* image = nil;
    if (self.tf_viewState == kTFViewStateDataError) {
        image =[UIImage imageNamed:TFSTYLEVAR(viewStateDataErrorImage)];
    }
    if (self.tf_viewState == kTFViewStateLoading) {
        image = TFSTYLEVAR(viewStateDataLoadingImage);
    }
    if (self.tf_viewState == kTFViewStateNetError) {
        image =[UIImage imageNamed:TFSTYLEVAR(viewStateDataNetErrorImage)];
    }
    if (self.tf_viewState == kTFViewStateNoData) {
        image =[UIImage imageNamed:TFSTYLEVAR(viewStateDataNoDataImage)];
    }
    if (self.tf_viewState == kTFViewStateTimeOut) {
        image =[UIImage imageNamed:TFSTYLEVAR(viewStateDataNetErrorImage)];
    }
    return image;
}
- (NSAttributedString *)attributeTitleForEmptyDataSet:(UIView *)view
{
    NSString *title = [self titleForEmptyDataSet:view];
    if (title) {
        return [[NSAttributedString alloc]initWithString:title attributes:TFSTYLEVAR(viewStateTitleAttributes)];
    }
    if (self.tf_viewState == kTFViewStateDataError) {
        title = TFSTYLEVAR(viewStateDataErrorTitle);
    }
    if (self.tf_viewState == kTFViewStateLoading) {
        title = TFSTYLEVAR(viewStateDataLoadingTitle);
    }
    if (self.tf_viewState == kTFViewStateNetError) {
        title = TFSTYLEVAR(viewStateDataNetErrorTitle);
    }
    if (self.tf_viewState == kTFViewStateNoData) {
        title = TFSTYLEVAR(viewStateDataNoDataTitle);
    }
    if (self.tf_viewState == kTFViewStateTimeOut) {
        title = TFSTYLEVAR(viewStateDataTimeOutTitle);
    }
    
    return [[NSAttributedString alloc]initWithString:title attributes:TFSTYLEVAR(viewStateTitleAttributes)];
}

- (NSAttributedString *)attributeButtonTitleForEmptyDataSet:(UIView *)view forState:(UIControlState)state
{
    NSString *title = [self buttonTitleForEmptyDataSet:view forState:state];
    if (title) {
        return [[NSMutableAttributedString alloc] initWithString:title attributes:TFSTYLEVAR(viewStateButtonTitleAttributes)];
    }
    if (self.tf_viewState == kTFViewStateDataError) {
        title = TFSTYLEVAR(viewStateDataErrorButtonTitle);
    }
    if (self.tf_viewState == kTFViewStateLoading) {
        return nil;
    }
    if (self.tf_viewState == kTFViewStateNetError) {
        
        title = TFSTYLEVAR(viewStateDataNetErrorButtonTitle);
    }
    if (self.tf_viewState == kTFViewStateNoData) {
        title = TFSTYLEVAR(viewStateDataNoDataButtonTitle);
    }
    if (self.tf_viewState == kTFViewStateTimeOut) {
        title = TFSTYLEVAR(viewStateDataErrorButtonTitle);
    }
    
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:title attributes:TFSTYLEVAR(viewStateButtonTitleAttributes)];
    return attributedTitle;
}

- (CGSize)buttonSizeForEmptyDataSet:(UIView *)view {
    return TFSTYLEVAR(viewStateButtonSize);
}

- (UIColor *)buttonBackgroundColorForEmptyDataSet:(UIView *)view {
    return TFSTYLEVAR(viewStateButtonBackgroundColor);
}

- (CGFloat)buttonCornerRadiusForEmptyDataSet:(UIView *)view {
    return TFSTYLEVAR(viewStateButtonCornerRadius);
}

- (UIColor *)buttonBorderColorForEmptyDataSet:(UIView *)view {
    return TFSTYLEVAR(viewStateButtonBorderColor);
}

- (CGFloat)buttonBorderWidthForEmptyDataSet:(UIView *)view {
    return TFSTYLEVAR(viewStateButtonBorderWidth);
}

- (NSString *)titleForEmptyDataSet:(UIView *)view {
    return nil;
}

- (NSString*)descriptionForEmptyDataSet:(UIView *)view {
    return nil;
}

- (NSString *)buttonTitleForEmptyDataSet:(UIView *)view forState:(UIControlState)state {
    return nil;
}

- (NSAttributedString *)attributeDescriptionForEmptyDataSet:(UIView *)view {
    NSString* desc = [self descriptionForEmptyDataSet:view];
    if (desc) {
        return [[NSAttributedString alloc]initWithString:desc attributes:TFSTYLEVAR(viewStateDescptionAttributes)];
    }
    return nil;
}

-(UIColor *)backgroundColorForEmptyDataSet:(UIView *)view {
    return TFSTYLEVAR(viewStateBackgroundColor);
}




@end
