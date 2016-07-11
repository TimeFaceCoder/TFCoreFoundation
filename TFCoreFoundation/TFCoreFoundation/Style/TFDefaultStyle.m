//
//  TFDefaultStyle.m
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFDefaultStyle.h"
#import "TFCoreFoundationMacro.h"
#import "UIColor+TFCore.h"
#import "UIImage+TFCore.h"

@implementation TFDefaultStyle

/////////////////////////////////////////////全局字体格式定义//////////////////////////////////////////

- (UIFont *)font10 {
    return [UIFont systemFontOfSize:10];
}
- (UIFont *)font10B {
    return [UIFont boldSystemFontOfSize:10];
}

- (UIFont *)font12 {
    return [UIFont systemFontOfSize:12];
}
- (UIFont *)font12B {
    return [UIFont boldSystemFontOfSize:12];
}

- (UIFont *)font14 {
    return [UIFont systemFontOfSize:14];
}

- (UIFont *)font14B {
    return [UIFont boldSystemFontOfSize:14];
}

- (UIFont *)font16 {
    return [UIFont systemFontOfSize:16];
}

- (UIFont *)font16B {
    return [UIFont boldSystemFontOfSize:16];
}

- (UIFont *)font18 {
    return [UIFont systemFontOfSize:18];
}

- (UIFont *)font18B {
    return [UIFont boldSystemFontOfSize:18];
}

/////////////////////////////////////////////全局颜色定义//////////////////////////////////////////

- (UIColor *)viewBackgroundColor {
    return RGBCOLOR(226,230,236);
}

- (UIColor *)navBarBackgroundColor {
    return RGBCOLOR(180, 0, 27);
}

- (UIFont *)navBarTitleFont {
    return [UIFont systemFontOfSize:20];
}

- (UIColor *)navBarTitleColor {
    return [UIColor whiteColor];
}


///////////////////////////////////////////AlertView样式定义/////////////////////////////////////////
- (UIColor *)alertCancelColor {
    return [self getColorByHex:@"b5b5b5"];
}
- (UIColor *)alertCancelHColor {
    return [self getColorByHex:@"a9a9a9"];
}
- (UIColor *)alertOKColor {
    return [self getColorByHex:@"069bf2"];
}
- (UIColor *)alertOKHColor {
    return [self getColorByHex:@"058ccd"];
}
- (UIColor *)alertLineColor {
    return [self getColorByHex:@"9b9b9b"];
}
- (UIColor *)alertTitleColor {
    return [self getColorByHex:@"069bf2"];
}
- (UIColor *)alertContentColor {
    return [self getColorByHex:@"333333"];
}






/////////////////////////////////////////////HUD提示-START//////////////////////////////////////////
- (UIFont *)loadingTextFont {
    return [UIFont systemFontOfSize:16];
}
- (UIColor *)loadingTextColor {
    return [self getColorByHex:@"7c7c7c"];
}
- (UIColor *)loadingLineColor {
    return [self getColorByHex:@"dfdfdf"];
}
/////////////////////////////////////////////HUD提示-END////////////////////////////////////////////

///////////////////////////////////////////ViewState自定义/////////////////////////////////////////

- (UIColor *)viewStateBackgroundColor {
    return RGBCOLOR(226,230,236);
}

- (UIColor *)viewStateButtonBackgroundColor {
    return [UIColor whiteColor];
}

- (CGSize)viewStateButtonSize {
    return CGSizeMake(200.0, 40.0);
}

- (CGFloat)viewStateButtonCornerRadius {
    return 5.0;
}

- (UIColor *)viewStateButtonBorderColor {
    return [self getColorByHex:@"dfdfdf"];
}


- (NSString *)viewStateDataErrorTitle {
    return NSLocalizedString(@"网络数据异常", nil);
}

- (NSString *)viewStateDataErrorButtonTitle {
    return NSLocalizedString(@"重新加载", nil);
}

- (NSString *)viewStateDataErrorImage {
    return NSLocalizedString(@"ViewDataError", nil);
}

- (NSString *)viewStateDataLoadingTitle {
    return NSLocalizedString(@"正在加载数据", nil);;
}

- (NSString *)viewStateDataNetErrorTitle {
    return NSLocalizedString(@"网络连接错误", nil);
}

- (NSString *)viewStateDataNetErrorButtonTitle {
    return NSLocalizedString(@"设置网络", nil);
}

- (NSString *)viewStateDataNetErrorImage {
    return NSLocalizedString(@"ViewDataNetError", nil);
}

- (NSString *)viewStateDataNoDataTitle {
    return NSLocalizedString(@"网络数据为空", nil);
}

- (NSString *)viewStateDataNoDataButtonTitle {
    return NSLocalizedString(@"暂无内容", nil);
}

- (NSString *)viewStateDataNoDataImage {
    return NSLocalizedString(@"ViewDataNoData", nil);
}

- (NSString *)viewStateDataTimeOutTitle {
    return  NSLocalizedString(@"网络连接超时", nil);
}

- (CGFloat)viewStateSpaceHeight {
    return 10.0;
}



@end
