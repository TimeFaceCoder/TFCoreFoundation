//
//  TFValidateUtility.m
//  TFCoreFoundation
//
//  Created by Melvin on 4/19/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFValidateUtility.h"

@implementation TFValidateUtility

+ (BOOL)isNUll:(id)object{
    if (!object || [object isKindOfClass:[NSNull class]]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isBlankOrNull:(id)object {
    if (!object || [object isKindOfClass:[NSNull class]] || [[NSString stringWithFormat:@"%@",object] isEqualToString:@"<null>"] ||[[NSString stringWithFormat:@"%@",object] isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isWebUrl:(NSString *)str {
    NSRange range = [str rangeOfString:@"http://"];
    if (range.length > 0) {
        return YES;
    }
    return NO;
}

/**
 *  手机号码校验
 *
 *  @param mobileNum
 *
 *  @return
 */
+ (BOOL)isMobileNumber:(NSString *)mobileNum {
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9]|7[0-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[01349])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
/**
 *  短信验证码校验
 *
 *  @param str
 *
 *  @return
 */
+ (BOOL)validateVerifyCode:(NSString *)str {
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
                                              initWithPattern:@"^[0-9]{6}$"
                                              options:NSRegularExpressionCaseInsensitive
                                              error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:str
                                                                  options:NSMatchingReportProgress
                                                                    range:NSMakeRange(0, str.length)];
    if(numberofMatch > 0) {
        return YES;
    }
    return NO;
}

/**
 *  用户名校验
 *
 *  @param str
 *
 *  @return
 */
+ (BOOL) validateUserName:(NSString *)str {
    NSString *patternStr = [NSString stringWithFormat:@"^.{0,4}$|.{21,}|^[^A-Za-z0-9\u4E00-\u9FA5]|[^\\w\u4E00-\u9FA5.-]|([_.-])\1"];
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
                                              initWithPattern:patternStr
                                              options:NSRegularExpressionCaseInsensitive
                                              error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:str
                                                                  options:NSMatchingReportProgress
                                                                    range:NSMakeRange(0, str.length)];
    
    if(numberofMatch > 0) {
        return YES;
    }
    return NO;
}

/**
 *  密码校验
 *
 *  @param str
 *
 *  @return
 */
+ (BOOL) validateUserPassword:(NSString *) str {
    
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
                                              initWithPattern:@"^[a-zA-Z0-9_\\W]{6,16}$"
                                              options:NSRegularExpressionCaseInsensitive
                                              error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:str
                                                                  options:NSMatchingReportProgress
                                                                    range:NSMakeRange(0, str.length)];
    if(numberofMatch > 0) {
        return YES;
    }
    return NO;
}

/**
 *  生日日期校验
 *
 *  @param str
 *
 *  @return
 */
+ (BOOL) validateUserBirthday:(NSString *)str {
    NSString *patternStr = @"^((((1[6-9]|[2-9]\\d)\\d{2})-(0?[13578]|1[02])-(0?[1-9]|[12]\\d|3[01]))|(((1[6-9]|[2-9]\\d)\\d{2})-(0?[13456789]|1[012])-(0?[1-9]|[12]\\d|30))|(((1[6-9]|[2-9]\\d)\\d{2})-0?2-(0?[1-9]|1\\d|2[0-8]))|(((1[6-9]|[2-9]\\d)(0[48]|[2468][048]|[13579][26])|((16|[2468][048]|[3579][26])00))-0?2-29-))$";
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
                                              initWithPattern:patternStr
                                              options:NSRegularExpressionCaseInsensitive
                                              error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:str
                                                                  options:NSMatchingReportProgress
                                                                    range:NSMakeRange(0, str.length)];
    if(numberofMatch > 0) {
        return YES;
    }
    return NO;
}

/**
 *  手机号码校验
 *
 *  @param str
 *
 *  @return
 */
+ (BOOL) validateUserPhone:(NSString *)str {
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
                                              initWithPattern:@"((\\d{11})|^((\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1})|(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1}))$)"
                                              options:NSRegularExpressionCaseInsensitive
                                              error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:str
                                                                  options:NSMatchingReportProgress
                                                                    range:NSMakeRange(0, str.length)];
    
    if(numberofMatch > 0) {
        return YES;
    }
    return NO;
}

/**
 *  邮箱校验
 *
 *  @param str
 *
 *  @return
 */
+ (BOOL) validateUserEmail:(NSString *)str {
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
                                              initWithPattern:@"\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*"
                                              options:NSRegularExpressionCaseInsensitive
                                              error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:str
                                                                  options:NSMatchingReportProgress
                                                                    range:NSMakeRange(0, str.length)];
    if(numberofMatch > 0) {
        return YES;
    }
    return NO;
}
@end
