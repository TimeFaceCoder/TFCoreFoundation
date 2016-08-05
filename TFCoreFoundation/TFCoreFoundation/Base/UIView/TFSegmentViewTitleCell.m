//
//  DCTitleCollectionViewCell.m
//  DigitalConference
//
//  Created by Summer on 16/6/13.
//  Copyright © 2016年 TimeFace. All rights reserved.
//

#import "TFSegmentViewTitleCell.h"

@implementation TFSegmentViewTitleCell

#pragma mark titleLabel
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor blackColor];
        
    }
    return _titleLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
//        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.mas_equalTo(UIEdgeInsetsZero);
//        }];
        _titleLabel.frame = self.bounds;
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _titleLabel.frame = self.bounds;
}

@end
