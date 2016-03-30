//
//  TFAliUploadOperation.h
//  TFUploadAssistant
//
//  Created by Melvin on 3/23/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFUploadAssistant.h"

@interface TFAliUploadOperation : NSObject

- (nonnull instancetype) initWithData:(nonnull NSData *)data
                                  key:(nonnull NSString *)key
                                token:(nonnull NSString *)token
                             progress:(nonnull TFUpProgressHandler)progressHandler
                             complete:(nonnull TFUpCompletionHandler)completionHandler
                               config:(nonnull TFConfiguration *)configuration;

+ (nonnull instancetype)uploadOperationWithData:(nonnull NSData *)data
                                            key:(nonnull NSString *)key
                                          token:(nonnull NSString *)token
                                       progress:(nonnull TFUpProgressHandler)progressHandler
                                       complete:(nonnull TFUpCompletionHandler)completionHandler
                                         config:(nonnull TFConfiguration *)configuration;

- (void)start;

@end
