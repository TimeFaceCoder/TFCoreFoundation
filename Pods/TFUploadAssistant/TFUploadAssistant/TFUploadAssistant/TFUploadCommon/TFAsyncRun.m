//
//  TFAsyncRun.m
//  TFUploadAssistant
//
//  Created by Melvin on 3/23/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFAsyncRun.h"

void TFAsyncRun(TFRun run) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        run();
    });
}

void TFAsyncRunInMain(TFRun run) {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        run();
    });
}
