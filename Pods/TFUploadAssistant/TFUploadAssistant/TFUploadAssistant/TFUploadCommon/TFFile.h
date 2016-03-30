//
//  TFFile.h
//  TFUploadAssistant
//
//  Created by Melvin on 3/23/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFFileProtocol.h"
@interface TFFile : NSObject<TFFileProtocol>

/**
 *    打开指定文件
 *
 *    @param path      文件路径
 *    @param error     输出的错误信息
 *
 *    @return 实例
 */
- (instancetype)init:(NSString *)path
               error:(NSError *__autoreleasing *)error;
@end
