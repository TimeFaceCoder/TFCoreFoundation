//
//  TFUrlSafeBase64.m
//  TFUploadAssistant
//
//  Created by Melvin on 3/23/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFUrlSafeBase64.h"
#import "GTM_Base64.h"

@implementation TFUrlSafeBase64

+ (NSString *)encodeString:(NSString *)sourceString {
    NSData *data = [NSData dataWithBytes:[sourceString UTF8String] length:[sourceString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    return [self encodeData:data];
}

+ (NSString *)encodeData:(NSData *)data {
    return [GTM_Base64 stringByWebSafeEncodingData:data padded:YES];
}

+ (NSData *)decodeString:(NSString *)data {
    return [GTM_Base64 webSafeDecodeString:data];
}

@end
