//
//  ASNavigationController.m
//  Pods
//
//  Created by Garrett Moon on 4/27/16.
//
//

#import "ASNavigationController.h"

@implementation ASNavigationController
{
  BOOL _parentManagesVisibilityDepth;
  NSInteger _visibilityDepth;
}

ASVisibilityDidMoveToParentViewController;

ASVisibilityViewWillAppear;

ASVisibilityViewDidDisappearImplementation;

ASVisibilitySetVisibilityDepth;

ASVisibilityDepthImplementation;

- (void)visibilityDepthDidChange
{
  for (UIViewController *viewController in self.viewControllers) {
    if ([viewController conformsToProtocol:@protocol(ASVisibilityDepth)]) {
      [(id <ASVisibilityDepth>)viewController visibilityDepthDidChange];
    }
  }
}

- (NSInteger)visibilityDepthOfChildViewController:(UIViewController *)childViewController
{
  NSUInteger viewControllerIndex = [self.viewControllers indexOfObject:childViewController];
  NSAssert(viewControllerIndex != NSNotFound, @"childViewController is not in the navigation stack.");
  
  if (viewControllerIndex == self.viewControllers.count - 1) {
    //view controller is at the top, just return our own visibility depth.
    return [self visibilityDepth];
  } else if (viewControllerIndex == 0) {
    //view controller is the root view controller. Can be accessed by holding the back button.
    return [self visibilityDepth] + 1;
  }
  
  return [self visibilityDepth] + self.viewControllers.count - 1 - viewControllerIndex;
}

#pragma mark - UIKit overrides

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
  NSArray *viewControllers = [super popToViewController:viewController animated:animated];
  [self visibilityDepthDidChange];
  return viewControllers;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
  NSArray *viewControllers = [super popToRootViewControllerAnimated:animated];
  [self visibilityDepthDidChange];
  return viewControllers;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
  [super setViewControllers:viewControllers];
  [self visibilityDepthDidChange];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
  [super setViewControllers:viewControllers animated:animated];
  [self visibilityDepthDidChange];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
  [super pushViewController:viewController animated:animated];
  [self visibilityDepthDidChange];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
  UIViewController *viewController = [super popViewControllerAnimated:animated];
  [self visibilityDepthDidChange];
  return viewController;
}

@end
