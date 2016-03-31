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

- (void)tf_addObserverBlockForKeyPath:(NSString*)keyPath block:(void (^)(id _Nonnull obj, _Nullable id oldVal, _Nullable id newVal))block;
- (void)tf_removeObserverBlocksForKeyPath:(NSString*)keyPath;
- (void)tf_removeObserverBlocks;

@end
NS_ASSUME_NONNULL_END