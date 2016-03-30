//
//  TFResponseInfo.h
//  TFUploadAssistant
//
//  Created by Melvin on 3/23/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *    中途取消的状态码
 */
extern NSInteger const kTFRequestCancelled;

/**
 *    网络错误状态码
 */
extern NSInteger const kTFNetworkError;

/**
 *    错误参数状态码
 */
extern NSInteger const kTFInvalidArgument;

/**
 *    0 字节文件或数据
 */
extern NSInteger const kTFZeroDataSize;

/**
 *    错误token状态码
 */
extern NSInteger const kTFInvalidToken;

/**
 *    读取文件错误状态码
 */
extern NSInteger const kTFFileError;


@interface TFResponseInfo : NSObject
/**
 *  状态码
 */
@property (readonly) NSInteger statusCode;
/**
 *  错误信息
 */
@property (nonatomic, copy, readonly) NSError *error;
/**
 *  请求消耗时间
 */
@property (nonatomic, readonly) double duration;
/**
 *  时间戳
 */
@property (readonly) UInt64 timeStamp;

/**
 *  是否取消
 */
@property (nonatomic, readonly, getter = isCancelled) BOOL canceled;
/**
 *  成功的请求
 */
@property (nonatomic, readonly, getter = isOK) BOOL ok;
/**
 *  是否网络错误
 */
@property (nonatomic, readonly, getter = isConnectionBroken) BOOL broken;
/**
 *  是否重试
 */
@property (nonatomic, readonly) BOOL couldRetry;

/**
 *    工厂函数，内部使用
 *
 *    @return 取消的实例
 */
+ (instancetype)cancel;

/**
 *    工厂函数，内部使用
 *
 *    @param desc 错误参数描述
 *
 *    @return 错误参数实例
 */
+ (instancetype)responseInfoWithInvalidArgument:(NSString *)desc;

/**
 *    工厂函数，内部使用
 *
 *    @param desc 错误token描述
 *
 *    @return 错误token实例
 */
+ (instancetype)responseInfoWithInvalidToken:(NSString *)desc;

/**
 *    工厂函数，内部使用
 *
 *    @param error 错误信息
 *    @param duration 请求完成时间，单位秒
 *
 *    @return 网络错误实例
 */
+ (instancetype)responseInfoWithNetError:(NSError *)error
                                duration:(double)duration;

/**
 *    工厂函数，内部使用
 *
 *    @param error 错误信息
 *
 *    @return 文件错误实例
 */
+ (instancetype)responseInfoWithFileError:(NSError *)error;

/**
 *    工厂函数，内部使用
 *
 *    @return 文件错误实例
 */
+ (instancetype)responseInfoOfZeroData:(NSString *)path;

/**
 *    构造函数
 *
 *    @param status 状态码
 *    @param duration 请求完成时间，单位秒
 *
 *    @return 实例
 */
- (instancetype)initWithStatusCode:(NSInteger)statusCode
                      withDuration:(double)duration
                          withBody:(NSData *)body;



@end
