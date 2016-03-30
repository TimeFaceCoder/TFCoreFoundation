//
//  TFAliUploadHandler.h
//  TFUploadAssistant
//
//  Created by Melvin on 3/23/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFUploadAssistant.h"

@interface TFAliUploadHandler : NSObject

@property (nonatomic ,strong) NSString *token;
@property (nonatomic ,copy) TFUpCompletionHandler completionHandler;
@property (nonatomic ,copy) TFUpProgressHandler progressHandler;
@property (nonatomic ,weak) id<TFUploadAssistantDelegate> delegate;

+ (TFAliUploadHandler*) uploadHandlerWithToken:(NSString *)token
                                 progressBlock:(TFUpProgressHandler)progressHandler
                               completionBlock:(TFUpCompletionHandler)completionHandler
                                           tag:(NSInteger)tag;

+ (TFAliUploadHandler*) uploadHandlerWithToken:(NSString *)token
                                      delegate:(id<TFUploadAssistantDelegate>)delegate;


@end
