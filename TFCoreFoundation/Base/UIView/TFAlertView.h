//
//  TFAlertView.h
//  TFCoreFoundation
//
//  Created by Melvin on 4/11/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TFAlertType) {
    TFAlertSuccess,
    TFAlertFailure,
    TFAlertInfo
};

@class TFAlertView;

typedef void (^TFAlertClickBlock)(NSInteger index);

#define REDCOLOR    [UIColor colorWithRed:0.906 green:0.296 blue:0.235 alpha:1]



@interface TFAlertView : UIView

+ (id)showAlertWithTitle:(NSString *)title
                 content:(NSString *)content
               alertType:(TFAlertType)alertType
              clickBlock:(TFAlertClickBlock)clickBlock;

+ (id)showAlertWithTitle:(NSString *)title
                 content:(NSString *)content
              fisrtTitle:(NSString *)fisrtTitle
             secondTitle:(NSString *)secondTitle
               alertType:(TFAlertType)alertType
              clickBlock:(TFAlertClickBlock)clickBlock;

- (void)show;

@end
