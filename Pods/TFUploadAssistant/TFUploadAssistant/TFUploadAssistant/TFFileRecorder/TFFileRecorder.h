//
//  TFFileRecorder.h
//  TFUploadAssistant
//  上传记录持久化管理
//  Created by Melvin on 3/23/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFFileRecorder : NSObject


+ (instancetype)sharedInstance;

/**
 *    用指定保存的目录进行初始化
 *
 *    @param directory 目录
 *    @param error     输出的错误信息
 *
 *    @return 实例
 */
+ (instancetype)fileRecorderWithFolder:(NSString *)directory
                                 error:(NSError *__autoreleasing *)error;

/**
 *    用指定保存的目录，以及是否进行base64编码进行初始化，
 *
 *    @param directory 目录
 *    @param encode    为避免因为特殊字符或含有/，无法保存持久化记录，故用此参数指定是否要base64编码
 *    @param error     输出错误信息
 *
 *    @return 实例
 */
+ (instancetype)fileRecorderWithFolder:(NSString *)directory
                             encodeKey:(BOOL)encode
                                 error:(NSError *__autoreleasing *)error;

/**
 *    保存记录
 *
 *    @param key   持久化记录的key
 *    @param value 持久化记录信息
 *
 *    @return 错误信息，成功为nil
 */
- (NSError *)set:(NSString *)key
          object:(id)object;

/**
 *    取出保存的持久化信息
 *
 *    @param key 持久化记录key
 *
 *    @return 上传中间状态信息
 */
- (id)get:(NSString *)key;

/**
 *    删除持久化记录，一般在上传成功后自动调用
 *
 *    @param key 持久化记录key
 *
 *    @return 错误信息，成功为nil
 */
- (NSError *)del:(NSString *)key;

@end
