//
//  TFSegmentConfigModel.m
//  TFCoreFoundation
//
//  Created by TFAppleWork-Summer on 2016/10/12.
//  Copyright © 2016年 TimeFace. All rights reserved.
//

#import "TFSegmentConfigModel.h"

@implementation TFSegmentConfigModel

- (instancetype)init {
    self = [super init];
    if (self) {
        //默认常量
        self.font = [UIFont systemFontOfSize:16];
        self.textColor = [UIColor blackColor];
        self.selectedTextColor = [UIColor blueColor];
        self.itemSpace = 10.0;
        self.itemMinWidth = 75.0;
        self.lineInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        self.lineCornerRadius = 0.0;
        self.lineColor = [UIColor cyanColor];
    }
    return self;
}

@end
