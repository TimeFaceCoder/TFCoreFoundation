//
//  UIWindow+TFNavigator.h
//  TFNavigator
//
//  Created by Melvin on 4/1/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (TFNavigator)

- (UIViewController *)visibleViewController;

@end

///--------------------------------
/// @name UIViewController Category
///--------------------------------

@interface UIViewController (TFRouter)

@property (nonatomic, strong) NSDictionary *params;

@end
