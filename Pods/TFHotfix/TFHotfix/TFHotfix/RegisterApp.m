//
//  RegisterApp.m
//  TFHotfix
//
//  Created by Melvin on 3/18/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "RegisterApp.h"
#import "TFHotfix.h"

@implementation RegisterApp {
    NSString *_appKey;
    NSString *_version;
}

- (instancetype)initWithAppKey:(NSString *)appKey {
    self = [super init];
    if (self) {
        _appKey = appKey;
        _version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    }
    return self;
}

- (TFRequestMethod)requestMethod {
    return TFRequestMethodPost;
}

- (TFRequestSerializerType)requestSerializerType {
    return TFRequestSerializerTypeJSON;
}

- (NSString *)requestUrl {
    if ([TFHotfix sandBox]) {
        return @"http://stg2.v5time.net/hotfix/hotfix/register";
    }
    return @"http://hotfix.timeface.cn/hotfix/register";
}

- (id)requestArgument {
    return @{@"appkey": _appKey,
             @"version": _version};
}

@end
