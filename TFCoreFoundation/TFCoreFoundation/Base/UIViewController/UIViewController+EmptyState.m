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
NSInteger const tf_kTFViewStateNone            = 0;
NSInteger const tf_kTFViewStateLoading         = 1;
NSInteger const tf_kTFViewStateNetError        = 2;
NSInteger const tf_kTFViewStateDataError       = 3;
NSInteger const tf_kTFViewStateNoData          = 4;
NSInteger const tf_kTFViewStateTimeOut         = 5;
NSInteger const tf_kTFViewStateLocationError   = 6;
NSInteger const tf_kTFViewStatePhotosError     = 7;
NSInteger const tf_kTFViewStateMicrophoneError = 8;
NSInteger const tf_kTFViewStateCameraError     = 9;
NSInteger const tf_kTFViewStateContactsError   = 10;


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

- (BOOL)emptyDataSetShouldDisplay:(UIView *)view {
    if (self.tf_viewState == tf_kTFViewStateNone) {
        return NO;
    }
    return YES;
}

#pragma mark - Default EmptyDataSetSource Methods

- (UIImage *)imageForEmptyDataSet:(UIView *)view
{
    UIImage* image = nil;
    if (self.tf_viewState == tf_kTFViewStateDataError) {
        image =[UIImage imageNamed:TFSTYLEVAR(viewStateDataErrorImage)];
    }
    if (self.tf_viewState == tf_kTFViewStateLoading) {
    }
    if (self.tf_viewState == tf_kTFViewStateNetError) {
        image =[UIImage imageNamed:TFSTYLEVAR(viewStateDataNetErrorImage)];
    }
    if (self.tf_viewState == tf_kTFViewStateNoData) {
        image =[UIImage imageNamed:TFSTYLEVAR(viewStateDataNoDataImage)];
    }
    if (self.tf_viewState == tf_kTFViewStateTimeOut) {
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
    if (self.tf_viewState == tf_kTFViewStateDataError) {
        title = TFSTYLEVAR(viewStateDataErrorTitle);
    }
    if (self.tf_viewState == tf_kTFViewStateLoading) {
        title = TFSTYLEVAR(viewStateDataLoadingTitle);
    }
    if (self.tf_viewState == tf_kTFViewStateNetError) {
        title = TFSTYLEVAR(viewStateDataNetErrorTitle);
    }
    if (self.tf_viewState == tf_kTFViewStateNoData) {
        title = TFSTYLEVAR(viewStateDataNoDataTitle);
    }
    if (self.tf_viewState == tf_kTFViewStateTimeOut) {
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
    if (self.tf_viewState == tf_kTFViewStateDataError) {
        title = TFSTYLEVAR(viewStateDataErrorButtonTitle);
    }
    if (self.tf_viewState == tf_kTFViewStateLoading) {
        
    }
    if (self.tf_viewState == tf_kTFViewStateNetError) {
        
        title = TFSTYLEVAR(viewStateDataNetErrorButtonTitle);
    }
    if (self.tf_viewState == tf_kTFViewStateNoData) {
        title = TFSTYLEVAR(viewStateDataNoDataButtonTitle);
    }
    if (self.tf_viewState == tf_kTFViewStateTimeOut) {
        title = TFSTYLEVAR(viewStateDataErrorButtonTitle);
    }
    
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:title attributes:TFSTYLEVAR(viewStateButtonTitleAttributes)];
    return attributedTitle;
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
