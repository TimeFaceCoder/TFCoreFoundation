//
//  TFUrlSafeBase64.h
//  TFUploadAssistant
//
//  Created by Melvin on 3/23/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFUrlSafeBase64 : NSObject

/**
 *    字符串编码
 *
 *    @param source 字符串
 *
 *    @return base64 字符串
 */
+ (NSString *)encodeString:(NSString *)source;

/**
 *    二进制数据编码
 *
 *    @param source 二进制数据
 *
 *    @return base64字符串
 */
+ (NSString *)encodeData:(NSData *)source;

/**
 *    字符串解码
 *
 *    @param base64 字符串
 *
 *    @return 数据
 */
+ (NSData *)decodeString:(NSString *)data;

@end
