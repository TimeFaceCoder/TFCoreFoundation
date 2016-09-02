//
//  UIViewController+Toast.h
//  TFCoreFoundation
//
//  Created by zguanyu on 16/8/26.
//  Copyright © 2016年 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>
// toast提示类型
typedef NS_ENUM (NSInteger, TFMessageType) {
    /**
     *  默认提示
     */
    TFMessageTypeDefault = 0,
    /**
     *  成功提示
     */
    TFMessageTypeSuccess = 1,
    /**
     *  失败提示
     */
    TFMessageTypeFaild   = 2,
    /**
     *  一般性消息提示
     */
    TFMessageTypeInfo    = 3
};

@interface UIViewController (Toast)

- (void)showToastMessage:(NSString *)message messageType:(TFMessageType)messageType;

- (void)dismissToastView;
@end
