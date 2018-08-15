//
//  TFInsetsLabel.m
//  TimeFaceV4
//
//  Created by TFAppleWork-Summer on 2016/11/2.
//  Copyright © 2016年 Summer. All rights reserved.
//

#import "TFInsetsLabel.h"

@implementation TFInsetsLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init {
    self = [super init];
    if (self) {
        self.contentInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    return UIEdgeInsetsInsetRect(textRect, UIEdgeInsetsMake(-self.contentInsets.top, -self.contentInsets.left, -self.contentInsets.bottom, -self.contentInsets.right));
}

@end
