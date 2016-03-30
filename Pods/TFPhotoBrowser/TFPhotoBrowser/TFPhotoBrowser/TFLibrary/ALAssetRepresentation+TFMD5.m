//
//  ALAssetRepresentation+TFMD5.m
//  TFPhotoBrowser
//
//  Created by Melvin on 1/4/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "ALAssetRepresentation+TFMD5.h"
#import <CommonCrypto/CommonDigest.h>
const char * AssetMD5StringKey = "MD5String";

static const int BUFFER_SIZE = 4096;

#define HASH_DATA_SIZE  1024  // Read 1K of data to be hashed
@implementation ALAssetRepresentation (TFMD5)

- (NSString *)hashString {
    Byte *buffer = (Byte *) malloc(self.size);
    long long offset = self.size / 2; // begin from the middle of the file
    NSUInteger buffered = [self getBytes:buffer fromOffset:offset length:HASH_DATA_SIZE error:nil];
    
    if (buffered > 0)
    {
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        
        unsigned char result[CC_MD5_DIGEST_LENGTH];
        
        CC_MD5([data bytes], [data length], result);
        NSString *hash = [NSString stringWithFormat:
                          @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                          result[0], result[1], result[2], result[3],
                          result[4], result[5], result[6], result[7],
                          result[8], result[9], result[10], result[11],
                          result[12], result[13], result[14], result[15]
                          ];
        
        NSLog(@"Hash for image is %@", hash);
        return hash;
    }
    return nil;
}

- (NSString *)getMD5String {
    CFStringRef result = NULL;
    
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    
    uint8_t *buffer = (uint8_t*)malloc(BUFFER_SIZE);
    
    NSUInteger read = 0;
    NSUInteger offset = 0;
    
    NSError *err;
    
    if ([self size] != 0) {
        do {
            read = [self getBytes:buffer fromOffset:offset length:BUFFER_SIZE error:&err];
            offset += read;
            
            CC_MD5_Update(&hashObject, (const void *)buffer, (CC_LONG)read);
        } while (read != 0);
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault, (const char *)hash, kCFStringEncodingUTF8);
    return (__bridge_transfer NSString *)result;
}

@end
