//
//  NSNotificationCenter+TFCore.h
//  TFCoreFoundation
//
//  Created by Melvin on 3/30/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSNotificationCenter (TFCore)

- (void)tf_postNotificationOnMainThread:(NSNotification *)notification;
- (void)tf_postNotificationOnMainThread:(NSNotification *)notification
                       waitUntilDone:(BOOL)wait;
- (void)tf_postNotificationOnMainThreadWithName:(NSString *)name
                                      object:(nullable id)object;
- (void)tf_postNotificationOnMainThreadWithName:(NSString *)name
                                      object:(nullable id)object
                                    userInfo:(nullable NSDictionary *)userInfo;
- (void)tf_postNotificationOnMainThreadWithName:(NSString *)name
                                      object:(nullable id)object
                                    userInfo:(nullable NSDictionary *)userInfo
                               waitUntilDone:(BOOL)wait;

@end
NS_ASSUME_NONNULL_END