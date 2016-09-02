//
//  UIViewController+EmptyState.h
//  TimeFaceDemoProject
//
//  Created by zguanyu on 16/8/25.
//  Copyright © 2016年 Summer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+EmptyDataSet.h"

/**
 *  @brief Adding StateView to UIViewController's arbitrary view.
 You can show title/desc/image/button/gif according to state.
 default state is tf_kTFViewStateNone which shows nothing.
 */
@interface UIViewController (EmptyState)<TFEmptyDataSetDelegate,TFEmptyDataSetSource>
/**
 *  @brief viewState indicate which state the view is.
    viewState is readonly, you can only access it for view purpose.
    If setter is required, use showStateView:inView:, this will set the viewState implicitly. Each UIViewController can only have one viewState.
 */
@property (nonatomic, readonly)NSInteger tf_viewState;

/**
 *  show custom appeareance for viewState in view.
 *  appearance should be customize in dataSource and delegate methods
 *
 *  @param viewState target view state to show, will override current view state.
 *  @param view      the view to apply
 */
- (void)tf_showStateView:(NSInteger)viewState inView:(UIView*)view;


/**
 *  show custom appeareance for viewState in self.view.
 *  appearance should be customize in dataSource and delegate methods
 *
 *  @param viewState target view state to show, will override current view state.
 *  @param
 */
- (void)tf_showStateView:(NSInteger)viewState;


#pragma mark - shortcut for attributed delegate

- (NSString *)titleForEmptyDataSet:(UIView *)view;

- (NSString *)buttonTitleForEmptyDataSet:(UIView *)view forState:(UIControlState)state;

- (NSString *)descriptionForEmptyDataSet:(UIView *)view;
@end
