//
//  UIViewController+Toast.m
//  TFCoreFoundation
//
//  Created by zguanyu on 16/8/26.
//  Copyright © 2016年 TimeFace. All rights reserved.
//

#import "UIViewController+Toast.h"
#import "TFCoreFoundationMacro.h"
#import <SVProgressHUD/SVProgressHUD.h>
@implementation UIViewController (Toast)
- (void)showToastMessage:(NSString *)message messageType:(TFMessageType)messageType {
    TFMainRun(^{
        
        NSDictionary *dic = @{
                              @"message"     :   message ? message : @"",
                              @"type"        :   @(messageType)
                              };
        //        [self performSelector:@selector(showMessage:) withObject:dic afterDelay:.5f];
        
        [self showMessage:dic];
    });
}

- (void)showMessage:(NSDictionary*)params {
    NSString *message = [params objectForKey:@"message"];
    TFMessageType messageType  = [[params objectForKey:@"type"] integerValue];
    [SVProgressHUD setMinimumDismissTimeInterval:0.8];
    switch (messageType) {
        case TFMessageTypeDefault:
            [SVProgressHUD showWithStatus:message];
            break;
        case TFMessageTypeSuccess:
            [SVProgressHUD showSuccessWithStatus:message];
            break;
        case TFMessageTypeFaild:
            [SVProgressHUD showErrorWithStatus:message];
            break;
        default:
            [SVProgressHUD showInfoWithStatus:message];
            break;
    }
}

- (void)dismissToastView {
    TFMainRun(^{
        [SVProgressHUD dismiss];
    });
}
@end
