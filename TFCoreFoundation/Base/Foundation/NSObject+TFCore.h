//
//  NSObject+TFCore.h
//  TFCoreFoundation
//
//  Created by Melvin on 3/30/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface NSObject (TFCore)

/**
 执行方法

 @param sel 方法以及参数
 @return 处理结果
 */
- (nullable id)tf_performSelectorWithArgs:(SEL)sel, ...;

/**
 延时执行方法

 @param sel 方法
 @param delay 延时时间单位秒
 */
- (void)tf_performSelectorWithArgs:(SEL)sel afterDelay:(NSTimeInterval)delay, ...;

/**
 是否需要线程等待执行方法

 @param sel 方法
 @param wait 是否等待
 @return 处理结果
 */
- (nullable id)tf_performSelectorWithArgsOnMainThread:(SEL)sel waitUntilDone:(BOOL)wait, ...;

/**
 是否需要在特定的线程上线程等待执行某个方法

 @param sel 方法
 @param thread 线程
 @param wait 是否等待
 @return 处理结果
 */
- (nullable id)tf_performSelectorWithArgs:(SEL)sel onThread:(NSThread *)thread waitUntilDone:(BOOL)wait, ...;

/**
 通过背后线程执行方法

 @param sel 方法
 */
- (void)tf_performSelectorWithArgsInBackground:(SEL)sel, ...;

/**
 延时执行方法

 @param sel 方法
 @param delay 延时时间单位秒
 */
- (void)tf_performSelector:(SEL)sel afterDelay:(NSTimeInterval)delay;

#pragma mark - Swap method (Swizzling)

/**
 实例方法置换

 @param originalSel 原来的方法
 @param newSel 新的方法
 @return 置换是否成功
 */
+ (BOOL)tf_swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel;

/**
 类方法置换

 @param originalSel 原来的方法
 @param newSel 新的方法
 @return 置换是否成功
 */
+ (BOOL)tf_swizzleClassMethod:(SEL)originalSel with:(SEL)newSel;

#pragma mark - Associate value

/**
 通过value和key设置关联对象

 @param value 值
 @param key 键
 */
- (void)tf_setAssociateValue:(nullable id)value withKey:(void *)key;

/**
 通过弱类型的value和key设置关联对象

 @param value 值
 @param key 键
 */
- (void)tf_setAssociateWeakValue:(nullable id)value withKey:(void *)key;

/**
 根据key获取相关联的value

 @param key 键
 @return value
 */
- (nullable id)tf_getAssociatedValueForKey:(void *)key;

/**
 移除关联
 */
- (void)tf_removeAssociatedValues;

#pragma mark - Others

/**
 类方法--获取类的名称

 @return NSString
 */
+ (NSString *)tf_className;

/**
 实例方法--获取类的名称

 @return NSString
 */
- (NSString *)tf_className;

/**
 对一个对象进行深copy

 @return 深copy后的对象
 */
- (nullable id)tf_deepCopy;

/**
 通过归档接档对对象进行深copy

 @param archiver 归档的类
 @param unarchiver 接档的类
 @return 深copy后的对象
 */
- (nullable id)tf_deepCopyWithArchiver:(Class)archiver unarchiver:(Class)unarchiver;

/**
 获取所有的子类

 @return NSArray 子类数组
 */
+ (nullable NSArray<Class> *)tf_subClasses;
@end
NS_ASSUME_NONNULL_END
