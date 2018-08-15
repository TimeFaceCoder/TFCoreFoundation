//
//  TFURLAction.m
//  TFNavigator
//
//  Created by Melvin on 3/31/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFURLAction.h"

@interface TFURLAction() {
    
}

@property (nonatomic ,assign) BOOL animated;

@end

@implementation TFURLAction

+ (id)actionWithURLPath:(NSString*)urlPath userInfo:(NSDictionary *)userInfo{
    return [[self alloc] initWithURLPath:urlPath userInfo:userInfo];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithURLPath:(NSString*)urlPath userInfo:(NSDictionary *)userInfo{
    if (self = [super init]) {
        self.urlPath  = urlPath;
        self.animated = YES;
        self.userInfo = userInfo;
    }
    
    return self;
}

- (TFURLAction*)applyAnimated:(BOOL)animated {
    self.animated = animated;
    return self;
}

- (void)dealloc {
    self.actionCompletionBlock = nil;
    self.transitioningDelegate = nil;
    self.userInfo = nil;
}

@end
