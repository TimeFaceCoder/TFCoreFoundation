//
//  TFCoreFoundationMacro.m
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFCoreFoundationMacro.h"

void TFAsyncRun(TFRun run) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        run();
    });
}

void TFMainRun(TFRun run) {
    dispatch_async_on_main_queue(^{
        run();
    });
}

NSString *  TF_APP_ERROR_DOMAIN        =      @"cn.timeface.corefoundation";

/////////////////////////////////////////////Common Error Code//////////////////////////////////////

NSInteger const kTFErrorCodeUnknown         = 0;
NSInteger const kTFErrorCodeAPI             = 1;
NSInteger const kTFErrorCodeHTTP            = 2;
NSInteger const kTFErrorCodeNetwork         = 3;
NSInteger const kTFErrorCodeEmpty           = 4;
NSInteger const kTFErrorCodeClassType       = 5;
NSInteger const kTFErrorCodeLocationError   = 6;
NSInteger const kTFErrorCodePhotosError     = 7;
NSInteger const kTFErrorCodeMicrophoneError = 8;
NSInteger const kTFErrorCodeCameraError     = 9;
NSInteger const kTFErrorCodeContactsError   = 10;


/////////////////////////////////////////////Common View State//////////////////////////////////////
NSInteger const kTFViewStateNone            = 0;
NSInteger const kTFViewStateLoading         = 1;
NSInteger const kTFViewStateNetError        = 2;
NSInteger const kTFViewStateDataError       = 3;
NSInteger const kTFViewStateNoData          = 4;
NSInteger const kTFViewStateTimeOut         = 5;
NSInteger const kTFViewStateLocationError   = 6;
NSInteger const kTFViewStatePhotosError     = 7;
NSInteger const kTFViewStateMicrophoneError = 8;
NSInteger const kTFViewStateCameraError     = 9;
NSInteger const kTFViewStateContactsError   = 10;

///////////////////////////////////////////Common ScrollDirection///////////////////////////////////
NSInteger const kTFScrollDirectionNone       = 0;
NSInteger const kTFScrollDirectionUp         = 1;
NSInteger const kTFScrollDirectionDown       = 2;
NSInteger const kTFScrollDirectionLeft       = 3;
NSInteger const kTFScrollDirectionRight      = 4;
NSInteger const kTFScrollDirectionVertical   = 5;
NSInteger const kTFScrollDirectionHorizontal = 6;


///////////////////////////////////////////Common Notification//////////////////////////////////////