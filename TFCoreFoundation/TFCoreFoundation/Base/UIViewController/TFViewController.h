//
//  TFViewController.h
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TFNavigator/TFNavigator.h>
#import "TFStateView.h"
#import "UIViewController+Toast.h"
#import "UIViewController+EmptyState.h"



@interface TFViewController : UIViewController

@property (nonatomic ,strong) NSMutableDictionary *requestParams;


- (void)showStateView:(NSInteger)viewState;

- (void)removeStateView;


@end
