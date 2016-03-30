//
//  TFFileRecorder.m
//  TFUploadAssistant
//
//  Created by Melvin on 3/23/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFFileRecorder.h"
#import "TFUrlSafeBase64.h"
#import <EGOCache/EGOCache.h>

@interface TFFileRecorder  ()

@property (copy, readonly) NSString *directory;
@property (nonatomic ,strong) EGOCache *cache;
@property BOOL encode;

@end

@implementation TFFileRecorder

- (NSString *)pathOfKey:(NSString *)key {
    return [TFFileRecorder pathJoin:key path:_directory];
}

+ (NSString *)pathJoin:(NSString *)key
                  path:(NSString *)path {
    return [[NSString alloc] initWithFormat:@"%@/%@", path, key];
}

+ (instancetype)sharedInstance {
    static TFFileRecorder *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [TFFileRecorder fileRecorderWithFolder:nil
                                                      encodeKey:YES
                                                          error:nil];
    });
    
    return sharedInstance;
}

+ (instancetype)fileRecorderWithFolder:(NSString *)directory
                                 error:(NSError *__autoreleasing *)perror {
    return [TFFileRecorder fileRecorderWithFolder:directory encodeKey:false error:perror];
}

+ (instancetype)fileRecorderWithFolder:(NSString *)directory
                             encodeKey:(BOOL)encode
                                 error:(NSError *__autoreleasing *)perror {
    NSError *error;
    if (!directory) {
        directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"cn.timeface.upload.cache"];
    }
    [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
    if (error != nil) {
        if (perror) {
            *perror = error;
        }
        return nil;
    }
    
    return [[TFFileRecorder alloc] initWithFolder:directory encodeKey:encode];
}

- (instancetype)initWithFolder:(NSString *)directory encodeKey:(BOOL)encode {
    if (self = [super init]) {
        _directory = directory;
        _encode = encode;
        _cache = [[EGOCache alloc] initWithCacheDirectory:_directory];
    }
    return self;
}

- (NSError *)set:(NSString *)key
          object:(id)object {
    NSError *error;
    if (_encode) {
        key = [TFUrlSafeBase64 encodeString:key];
    }
    [_cache setObject:object forKey:key];
    return error;
}

- (id)get:(NSString *)key {
    if (_encode) {
        key = [TFUrlSafeBase64 encodeString:key];
    }
    return [_cache objectForKey:key];
}

- (NSError *)del:(NSString *)key {
    NSError *error;
    if (_encode) {
        key = [TFUrlSafeBase64 encodeString:key];
    }
    [_cache removeCacheForKey:key];
    return error;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, dir: %@>", NSStringFromClass([self class]), self, _directory];
}

@end
