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

- (nullable id)tf_performSelectorWithArgs:(SEL)sel, ...;
- (void)tf_performSelectorWithArgs:(SEL)sel afterDelay:(NSTimeInterval)delay, ...;
- (nullable id)tf_performSelectorWithArgsOnMainThread:(SEL)sel waitUntilDone:(BOOL)wait, ...;
- (nullable id)tf_performSelectorWithArgs:(SEL)sel onThread:(NSThread *)thread waitUntilDone:(BOOL)wait, ...;
- (void)tf_performSelectorWithArgsInBackground:(SEL)sel, ...;
- (void)tf_performSelector:(SEL)sel afterDelay:(NSTimeInterval)delay;

#pragma mark - Swap method (Swizzling)
+ (BOOL)tf_swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel;
+ (BOOL)tf_swizzleClassMethod:(SEL)originalSel with:(SEL)newSel;

#pragma mark - Associate value
- (void)tf_setAssociateValue:(nullable id)value withKey:(void *)key;
- (void)tf_setAssociateWeakValue:(nullable id)value withKey:(void *)key;
- (nullable id)tf_getAssociatedValueForKey:(void *)key;
- (void)tf_removeAssociatedValues;

#pragma mark - Others
+ (NSString *)tf_className;
- (NSString *)tf_className;
- (nullable id)tf_deepCopy;
- (nullable id)tf_deepCopyWithArchiver:(Class)archiver unarchiver:(Class)unarchiver;

@end
NS_ASSUME_NONNULL_END