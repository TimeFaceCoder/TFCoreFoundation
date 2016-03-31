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
+ (nullable NSNumber *)tf_numberWithString:(NSString *)string;

@end
NS_ASSUME_NONNULL_END