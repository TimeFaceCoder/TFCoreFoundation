//
//  TFNavigator.h
//  TFNavigator
//
//  Created by Melvin on 3/31/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIWindow+TFNavigator.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
void TFOpenURL(NSString *URL ,NSDictionary *userInfo);

@class TFURLAction;

@interface TFNavigator : NSObject

+ (instancetype)sharedNavigator;
/**
 *  注册Controller
 *
 *  @param route
 *  @param controllerClass
 */
- (void)map:(NSString *)route toControllerClass:(Class)controllerClass;
/**
 *  注册app webview controller
 *
 *  @param route           路由
 *  @param controllerClass Class
 */
- (void)registeredWebViewController:(NSString *)route toControllerClass:(Class)controllerClass;

- (void)openURLAction:(TFURLAction *)action;

- (UIViewController *)matchController:(NSString *)route;

- (UIViewController *)matchController:(NSString *)route userInfo:(NSDictionary *)userInfo;

@end
