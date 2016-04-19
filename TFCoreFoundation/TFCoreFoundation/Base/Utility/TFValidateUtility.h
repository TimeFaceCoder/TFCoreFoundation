//
//  TFValidateUtility.h
//  TFCoreFoundation
//  各类数据校验工具
//  Created by Melvin on 4/19/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFValidateUtility : NSObject
/**
 *  校验手机号码合法性
 *
 *  @param phoneNumber
 *
 *  @return
 */
+ (BOOL)isMobilePhone:(NSString *)phoneNumber;

@end
