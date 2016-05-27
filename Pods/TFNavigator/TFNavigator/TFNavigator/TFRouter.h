//
//  TFRouter.h
//  TFNavigator
//
//  Created by Melvin on 3/31/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIWindow+TFNavigator.h"

typedef NS_ENUM (NSInteger, TFRouteType) {
    TFRouteTypeNone = 0,
    TFRouteTypeViewController = 1,
    TFRouteTypeBlock = 2
};

typedef id (^TFRouterBlock)(NSDictionary *params);


@interface TFRouter : NSObject

+ (instancetype)shared;

- (void)map:(NSString *)route toControllerClass:(Class)controllerClass;
- (void)mapWith:(NSDictionary *)param toControllerClass:(Class)controllerClass;
- (UIViewController *)matchController:(NSString *)route;
- (UIViewController *)matchController:(NSString *)route userInfo:(NSDictionary *)userInfo;

- (void)map:(NSString *)route toBlock:(TFRouterBlock)block;
- (TFRouterBlock)matchBlock:(NSString *)route;
- (id)callBlock:(NSString *)route;

- (TFRouteType)canRoute:(NSString *)route;

@end

