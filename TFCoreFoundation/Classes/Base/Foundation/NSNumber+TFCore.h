//
//  NSNumber+TFCore.h
//  TFCoreFoundation
//
//  Created by Melvin on 3/30/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (TFCore)

/**
 将字符串转换成NSNumber对象

 @param string 字符串
 @return NSNumber
 */
+ (nullable NSNumber *)tf_numberWithString:(NSString *)string;

@end
NS_ASSUME_NONNULL_END
