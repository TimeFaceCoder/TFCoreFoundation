//
//  TFAliUploadHandler.m
//  TFUploadAssistant
//
//  Created by Melvin on 3/23/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFAliUploadHandler.h"

@implementation TFAliUploadHandler


+ (TFAliUploadHandler*) uploadHandlerWithToken:(NSString *)token
                                 progressBlock:(TFUpProgressHandler)progressHandler
                               completionBlock:(TFUpCompletionHandler)completionHandler
                                           tag:(NSInteger)tag {
    TFAliUploadHandler *handler = [TFAliUploadHandler new];
    handler.token = token;
    handler.progressHandler = progressHandler;
    handler.completionHandler = completionHandler;
    return handler;
}

+ (TFAliUploadHandler*) uploadHandlerWithToken:(NSString *)token
                                      delegate:(id<TFUploadAssistantDelegate>)delegate {
    TFAliUploadHandler *handler = [TFAliUploadHandler new];
    handler.token = token;
    handler.delegate = delegate;
    return handler;
}

@end
