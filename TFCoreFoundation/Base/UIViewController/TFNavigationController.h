//
//  TFNavigationController.h
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TFNavigationControllerNavigationBarVisibility) {
    TFNavigationControllerNavigationBarVisibilityUndefined = 0, // Initial value, don't set this
    TFNavigationControllerNavigationBarVisibilitySystem = 1, // Use System navigation bar
    TFNavigationControllerNavigationBarVisibilityHidden = 2, // Use custom navigation bar and hide it
    TFNavigationControllerNavigationBarVisibilityVisible = 3 // Use custom navigation bar and show it
};

@protocol TFNavigationControllerDelegate <NSObject>

/**
 You should give back the correct enum value if the controller asks you
 */
- (TFNavigationControllerNavigationBarVisibility)preferredNavigationBarVisibility;

@end

@interface TFNavigationController : UINavigationController

@property (nonatomic ,assign) BOOL canDragBack;

- (void)setNeedsNavigationBarVisibilityUpdateAnimated:(BOOL)animated;

@end
