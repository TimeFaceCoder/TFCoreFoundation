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

/**
 根据通知对象在主线程发送通知

 @param notification 通知对象
 */
- (void)tf_postNotificationOnMainThread:(NSNotification *)notification;

/**
 根据通知对象和是否等待在主线程发送通知

 @param notification 通知对象
 @param wait 是否需要等地啊
 */
- (void)tf_postNotificationOnMainThread:(NSNotification *)notification
                       waitUntilDone:(BOOL)wait;

/**
 根据通知名称和发送对象在主线程发送通知

 @param name 通知名称
 @param object 发送对象
 */
- (void)tf_postNotificationOnMainThreadWithName:(NSString *)name
                                      object:(nullable id)object;

/**
 根据通知名称、发送对象、以及用户信息字典在主线程发送通知

 @param name 通知名称
 @param object 发送对象
 @param userInfo 用户信息字典
 */
- (void)tf_postNotificationOnMainThreadWithName:(NSString *)name
                                      object:(nullable id)object
                                    userInfo:(nullable NSDictionary *)userInfo;

/**
 根据通知名称、发送对象、用户信息字典以及是否等待在主线程发送通知

 @param name 通知名称
 @param object 发送对象
 @param userInfo 用户信息字典
 @param wait 是否等待
 */
- (void)tf_postNotificationOnMainThreadWithName:(NSString *)name
                                      object:(nullable id)object
                                    userInfo:(nullable NSDictionary *)userInfo
                               waitUntilDone:(BOOL)wait;

@end
NS_ASSUME_NONNULL_END
