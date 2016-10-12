//
//  TFSegmentConfigModel.m
//  TFCoreFoundation
//
//  Created by TFAppleWork-Summer on 2016/10/12.
//  Copyright © 2016年 TimeFace. All rights reserved.
//

#import "TFSegmentConfigModel.h"
#import "UIColor+TFCore.h"

@implementation TFSegmentConfigModel

- (instancetype)init {
    self = [super init];
    if (self) {
        //默认常量
        self.font = [UIFont systemFontOfSize:16];
        self.textColor = UIColorHex(0x333333);
        self.selectedTextColor = UIColorHex(0x2f83eb);
        self.itemSpace = 10.0;
        self.itemMinWidth = 75.0;
        self.lineInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        self.lineCornerRadius = 0.0;
        self.lineColor = UIColorHex(0x2f83eb);
    }
    return self;
}

@end
