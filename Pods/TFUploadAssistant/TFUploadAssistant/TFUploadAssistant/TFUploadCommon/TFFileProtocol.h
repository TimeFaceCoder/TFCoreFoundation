//
//  TFFileProtocol.h
//  TFUploadAssistant
//
//  Created by Melvin on 3/23/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <MobileCoreServices/MobileCoreServices.h>

@protocol TFFileProtocol <NSObject>

/**
 *    从指定偏移读取数据
 *
 *    @param offset 偏移地址
 *    @param size   大小
 *
 *    @return 数据
 */
- (NSData *)read:(long)offset
            size:(long)size;

/**
 *    读取所有文件内容
 *
 *    @return 数据
 */
- (NSData *)readAll;

/**
 *    关闭文件
 *
 */
- (void)close;

/**
 *    文件路径
 *
 *    @return 文件路径
 */
- (NSString *)path;
/**
 *  文件扩展名
 *
 *  @return 文件扩展名
 */
- (NSString *)fileExtension;

/**
 *  文件创建时间
 *
 *  @return 文件创建时间
 */
- (int64_t)createdTime;

/**
 *    文件修改时间
 *
 *    @return 修改时间
 */
- (int64_t)modifyTime;

/**
 *  文件类型
 *
 *  @return
 */
- (NSString *)mimeType;
/**
 *    文件大小
 *
 *    @return 文件大小
 */
- (int64_t)size;

- (UIImageOrientation)orientation;

@end