//
//  NSObject+TFCoreForKVO.h
//  TFCoreFoundation
//
//  Created by Melvin on 3/30/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface NSObject (TFCoreForKVO)

/**
 通过keyPath和值变化的block添加监察者

 @param keyPath 路径
 @param block 值变化代码块
 */
- (void)tf_addObserverBlockForKeyPath:(NSString*)keyPath block:(void (^)(id _Nonnull obj, _Nullable id oldVal, _Nullable id newVal))block;

/**
 通过keyPath移除监察者

 @param keyPath 路径
 */
- (void)tf_removeObserverBlocksForKeyPath:(NSString*)keyPath;

/**
 移除所有的监察者
 */
- (void)tf_removeObserverBlocks;

@end
NS_ASSUME_NONNULL_END
