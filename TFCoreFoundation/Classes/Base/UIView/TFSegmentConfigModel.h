//
//  TFSegmentConfigModel.h
//  TFCoreFoundation
//
//  Created by TFAppleWork-Summer on 2016/10/12.
//  Copyright © 2016年 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TFSegmentConfigModel : NSObject

@property (nonatomic, strong) UIFont *font;///<字体 默认14 默认16.0

@property (nonatomic, strong) UIColor *textColor;///<字体颜色 默认333333

@property (nonatomic, strong) UIColor *selectedTextColor;///<选中字体颜色 默认2f83eb

@property (nonatomic, assign) CGFloat itemSpace;///<Item之间的间距 默认10.0

@property (nonatomic, assign) CGFloat itemMinWidth;///<固定的最小间距 默认75.0,

@property (nonatomic, assign) UIEdgeInsets lineInsets;///<线view的插入边距，默认(self.height - 4, 0.0, 0, 0.0)

@property (nonatomic, assign) CGFloat lineCornerRadius;///<线的圆角角度， 默认0

@property (nonatomic, strong) UIColor *lineColor;///<线的颜色，默认2f83eb

@end
