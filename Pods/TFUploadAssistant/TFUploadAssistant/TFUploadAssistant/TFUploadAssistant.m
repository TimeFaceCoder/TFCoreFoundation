//
//  TFUploadAssistant.m
//  TFUploadAssistant
//
//  Created by Melvin on 3/23/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFUploadAssistant.h"
#import "TFConfiguration.h"
#import "TFAsyncRun.h"
#import "TFFile.h"
#import "TFFileProtocol.h"
#import "TFResponseInfo.h"
#import "TFAliUploadOperation.h"
#import "TFPHAssetFile.h"
#import "TFFileRecorder.h"
#import <AliyunOSSiOS/OSSService.h>
#import <AliyunOSSiOS/OSSCompat.h>
#import <AFNetworking/AFNetworking.h>
#import "TFAliUploadHandler.h"
#import <Photos/Photos.h>
#import <YYDispatchQueuePool/YYDispatchQueuePool.h>


NSString * const kTFUploadOperationsKey      = @"kTFUploadOperationsKey";
NSString * const kTFUploadFailedOperationsKey = @"kTFUploadFailedOperationsKey";

@interface TFUploadAssistant()<NSURLSessionDelegate>

@property (nonatomic ,strong) TFConfiguration     *configuration;
@property (nonatomic ,strong) NSMutableDictionary *uploadHandlers;
@property (nonatomic ,strong) NSMutableDictionary *uploadOperations;
@property (nonatomic ,strong) NSMutableDictionary *failedOperations;
@property (nonatomic ,strong) NSMutableDictionary *progressHandlers;
@property (nonatomic ,strong) YYDispatchQueuePool *pool;
@end

@implementation TFUploadAssistant

- (instancetype)initWithConfiguration:(TFConfiguration *)config {
    if (self = [super init]) {
        _pool = [[YYDispatchQueuePool alloc] initWithName:@"cn.timeface.upload.read"
                                               queueCount:10
                                                      qos:NSQualityOfServiceBackground];
        
        _configuration = config;
        _uploadHandlers = [NSMutableDictionary dictionary];
        _progressHandlers = [NSMutableDictionary dictionary];
        _uploadOperations = [NSMutableDictionary dictionary];
        _failedOperations = [[TFFileRecorder sharedInstance] get:kTFUploadFailedOperationsKey];
        if (!_failedOperations) {
            _failedOperations = [NSMutableDictionary dictionary];
        }
        [self initOSSService];
        [self checkTask];
    }
    return self;
}

+ (instancetype)sharedInstanceWithConfiguration:(TFConfiguration *)config {
    static TFUploadAssistant *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initWithConfiguration:config];
    });
    
    return sharedInstance;
}

+ (BOOL)checkAndNotifyError:(NSString *)key
                      token:(NSString *)token
                      input:(NSObject *)input
                   complete:(TFUpCompletionHandler)completionHandler {
    NSString *desc = nil;
    TFResponseInfo *info = nil;
    if (completionHandler == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"no completionHandler" userInfo:nil];
        return YES;
    }
    if (input == nil) {
        desc = @"no input data";
        info = [TFResponseInfo responseInfoOfZeroData:nil];
    }
    else if (token == nil || [token isEqualToString:@""]) {
        desc = @"no token";
        info = [TFResponseInfo responseInfoWithInvalidToken:desc];
    }
    if (desc != nil) {
        completionHandler(info, key,token, NO);
        TFULogDebug(@"check input error:%@",desc);
        return YES;
    }
    return NO;
}

#pragma mark - Public

- (void) putData:(NSData *)data
             key:(NSString *)key
           token:(NSString *)token
        progress:(TFUpProgressHandler)progressHandler
      completion:(TFUpCompletionHandler)completionHandler {
    if ([TFUploadAssistant checkAndNotifyError:key token:token input:data complete:completionHandler]) {
        return;
    }
    TFAliUploadOperation *uploadOperation = [TFAliUploadOperation uploadOperationWithData:data
                                                                                      key:key
                                                                                    token:token
                                                                                 progress:progressHandler
                                                                                 complete:completionHandler
                                                                                   config:_configuration];
    
    dispatch_async([_pool queue], ^{
        [uploadOperation start];
    });
}

- (void) putFile:(NSString *)filePath
             key:(NSString *)key
           token:(NSString *)token
        progress:(TFUpProgressHandler)progressHandler
      completion:(TFUpCompletionHandler)completionHandler {
    @autoreleasepool {
        NSError *error = nil;
        __block TFFile *file = [[TFFile alloc] init:filePath error:&error];
        [self putFileInternal:file key:key token:token progress:progressHandler complete:completionHandler];
    }
}

- (void) putPHAsset:(PHAsset *)asset
                key:(NSString *)key
              token:(NSString *)token
           progress:(TFUpProgressHandler)progressHandler
         completion:(TFUpCompletionHandler)completionHandler {
    @autoreleasepool {
        NSError *error = nil;
        __block TFPHAssetFile *file = [[TFPHAssetFile alloc] init:asset error:&error];
        [self putFileInternal:file key:key token:token progress:progressHandler complete:completionHandler];
    }
}

- (void) putPHAssets:(NSArray *)assets
                keys:(NSArray *)keys
               token:(NSString *)token
            delegate:(id<TFUploadAssistantDelegate>)delegate {
    if (delegate) {
        [self attachListener:delegate token:token];
        [self putPHAssets:assets keys:keys token:token progress:nil completion:nil];
    }
}
- (void) putPHAssets:(NSArray *)assets
                keys:(NSArray *)keys
               token:(NSString *)token
            progress:(TFUpProgressHandler)progressHandler
          completion:(TFUpCompletionHandler)completionHandler {
    NSInteger index = 0;
    [self initOperations:keys token:token];
    for (PHAsset *asset in assets) {
        [self putPHAsset:asset
                     key:[keys objectAtIndex:index]
                   token:token
                progress:progressHandler
              completion:completionHandler];
        index ++;
        TFULogDebug(@"put PHAsset in upload queue");
    }
    
}


- (void) attachListener:(id<TFUploadAssistantDelegate>)listener token:(NSString *)token {
    [self removeHandlerWithListener:listener];
    NSMutableArray *handlers = [self.uploadHandlers objectForKey:token];
    if (!handlers) {
        handlers = [NSMutableArray array];
    }
    TFAliUploadHandler *handler = [TFAliUploadHandler uploadHandlerWithToken:token delegate:listener];
    [handlers addObject:handler];
    [self.uploadHandlers setObject:handlers forKey:token];
}

- (void) detachListener:(id<TFUploadAssistantDelegate>)listener {
    [self removeHandlerWithListener:listener];
}

#pragma mark - Private

#pragma mark - 文件上传内部方法

- (void) putFileInternal:(id<TFFileProtocol>)file
                     key:(NSString *)key
                   token:(NSString *)token
                progress:(TFUpProgressHandler)progressHandler
                complete:(TFUpCompletionHandler)completionHandler {
    __weak __typeof(self)weakSelf = self;
    TFUpCompletionHandler checkComplete = ^(TFResponseInfo *info, NSString *key, NSString * token,BOOL success)
    {
        [file close];
        if (completionHandler) {
            completionHandler(info,key,token,success);
        }
    };
    NSData *data = [file readAll];
    //check file
    if ([TFUploadAssistant checkAndNotifyError:key token:token input:data complete:checkComplete]) {
        TFULogDebug(@"File :%@ check error",[file path]);
        return;
    }
    if (!progressHandler) {
        progressHandler = ^(NSString *key,NSString *token ,float percent) {
            [self calculateTotalProgress:token key:key progress:percent];
        };
    }
    TFUpCompletionHandler uploadComplete = ^(TFResponseInfo *info, NSString *key, NSString *token, BOOL success){
        //remove from operations
        __typeof(&*weakSelf) strongSelf = weakSelf;
        [strongSelf removeOperationsByToken:token identifier:key];
        if (completionHandler) {
            completionHandler(info,key,token,success);
        }
        if (!success) {
            //上传失败,加入错误列表
            TFULogDebug(@"update object :%@ error add failed operations",key);
            [strongSelf cacheFailedOperationsByToken:token objectKey:key filePath:[file path]];
        }
        TFULogDebug(@"update object :%@ consume %f seconds",key,info.duration);
    };
    [self putData:data key:key token:token progress:progressHandler completion:uploadComplete];
}


#pragma mark -
#pragma mark Global Blocks

void (^GlobalProgressBlock)(NSString *key,NSString *token ,float percent ,TFUploadAssistant* self) =
^(NSString *key,NSString *token ,float percent ,TFUploadAssistant* self)
{
    NSMutableArray *handlers = [self.uploadHandlers objectForKey:token];
    //Inform the handlers
    [handlers enumerateObjectsUsingBlock:^(TFAliUploadHandler *handler, NSUInteger idx, BOOL *stop) {
        if(handler.progressHandler) {
            handler.progressHandler(key, token,percent);
        }
        if([handler.delegate respondsToSelector:@selector(uploadAssistantProgressHandler:token:percent:)]) {
            [handler.delegate uploadAssistantProgressHandler:key token:token percent:percent];
        }
    }];
};
void (^GlobalCompletionBlock)(TFResponseInfo *info, NSString *key, NSString *token,BOOL success, TFUploadAssistant* self) =
^(TFResponseInfo *info, NSString *key, NSString *token,BOOL success, TFUploadAssistant* self)
{
    NSMutableArray *handlers = [self.uploadHandlers objectForKey:token];
    //Inform the handlers
    [handlers enumerateObjectsUsingBlock:^(TFAliUploadHandler *handler, NSUInteger idx, BOOL *stop) {
        if(handler.completionHandler) {
            handler.completionHandler(info,key,token,success);
        }
        if([handler.delegate respondsToSelector:@selector(uploadAssistantCompletionHandler:key:token:success:)]) {
            [handler.delegate uploadAssistantCompletionHandler:info key:key token:token success:success];
        }
    }];
    //Remove the upload handlers
    [self.uploadHandlers removeObjectForKey:token];
};


#pragma mark - 处理进度与任务列表

- (void)initOperations:(NSArray *)keys token:(NSString *)token {
    //创建进度管理
    NSMutableDictionary *progressDic = [_progressHandlers objectForKey:token];
    if (!progressDic) {
        progressDic = [NSMutableDictionary new];
        [_progressHandlers setObject:progressDic forKey:token];
    }
    //创建任务列表
    for (NSString *objectKey in keys) {
        [progressDic setObject:[NSNumber numberWithFloat:0] forKey:objectKey];
        [self cacheOperationsByToken:token identifier:objectKey];
    }
    //cache task list
    [[TFFileRecorder sharedInstance] set:kTFUploadOperationsKey object:_uploadOperations];
}

#pragma mark - 移除监听

- (void)removeHandlerWithListener:(id)listener {
    for (NSInteger i = self.uploadHandlers.allKeys.count - 1; i >= 0; i-- ) {
        id key = self.uploadHandlers.allKeys[i];
        NSMutableArray *array = [self.uploadHandlers objectForKey:key];
        for (NSInteger j = array.count - 1; j >= 0; j-- ) {
            TFAliUploadHandler *handler = array[j];
            if (handler.delegate == listener) {
                [array removeObject:handler];
            }
        }
    }
}



#pragma mark - 计算总体进度

- (void)calculateTotalProgress:(NSString *)token key:(NSString *)key progress:(float)progress {
    NSMutableDictionary *progressEntry = [_progressHandlers objectForKey:token];
    [progressEntry setObject:[NSNumber numberWithFloat:progress] forKey:key];
    float count = [[progressEntry allKeys] count];
    float currentPorgress = 0;
    for (NSString *key in [progressEntry allKeys]) {
        currentPorgress += [[progressEntry objectForKey:key] floatValue];
    }
    float newProgress = (currentPorgress / count);
    GlobalProgressBlock(key,token,newProgress,self);
}

#pragma mark - 缓存任务列表

- (void)cacheOperationsByToken:(NSString *)token identifier:(NSString *)identifier {
    NSMutableArray *array = [_uploadOperations objectForKey:token];
    if (!array) {
        array = [NSMutableArray array];
        [_uploadOperations setObject:array forKey:token];
    }
    //添加至任务列表
    if (![array containsObject:identifier]) {
        [array addObject:identifier];
    }
}

- (void)removeOperationsByToken:(NSString *)token identifier:(NSString *)identifier {
    NSMutableArray *array = [_uploadOperations objectForKey:token];
    if (array) {
        [array removeObject:identifier];
        if ([array count] == 0) {
            //all task is over in this token
            GlobalCompletionBlock(nil,nil,token,YES,self);
            //update task list
            [[TFFileRecorder sharedInstance] set:kTFUploadOperationsKey object:_uploadOperations];
        }
    }
}

#pragma mark - 缓存失败任务列表

- (void)cacheFailedOperationsByToken:(NSString *)token objectKey:(NSString *)objectKey filePath:(NSString *)filePath {
    NSMutableDictionary *entry = [_failedOperations objectForKey:token];
    if (!entry) {
        entry = [NSMutableDictionary dictionary];
        [_failedOperations setObject:entry forKey:token];
    }
    //添加至任务列表
    [entry setObject:filePath forKey:objectKey];
    //save to disk
    [[TFFileRecorder sharedInstance] set:kTFUploadFailedOperationsKey object:_failedOperations];
}

- (void)removeFailedOperationsByToken:(NSString *)token objectKey:(NSString *)objectKey {
    NSMutableDictionary *entry = [_failedOperations objectForKey:token];
    if (entry) {
        [entry removeObjectForKey:objectKey];
    }
    //{objectkey:filepath}
    [_failedOperations setObject:entry forKey:token];
    //save to disk
    [[TFFileRecorder sharedInstance] set:kTFUploadFailedOperationsKey object:_failedOperations];
}
#pragma mark - 检测未完成任务列表

- (void)checkTask {
    __weak __typeof(self)weakSelf = self;
    TFAsyncRun(^{
        __typeof(&*weakSelf) strongSelf = weakSelf;
        @autoreleasepool {
            NSMutableDictionary *failedOperations = [[TFFileRecorder sharedInstance] get:kTFUploadFailedOperationsKey];
            if (failedOperations) {
                for (NSString *token in [failedOperations allKeys]) {
                    NSMutableDictionary *entry = [failedOperations objectForKey:token];
                    //{objectkey:filepath}
                    if (entry) {
                        for (NSString *objectKey in entry) {
                            NSString *filePath = [entry objectForKey:objectKey];
                            if ([[NSURL URLWithString:filePath] isFileReferenceURL]) {
                                //file path
                                [strongSelf putFile:filePath
                                                key:objectKey
                                              token:token
                                           progress:NULL
                                         completion:^(TFResponseInfo *info, NSString *key, NSString *token, BOOL success) {
                                             if (success) {
                                                 [strongSelf removeFailedOperationsByToken:token objectKey:objectKey];
                                             }
                                         }];
                            }
                            else {
                                //PHAsset URL
                                PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[filePath] options:nil];
                                if ([fetchResult count] > 0) {
                                    PHAsset *asset = [fetchResult objectAtIndex:0];
                                    [strongSelf putPHAsset:asset
                                                       key:objectKey
                                                     token:token
                                                  progress:NULL
                                                completion:^(TFResponseInfo *info, NSString *key, NSString *token, BOOL success) {
                                                    if (success) {
                                                        [strongSelf removeFailedOperationsByToken:token objectKey:objectKey];
                                                    }
                                                }];
                                }
                            }
                        }
                    }
                }
            }
        }
    });
    
}

#pragma mark - 初始化阿里云服务

- (void)initOSSService {
    id<OSSCredentialProvider> credential = [[OSSFederationCredentialProvider alloc] initWithFederationTokenGetter:^OSSFederationToken * {
        NSURL * url = [NSURL URLWithString:_configuration.aliAuthSTS];
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        OSSTaskCompletionSource * tcs = [OSSTaskCompletionSource taskCompletionSource];
        NSURLSessionConfiguration  *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession * session = [NSURLSession sessionWithConfiguration:configuration
                                                               delegate:self
                                                          delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionTask * sessionTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data,
                                                                        NSURLResponse *response,
                                                                        NSError *error)
                                          {
                                              if (error) {
                                                  [tcs setError:error];
                                                  return;
                                              }
                                              [tcs setResult:data];
                                          }];
        [sessionTask resume];
        [tcs.task waitUntilFinished];
        if (tcs.task.error) {
            return nil;
        } else {
            NSDictionary *object = [NSJSONSerialization JSONObjectWithData:tcs.task.result
                                                                   options:kNilOptions
                                                                     error:nil];
            OSSFederationToken *token         = [OSSFederationToken new];
            token.tAccessKey                  = [object objectForKey:@"tempAK"];
            token.tSecretKey                  = [object objectForKey:@"tempSK"];
            token.tToken                      = [object objectForKey:@"token"];
            token.expirationTimeInMilliSecond = [[object objectForKey:@"expiration"] longLongValue]*1000;
            return token;
        }
    }];
    OSSClientConfiguration * conf = [OSSClientConfiguration new];
    conf.maxConcurrentRequestCount = [TFConfiguration maxConcurrentRequestCount];
    conf.enableBackgroundTransmitService = YES;
    conf.maxRetryCount = 3;
    conf.timeoutIntervalForRequest = 30;
    conf.backgroundSesseionIdentifier = @"cn.timeface.upload.session";
    _client = [[OSSClient alloc] initWithEndpoint:_configuration.aliEndPoint
                               credentialProvider:credential
                              clientConfiguration:conf];
}


#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler {
    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential , credential);
}


@end
