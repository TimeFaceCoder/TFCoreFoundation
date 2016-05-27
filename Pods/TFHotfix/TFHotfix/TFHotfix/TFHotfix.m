//
//  TFHotfix.m
//  TFHotfix
//
//  Created by Melvin on 3/18/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFHotfix.h"
#import <JSPatch/JPEngine.h>
#import "TFCleaner.h"
#import <AFNetworking/AFNetworking.h>
#import "RegisterApp.h"
#import "SyncHotfix.h"

NSString * const kTFFixFileName       = @"fixfile";
NSString * const kTFFixRegisterAppURL = @"";
NSString * const kTFFixSyncURL        = @"";

@implementation TFHotfix {
    /// fix 文件本地存储目录，同一时间只允许存在一个fix文件
    NSURL *_localFilePath;
    NSString *_appKey;
    NSString *_version;
}

+ (void)fixOnSandBox:(BOOL)sandBox {
    isSandBox = sandBox;
}

+ (BOOL)sandBox {
    return isSandBox;
}


+ (TFHotfix *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        BOOL isDir = YES;
        NSError *error = nil;
        NSString *diskCachePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"cn.timeface.file/repairtool"];
        BOOL directoryExists = [[NSFileManager defaultManager] fileExistsAtPath:diskCachePath isDirectory:&isDir];
        if (!directoryExists) {
            [[NSFileManager defaultManager] createDirectoryAtURL:[NSURL fileURLWithPath:diskCachePath]
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:&error];
        }
        _localFilePath = [NSURL fileURLWithPath:[diskCachePath stringByAppendingPathComponent:kTFFixFileName]];
        [JPEngine startEngine];
    }
    return self;
}

- (void)startWithAppKey:(NSString *)appKey {
    //注册app，并执行本地脚本
    _appKey = appKey;
    RegisterApp *registerApp = [[RegisterApp alloc] initWithAppKey:appKey];
    [registerApp startWithCompletionBlockWithSuccess:^(__kindof TFBaseRequest *request) {
        if ([[request.responseObject objectForKey:@"status"] boolValue]) {
            if ([request.responseObject objectForKey:@"clean"]) {
                //清除本地文件
                [[NSFileManager defaultManager] removeItemAtURL:_localFilePath error:nil];
            }
            else {
                [JPEngine startEngine];
                [self evaluateLoacalScript];
            }
        }
    } failure:^(__kindof TFBaseRequest *request) {
    }];
}

- (void)sync {
    SyncHotfix *syncHotfix = [[SyncHotfix alloc] initWithAppKey:_appKey];
    [syncHotfix startWithCompletionBlockWithSuccess:^(__kindof TFBaseRequest *request) {
        if ([request.responseObject objectForKey:@"fileUrl"] && [[request.responseObject objectForKey:@"fileUrl"] count] > 0) {
            NSString *fileUrl = [[request.responseObject objectForKey:@"fileUrl"] objectAtIndex:0];
            if (fileUrl.length) {
                [self downloadFixFile:fileUrl];
            }
        }
        else {
            [self removeLocalScript];
        }
    } failure:^(__kindof TFBaseRequest *request) {
        
    }];}

#pragma mark - Download fix file from server

- (void)downloadFixFile:(NSString *)fileUrl {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:fileUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    __weak __typeof(self) weakSelf = self;
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request
                                                                     progress:nil
                                                                  destination:^NSURL *(NSURL *targetPath, NSURLResponse *response)
                                              {
                                                  [[NSFileManager defaultManager] removeItemAtURL:_localFilePath error:nil];
                                                  return _localFilePath;
                                              }
                                                            completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error)
                                              {
                                                  NSLog(@"File downloaded to: %@", filePath);
                                                  __typeof(&*weakSelf) strongSelf = weakSelf;
                                                  if (strongSelf) {
                                                      [strongSelf evaluateLoacalScript];
                                                  }
                                              }];
    [downloadTask resume];
}

- (void)removeLocalScript {
    [[NSFileManager defaultManager] removeItemAtURL:_localFilePath error:nil];
    [TFCleaner cleanAll];
}

- (void)evaluateLoacalScript {
    NSError *error = nil;
    NSString *script = [NSString stringWithContentsOfURL:_localFilePath
                                                encoding:NSUTF8StringEncoding
                                                   error:&error];
    if (!error) {
        [JPEngine evaluateScript:script];
    }
}

@end
