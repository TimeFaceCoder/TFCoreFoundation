//
//  TFRouter.m
//  TFNavigator
//
//  Created by Melvin on 3/31/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFRouter.h"

#import <objc/runtime.h>

@interface TFRouter ()
@property (strong, nonatomic) NSMutableDictionary *routes;
@property (strong, nonatomic) NSMutableDictionary *paramKeys;
@end




@implementation TFRouter
+ (instancetype)shared
{
    static TFRouter *router = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (!router) {
            router = [[self alloc] init];
        }
    });
    return router;
}

- (void)map:(NSString *)route toBlock:(TFRouterBlock)block
{
    NSMutableDictionary *subRoutes = [self subRoutesToRoute:route];
    
    subRoutes[@"_"] = [block copy];
}

- (UIViewController *)matchController:(NSString *)route
{
    NSDictionary *params = [self paramsInRoute:route];
    Class controllerClass = params[@"controller_class"];
    
    UIViewController *viewController = [[controllerClass alloc] init];
    
    if ([viewController respondsToSelector:@selector(setParams:)]) {
        [viewController performSelector:@selector(setParams:)
                             withObject:[params copy]];
    }
    return viewController;
}

- (UIViewController *)matchController:(NSString *)route userInfo:(NSDictionary *)userInfo;
{
    NSMutableDictionary *params = [self paramsInRoute:route];
    Class controllerClass = params[@"controller_class"];
    if (userInfo) {
        //传入自定义参数
        params[kTFNavigatorParameterUserInfo] = [userInfo copy];
    }
    UIViewController *viewController = [[controllerClass alloc] init];
    
    if ([viewController respondsToSelector:@selector(setParams:)]) {
        [viewController performSelector:@selector(setParams:)
                             withObject:[params copy]];
    }
    return viewController;
}

- (UIViewController *)matchController:(NSString *)route storyboardName:(NSString *)storyboardName userInfo:(NSDictionary *)userInfo {
    NSMutableDictionary *params = [self paramsInRoute:route];
    Class controllerClass = params[@"controller_class"];
    if (userInfo) {
        //传入自定义参数
        params[kTFNavigatorParameterUserInfo] = [userInfo copy];
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(controllerClass)];
    if ([viewController respondsToSelector:@selector(setParams:)]) {
        [viewController performSelector:@selector(setParams:)
                             withObject:[params copy]];
    }
    return viewController;
}

- (TFRouterBlock)matchBlock:(NSString *)route
{
    NSDictionary *params = [self paramsInRoute:route];
    
    if (!params){
        return nil;
    }
    
    TFRouterBlock routerBlock = [params[@"block"] copy];
    TFRouterBlock returnBlock = ^id(NSDictionary *aParams) {
        if (routerBlock) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:params];
            [dic addEntriesFromDictionary:aParams];
            return routerBlock([NSDictionary dictionaryWithDictionary:dic].copy);
        }
        return nil;
    };
    
    return [returnBlock copy];
}

- (id)callBlock:(NSString *)route
{
    NSDictionary *params = [self paramsInRoute:route];
    TFRouterBlock routerBlock = [params[@"block"] copy];
    
    if (routerBlock) {
        return routerBlock([params copy]);
    }
    return nil;
}

// extract params in a route
- (NSMutableDictionary *)paramsInRoute:(NSString *)route
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    params[@"route"] = [self stringFromFilterAppUrlScheme:route];
    
    NSMutableDictionary *subRoutes = self.routes;
    NSArray *pathComponents = [self pathComponentsFromRoute:[self stringFromFilterAppUrlScheme:route]];
    for (NSString *pathComponent in pathComponents) {
        BOOL found = NO;
        NSArray *subRoutesKeys = subRoutes.allKeys;
        for (NSString *key in subRoutesKeys) {
            if ([subRoutesKeys containsObject:pathComponent]) {
                found = YES;
                subRoutes = subRoutes[pathComponent];
                break;
            } else if ([key hasPrefix:@":"]) {
                found = YES;
                subRoutes = subRoutes[key];
                params[[key substringFromIndex:1]] = pathComponent;
                break;
            }
        }
        if (!found) {
            return nil;
        }
    }
    
    // Extract Params From Query.
    NSRange firstRange = [route rangeOfString:@"?"];
    if (firstRange.location != NSNotFound && route.length > firstRange.location + firstRange.length) {
        NSString *paramsString = [route substringFromIndex:firstRange.location + firstRange.length];
        NSArray *paramStringArr = [paramsString componentsSeparatedByString:@"&"];
        for (NSString *paramString in paramStringArr) {
            NSArray *paramArr = [paramString componentsSeparatedByString:@"="];
            if (paramArr.count > 1) {
                NSString *key = [paramArr objectAtIndex:0];
                NSString *value = [paramArr objectAtIndex:1];
                params[key] = value;
            }
        }
    }
    
    Class class = subRoutes[@"_"];
    if (class_isMetaClass(object_getClass(class))) {
        if ([class isSubclassOfClass:[UIViewController class]]) {
            params[@"controller_class"] = subRoutes[@"_"];
        } else {
            return nil;
        }
    } else {
        if (subRoutes[@"_"]) {
            params[@"block"] = [subRoutes[@"_"] copy];
        }
    }
    //默认userinfo为空
    params[kTFNavigatorParameterUserInfo] = @{};
    
    return params;
}

#pragma mark - Private

- (NSMutableDictionary *)routes
{
    if (!_routes) {
        _routes = [[NSMutableDictionary alloc] init];
    }
    
    return _routes;
}

- (NSMutableDictionary *)paramKeys
{
    if (!_paramKeys) {
        _paramKeys = [[NSMutableDictionary alloc] init];
    }
    return _paramKeys;
}

- (NSArray *)pathComponentsFromRoute:(NSString *)route
{
    NSMutableArray *pathComponents = [NSMutableArray array];
    for (NSString *pathComponent in route.pathComponents) {
        if ([pathComponent isEqualToString:@"/"]) continue;
        if ([[pathComponent substringToIndex:1] isEqualToString:@"?"]) break;
        [pathComponents addObject:pathComponent];
    }
    
    return [pathComponents copy];
}

- (NSString *)stringFromFilterAppUrlScheme:(NSString *)string
{
    // filter out the app URL compontents.
    for (NSString *appUrlScheme in [self appUrlSchemes]) {
        if ([string hasPrefix:[NSString stringWithFormat:@"%@:", appUrlScheme]]) {
            return [string substringFromIndex:appUrlScheme.length + 2];
        }
    }
    
    return string;
}

- (NSArray *)appUrlSchemes
{
    NSMutableArray *appUrlSchemes = [NSMutableArray array];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    for (NSDictionary *dic in infoDictionary[@"CFBundleURLTypes"]) {
        NSString *appUrlScheme = dic[@"CFBundleURLSchemes"][0];
        [appUrlSchemes addObject:appUrlScheme];
    }
    
    return [appUrlSchemes copy];
}

- (NSMutableDictionary *)subRoutesToRoute:(NSString *)route
{
    NSArray *pathComponents = [self pathComponentsFromRoute:route];
    
    NSInteger index = 0;
    NSMutableDictionary *subRoutes = self.routes;
    
    while (index < pathComponents.count) {
        NSString *pathComponent = pathComponents[index];
        if (![subRoutes objectForKey:pathComponent]) {
            subRoutes[pathComponent] = [[NSMutableDictionary alloc] init];
        }
        subRoutes = subRoutes[pathComponent];
        index++;
    }
    
    return subRoutes;
}

- (void)map:(NSString *)route toControllerClass:(Class)controllerClass
{
    NSMutableDictionary *subRoutes = [self subRoutesToRoute:route];
    
    subRoutes[@"_"] = controllerClass;
}

- (void)mapWith:(NSDictionary *)param toControllerClass:(Class)controllerClass
{
    
}


- (TFRouteType)canRoute:(NSString *)route
{
    NSDictionary *params = [self paramsInRoute:route];
    
    if (params[@"controller_class"]) {
        return TFRouteTypeViewController;
    }
    
    if (params[@"block"]) {
        return TFRouteTypeBlock;
    }
    
    return TFRouteTypeNone;
}

@end


