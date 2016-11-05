//
//  TFUnReadCountLabel.m
//  TimeFaceV4
//
//  Created by TFAppleWork-Summer on 2016/11/2.
//  Copyright © 2016年 Summer. All rights reserved.
//

#import "TFUnReadCountLabel.h"
#import "TFDefaultStyle.h"
#import "TFCoreFoundationMacro.h"
#import "UIColor+TFCore.h"
#import "UIView+TFCore.h"

@implementation TFUnReadCountLabel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _defaultConfig];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _defaultConfig];
    }
    return self;
}

- (void)_defaultConfig {
    self.font = TFSTYLEVAR(font10);
    self.textColor = [UIColor whiteColor];
    self.contentInsets = UIEdgeInsetsMake(2.0, 4.0, 2.0, 4.0);
    self.textAlignment = NSTextAlignmentCenter;
    self.backgroundColor = [UIColor colorWithHexString:@"ef5e17"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = self.tf_height/2.0;
    self.layer.masksToBounds = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect rect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    //判断不存在的情况
    if ((self.text.length==0)|[self.text isEqualToString:@"0"]) {
        rect.size = CGSizeZero;
    }
    //设置宽度比较小时等于高度
    rect.size.width = MAX(rect.size.width, rect.size.height);
    return rect;
}

@end
