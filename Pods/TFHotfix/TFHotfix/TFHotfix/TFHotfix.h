//
//  TFHotfix.h
//  TFHotfix
//
//  Created by Melvin on 3/18/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFHotfix : NSObject

+ (TFHotfix *)sharedInstance;
/**
 *  传入AppKey 并自动执行已下载到本地的patch脚本
 *
 *  @param appKey
 */
- (void)startWithAppKey:(NSString *)appKey;
/**
 *  检查是否有patch更新，并下载执行
 */
- (void)sync;


@end
