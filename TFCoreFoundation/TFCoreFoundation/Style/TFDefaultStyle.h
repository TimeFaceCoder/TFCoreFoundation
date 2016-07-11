//
//  TFDefaultStyle.h
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFStyle.h"

@interface TFDefaultStyle : TFStyle

/////////////////////////////////////////////全局字体格式定义//////////////////////////////////////////

@property (nonatomic ,readonly) UIFont *font10;
@property (nonatomic ,readonly) UIFont *font10B;

@property (nonatomic ,readonly) UIFont *font12;
@property (nonatomic ,readonly) UIFont *font12B;

@property (nonatomic ,readonly) UIFont *font14;
@property (nonatomic ,readonly) UIFont *font14B;

@property (nonatomic ,readonly) UIFont *font16;
@property (nonatomic ,readonly) UIFont *font16B;

@property (nonatomic ,readonly) UIFont *font18;
@property (nonatomic ,readonly) UIFont *font18B;

/////////////////////////////////////////////全局颜色定义//////////////////////////////////////////

@property (nonatomic ,readonly) UIColor *viewBackgroundColor;

@property (nonatomic ,readonly) UIColor *navBarBackgroundColor;

@property (nonatomic ,readonly) UIFont  *navBarTitleFont;

@property (nonatomic ,readonly) UIColor *navBarTitleColor;

/////////////////////////////////////////////HUD提示-START//////////////////////////////////////////
@property (nonatomic ,readonly) UIFont  *loadingTextFont;
@property (nonatomic ,readonly) UIColor *loadingTextColor;
@property (nonatomic ,readonly) UIColor *loadingLineColor;
/////////////////////////////////////////////HUD提示-END////////////////////////////////////////////



///////////////////////////////////////////AlertView样式定义/////////////////////////////////////////
@property (nonatomic ,readonly) UIColor *alertCancelColor;
@property (nonatomic ,readonly) UIColor *alertCancelHColor;
@property (nonatomic ,readonly) UIColor *alertOKColor;
@property (nonatomic ,readonly) UIColor *alertOKHColor;
@property (nonatomic ,readonly) UIColor *alertLineColor;
@property (nonatomic ,readonly) UIColor *alertTitleColor;
@property (nonatomic ,readonly) UIColor *alertContentColor;
///////////////////////////////////////////ViewState自定义/////////////////////////////////////////

@property (nonatomic ,readonly) UIColor *viewStateBackgroundColor;

@property (nonatomic ,readonly) UIColor *viewStateButtonBackgroundColor;

@property (nonatomic ,readonly) CGSize viewStateButtonSize;

@property (nonatomic ,readonly) CGFloat viewStateSpaceHeight;

@property (nonatomic ,readonly) CGFloat viewStateButtonCornerRadius;

@property (nonatomic ,readonly) UIColor *viewStateButtonBorderColor;

@property (nonatomic ,readonly) NSString *viewStateDataErrorTitle;///<数据错误提示文本

@property (nonatomic ,readonly) NSString *viewStateDataErrorButtonTitle;///<数据错误底部按钮提示文本
@property (nonatomic ,readonly) NSString *viewStateDataErrorImage;///<数据错误图片

@property (nonatomic ,readonly) NSString *viewStateDataLoadingTitle;///<数据正在加载提示文本

@property (nonatomic ,readonly) NSString *viewStateDataNetErrorTitle;///<网络错误提示文本

@property (nonatomic ,readonly) NSString *viewStateDataNetErrorImage;///<网络错误图片

@property (nonatomic ,readonly) NSString *viewStateDataNetErrorButtonTitle;///<网络错误底部按钮提示文本

@property (nonatomic ,readonly) NSString *viewStateDataNoDataTitle;///<没有数据错误提示文本

@property (nonatomic ,readonly) NSString *viewStateDataNoDataButtonTitle;///<没有数据错误提示文本

@property (nonatomic ,readonly) NSString *viewStateDataNoDataImage;///<没有数据图片

@property (nonatomic ,readonly) NSString *viewStateDataTimeOutTitle;///<网络超时提示文本

@property (nonatomic ,readonly) NSString *viewStateDataTimeOutButtonTitle;///<没有数据错误提示文本
@property (nonatomic ,readonly) UIImage *viewStateButtonBackgroundImage;///<按钮的背景图片



@end
