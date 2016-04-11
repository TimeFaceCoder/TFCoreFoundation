//
//  TFViewController.h
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TFNavigator/TFNavigator.h>
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


@interface TFViewController : UIViewController

@property (nonatomic ,strong) NSMutableDictionary *requestParams;
@property (nonatomic ,assign) NSInteger viewState;

- (void)showToastMessage:(NSString *)message messageType:(TFMessageType)messageType;
- (void)dismissToastView;


- (void)showStateView:(NSInteger)viewState;

- (void)removeStateView;

- (NSString *)stateViewTitle:(NSInteger)viewState;
- (NSString *)stateViewButtonTitle:(NSInteger)viewState;
- (UIImage *)stateViewImage:(NSInteger)viewState;

@end
