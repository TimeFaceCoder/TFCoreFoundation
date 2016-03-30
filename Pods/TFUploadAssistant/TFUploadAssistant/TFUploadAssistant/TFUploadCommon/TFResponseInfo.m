//
//  TFResponseInfo.m
//  TFUploadAssistant
//
//  Created by Melvin on 3/23/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFResponseInfo.h"

NSInteger const kTFZeroDataSize     = -6;
NSInteger const kTFInvalidToken     = -5;
NSInteger const kTFFileError        = -4;
NSInteger const kTFInvalidArgument  = -3;
NSInteger const kTFRequestCancelled = -2;
NSInteger const kTFNetworkError     = -1;

static TFResponseInfo *cancelledInfo = nil;

static NSString *domain = @"timeface.cn";

@implementation TFResponseInfo

+ (instancetype)cancel {
    return [[TFResponseInfo alloc] initWithCancelled];
}

+ (instancetype)responseInfoWithInvalidArgument:(NSString *)text {
    return [[TFResponseInfo alloc] initWithStatus:kTFInvalidArgument errorDescription:text];
}

+ (instancetype)responseInfoWithInvalidToken:(NSString *)text {
    return [[TFResponseInfo alloc] initWithStatus:kTFInvalidToken errorDescription:text];
}

+ (instancetype)responseInfoWithNetError:(NSError *)error duration:(double)duration {
    int code = kTFNetworkError;
    if (error != nil) {
        code = (int)error.code;
    }
    return [[TFResponseInfo alloc] initWithStatus:code error:error duration:duration];
}

+ (instancetype)responseInfoWithFileError:(NSError *)error {
    return [[TFResponseInfo alloc] initWithStatus:kTFFileError error:error];
}

+ (instancetype)responseInfoOfZeroData:(NSString *)path {
    NSString *desc;
    if (path == nil) {
        desc = @"data size is 0";
    }else {
        desc = [[NSString alloc] initWithFormat:@"file %@ size is 0", path];
    }
    return [[TFResponseInfo alloc] initWithStatus:kTFZeroDataSize errorDescription:desc];
}

- (instancetype)initWithCancelled {
    return [self initWithStatus:kTFRequestCancelled errorDescription:@"cancelled by user"];
}

- (instancetype)initWithStatus:(int)status
                         error:(NSError *)error {
    return [self initWithStatus:status error:error duration:0];
}

- (instancetype)initWithStatus:(int)status
                         error:(NSError *)error
                      duration:(double)duration {
    if (self = [super init]) {
        _statusCode = status;
        _error = error;
        _duration = duration;
        _timeStamp = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

- (instancetype)initWithStatus:(int)status
              errorDescription:(NSString *)text {
    NSError *error = [[NSError alloc] initWithDomain:domain code:status userInfo:@{ @"error":text }];
    return [self initWithStatus:status error:error];
}

- (instancetype)initWithStatusCode:(NSInteger)statusCode
                      withDuration:(double)duration
                          withBody:(NSData *)body {
    if (self = [super init]) {
        _statusCode = statusCode;
        _duration = duration;
        _timeStamp = [[NSDate date] timeIntervalSince1970];
        if (statusCode != 200) {
            if (body == nil) {
                _error = [[NSError alloc] initWithDomain:domain code:_statusCode userInfo:nil];
            }
            else {
                NSError *tmp;
                NSDictionary *uInfo = [NSJSONSerialization JSONObjectWithData:body options:NSJSONReadingMutableLeaves error:&tmp];
                if (tmp != nil) {
                    // 出现错误时，如果信息是非UTF8编码会失败，返回nil
                    NSString *str = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
                    if (str == nil) {
                        str = @"";
                    }
                    uInfo = @{ @"error": str };
                }
                _error = [[NSError alloc] initWithDomain:domain code:_statusCode userInfo:uInfo];
            }
        }
        else if (body == nil || body.length == 0) {
            NSDictionary *uInfo = @{ @"error":@"no response json" };
            _error = [[NSError alloc] initWithDomain:domain code:_statusCode userInfo:uInfo];
        }
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@= status: %@, duration: %f s time: %llu error: %@>", NSStringFromClass([self class]), @(_statusCode), _duration, _timeStamp, _error];
}

- (BOOL)isCancelled {
    return _statusCode == kTFRequestCancelled || _statusCode == -999;
}

- (BOOL)isOK {
    return _statusCode == 200 && _error == nil;
}

- (BOOL)isConnectionBroken {
    // reqId is nill means the server is not qiniu
    return _statusCode == kTFNetworkError || (_statusCode < -1000 && _statusCode != -1003);
}

- (BOOL)needSwitchServer {
    return _statusCode == kTFNetworkError || (_statusCode < -1000 && _statusCode != -1003) || (_statusCode / 100 == 5 && _statusCode != 579);
}

- (BOOL)couldRetry {
    return (_statusCode >= 500 && _statusCode < 600 && _statusCode != 579) || _statusCode == kTFNetworkError || _statusCode == 996 || _statusCode == 406 || (_statusCode == 200 && _error != nil) || _statusCode < -1000;
}

@end
