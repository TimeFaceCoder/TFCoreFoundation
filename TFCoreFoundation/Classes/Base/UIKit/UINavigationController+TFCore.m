//
//  UINavigationController+TFCore.m
//  TFCoreFoundation
//
//  Created by Melvin on 4/13/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "UINavigationController+TFCore.h"
#import "UIViewController+TFCore.h"
#import <objc/runtime.h>
#import "TFSwizzleMethod.h"
#import "TFCoreFoundationMacro.h"

TFSYNTH_DUMMY_CLASS(UINavigationController_TFCore)

@implementation UINavigationController (TFCore)

- (void)popToViewControllerWithClass:(Class)popClass animated:(BOOL)animated{
    NSArray *viewControllers = self.viewControllers;
    for (NSInteger i=0; i < viewControllers.count-1; i++) {
        UIViewController *viewController = viewControllers[i];
        if ([viewController isKindOfClass:popClass]) {
            [self popToViewController:viewController animated:animated];
            return;
        }
    }
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if([self.viewControllers count] < [navigationBar.items count]) {
        return YES;
    }
//    item.backBarButtonItem setBackButtonBackgroundImage:item.backBarButtonItem forState:<#(UIControlState)#> barMetrics:<#(UIBarMetrics)#>
    BOOL shouldPop = YES;
    UIViewController* vc = [self topViewController];
    if ([vc respondsToSelector:@selector(tf_navigationBarBackItemDidClick)]) {
        shouldPop = [vc tf_navigationBarBackItemDidClick];
    }
    if(shouldPop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self popViewControllerAnimated:YES];
        });
    }
    return shouldPop;
}




@end
