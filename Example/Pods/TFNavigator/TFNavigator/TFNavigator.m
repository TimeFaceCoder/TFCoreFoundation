//
//  TFNavigator.m
//  TFNavigator
//
//  Created by Melvin on 3/31/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFNavigator.h"
#import "TFRouter.h"
#import "TFURLAction.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
UIViewController * TFOpenURL(NSString* URL ,NSDictionary *userInfo) {
    return [[TFNavigator sharedNavigator] openURLAction:[TFURLAction actionWithURLPath:URL userInfo:userInfo]];
}

UIViewController * TFOpenStoryboardURL(NSString* URL ,NSString * storyboardName ,NSDictionary *userInfo) {
    TFURLAction *urlAction = [TFURLAction actionWithURLPath:URL userInfo:userInfo];
    urlAction.storyboardName = storyboardName;
    return [[TFNavigator sharedNavigator] openURLAction:urlAction];
}

@interface TFNavigator() {
    
}

@property (nonnull ,copy) NSString *webViewRouter;

@end

@implementation TFNavigator

+ (instancetype)sharedNavigator {
    static TFNavigator *navigator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!navigator) {
            navigator = [[self alloc] init];
        }
    });
    return navigator;
}

#pragma mark - Public

- (void)map:(NSString *)route toControllerClass:(Class)controllerClass {
    [[TFRouter shared] map:route toControllerClass:controllerClass];
}

- (void)registeredWebViewController:(NSString *)route toControllerClass:(Class)controllerClass {
    self.webViewRouter = route;
    [[TFRouter shared] map:route toControllerClass:controllerClass];
}


- (UIViewController *)openURLAction:(TFURLAction *)action {
    if (action == nil || action.urlPath == nil) {
        return nil;
    }
    //third-party app
    NSURL *URL = [NSURL URLWithString:action.urlPath];
    if ([self isAppURL:URL]) {
        [[UIApplication sharedApplication] openURL:URL];
        return nil;
    }
    if ([self isWebURL:URL]) {
        //web url check
        if (_webViewRouter) {
            //use registered WebView  open the web url
            TFOpenURL(self.webViewRouter, @{@"url":URL});
        }
        else {
            //use safari open the web url
            [[UIApplication sharedApplication] openURL:URL];
        }
    }
    UIViewController *viewController;
    if (action.storyboardName.length!=0) {
        viewController = [self matchController:action.urlPath storyboardName:action.storyboardName userInfo:action.userInfo];
    }
    else {
        viewController = [self matchController:action.urlPath userInfo:action.userInfo];
    }
    if (!viewController) {
        return nil;
    }
    //open viewcontroller
    UIViewController *currentController = [[[UIApplication sharedApplication] keyWindow] visibleViewController];
    if (currentController) {
        if (action.transitioningDelegate) {
            viewController.transitioningDelegate = action.transitioningDelegate;
            viewController.modalPresentationStyle = UIModalPresentationCustom;
        }
        if (action.presentModel) {
            UIViewController *vc = nil;
            
            if (viewController.navigationController) {
                vc = viewController;
            }
            else {
                action.navigationViewControllerClass = action.navigationViewControllerClass ? : [UINavigationController class];
                vc = [[action.navigationViewControllerClass alloc] initWithRootViewController:viewController];
            }
            
            [currentController presentViewController:vc
                                            animated:YES
                                          completion:^{
                                              if (action.actionCompletionBlock) {
                                                  action.actionCompletionBlock(action);
                                                  action.actionCompletionBlock = nil;
                                              }
                                          }];
        }
        else {
            viewController.hidesBottomBarWhenPushed = YES;
            NSNumber *replaceIndex = action.userInfo[kOpenURLViewControllerIndexKey];
            if (replaceIndex) {
                NSArray *viewControllersArr = currentController.navigationController.viewControllers;
                viewControllersArr = [viewControllersArr subarrayWithRange:NSMakeRange(0, viewControllersArr.count-[replaceIndex integerValue])];
                
                [currentController.navigationController setViewControllers:[viewControllersArr arrayByAddingObject:viewController] animated:YES];
            }
            else {
                [currentController.navigationController pushViewController:viewController
                                                                animated:YES];
            }
        }
    }
    return viewController;
}


- (UIViewController *)matchController:(NSString *)route {
    return [self matchController:route userInfo:nil];
}
- (UIViewController *)matchController:(NSString *)route userInfo:(NSDictionary *)userInfo {
    UIViewController *viewController = [[TFRouter shared] matchController:route userInfo:userInfo];
    return viewController;
}

- (UIViewController *)matchController:(NSString *)route storyboardName:(NSString *)storyboardName userInfo:(NSDictionary *)userInfo {
    UIViewController *viewController = [[TFRouter shared]matchController:route storyboardName:storyboardName userInfo:userInfo];
    return viewController;
}

#pragma mark - Private

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isAppURL:(NSURL*)URL {
    return [self isExternalURL:URL]
    || ([[UIApplication sharedApplication] canOpenURL:URL]
        && ![self isWebURL:URL]);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isWebURL:(NSURL*)URL {
    return !URL.scheme ? NO : [URL.scheme caseInsensitiveCompare:@"http"] == NSOrderedSame
    || [URL.scheme caseInsensitiveCompare:@"https"] == NSOrderedSame
    || [URL.scheme caseInsensitiveCompare:@"ftp"] == NSOrderedSame
    || [URL.scheme caseInsensitiveCompare:@"ftps"] == NSOrderedSame
    || [URL.scheme caseInsensitiveCompare:@"data"] == NSOrderedSame
    || [URL.scheme caseInsensitiveCompare:@"file"] == NSOrderedSame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isExternalURL:(NSURL*)URL {
    if ([URL.host isEqualToString:@"maps.google.com"]
        || [URL.host isEqualToString:@"itunes.apple.com"]
        || [URL.host isEqualToString:@"phobos.apple.com"]) {
        return YES;
        
    } else {
        return NO;
    }
}


@end

