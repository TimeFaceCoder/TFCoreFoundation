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
 *  校验对象是否为空
 *
 *  @param object
 *
 *  @return
 */
+ (BOOL)isNUll:(id)object;
+ (BOOL)isBlankOrNull:(id)object;
+ (BOOL)isWebUrl:(NSString *)str;

/**
 *  手机号码校验
 *
 *  @param mobileNum
 *
 *  @return
 */
+ (BOOL)isMobileNumber:(NSString *)mobileNum;

/**
 *  短信验证码校验
 *
 *  @param str
 *
 *  @return
 */
+ (BOOL)validateVerifyCode:(NSString *)str;

/**
 *  用户名校验
 *
 *  @param str
 *
 *  @return
 */
+ (BOOL) validateUserName:(NSString *)str;

/**
 *  密码校验
 *
 *  @param str
 *
 *  @return
 */
+ (BOOL) validateUserPassword:(NSString *) str;

/**
 *  生日日期校验
 *
 *  @param str
 *
 *  @return
 */
+ (BOOL) validateUserBirthday:(NSString *)str;

/**
 *  手机号码校验
 *
 *  @param str
 *
 *  @return
 */
+ (BOOL) validateUserPhone:(NSString *)str;

/**
 *  邮箱校验
 *
 *  @param str
 *
 *  @return
 */
+ (BOOL) validateUserEmail:(NSString *)str;

@end
