//
//  TFMomentHeaderView.m
//  TFPhotoBrowser
//
//  Created by Melvin on 2/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFMomentHeaderView.h"
#import "TFPhotoBrowserBundle.h"

@interface TFMomentHeaderNomalView ()


@end

@implementation TFMomentHeaderNomalView

#pragma mark backView
- (UIVisualEffectView *)backView {
    if (!_backView) {
        _backView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        _backView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _backView;
}

#pragma mark primaryLabel
- (UILabel *)primaryLabel {
    if (!_primaryLabel) {
        _primaryLabel = [[UILabel alloc] init];
        _primaryLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _primaryLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _primaryLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _primaryLabel;
}


#pragma mark selectedButton
- (UIButton *)selectedButton {
    if (!_selectedButton) {
        _selectedButton = [[UIButton alloc]init];
        _selectedButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_selectedButton setTitleColor:[UIColor colorWithRed:6/255.0f green:155/255.0f blue:242/255.0f alpha:1] forState:UIControlStateNormal];
        
        [_selectedButton setTitle:TFPhotoBrowserLocalizedStrings(@"Select all") forState:UIControlStateNormal];
        [_selectedButton setTitle:TFPhotoBrowserLocalizedStrings(@"Deselect all") forState:UIControlStateSelected];
        [_selectedButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        _selectedButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        [_selectedButton addTarget:self action:@selector(onViewClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectedButton;
}

#pragma mark 载入视图
- (void)initSubViews {
    //添加subview
    [self addSubview:self.backView];
    [self addSubview:self.primaryLabel];
    [self addSubview:self.selectedButton];
    
    //添加约束
    NSDictionary *viewsDic = @{@"backView":self.backView,
                               @"primaryLabel":self.primaryLabel,
                               @"selectedButton":self.selectedButton,
                               };
    NSDictionary *metricsDic = @{@"hSpace":@8.0,
                                 @"vSpace":@5.0,
                                 };
    NSMutableArray *constraintsArr = [NSMutableArray array];
    
    //模糊背景
    [constraintsArr addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[backView]-0-|" options:0 metrics:nil views:viewsDic]];
    [constraintsArr addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[backView]-0-|" options:0 metrics:nil views:viewsDic]];
    //主标题和副标题
    [constraintsArr addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10.0-[primaryLabel]-10.0-|" options:0 metrics:metricsDic views:viewsDic]];
    
    
    //选择按钮和右边详情
    [constraintsArr addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vSpace-[selectedButton]-vSpace-|" options:NSLayoutFormatAlignAllRight metrics:metricsDic views:viewsDic]];
    [constraintsArr addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hSpace-[primaryLabel]-hSpace-[selectedButton]-hSpace-|" options:0 metrics:metricsDic views:viewsDic]];
    
    [NSLayoutConstraint activateConstraints:constraintsArr];
    
}


#pragma mark 初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

#pragma mark 全选按钮点击
- (void)onViewClick:(id)sender {
    UIButton *button = (UIButton*)sender;
//    button.selected = !button.selected;
    
    NSDictionary *userInfo = @{
                               @"indexPath" : self.indexPath,
                               @"button"     :button
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTICE_RELOAD_COLLECTION_INDEXPATH" object:nil userInfo:userInfo];
}

@end

@implementation TFMomentHeaderDetailView

#pragma mark secondaryLabel
- (UILabel *)secondaryLabel {
    if (!_secondaryLabel) {
        _secondaryLabel = [[UILabel alloc] init];
        _secondaryLabel.font = [UIFont systemFontOfSize:11];
        _secondaryLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _secondaryLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _secondaryLabel;
}

#pragma mark detailLabel
- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont systemFontOfSize:11];
        _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _detailLabel;
}

#pragma mark 重写初始化方法写视图
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

#pragma mark 载入视图
- (void)initSubViews {
    //添加subview
    [self addSubview:self.backView];
    [self addSubview:self.primaryLabel];
    [self addSubview:self.secondaryLabel];
    [self addSubview:self.detailLabel];
    [self addSubview:self.selectedButton];
    //添加约束
    NSDictionary *viewsDic = @{@"backView":self.backView,
                               @"primaryLabel":self.primaryLabel,
                               @"secondaryLabel":self.secondaryLabel,
                               @"detailLabel":self.detailLabel,
                               @"selectedButton":self.selectedButton,
                               };
    NSDictionary *metricsDic = @{@"hSpace":@8.0,
                                 @"vSpace":@5.0,
                                 };
    NSMutableArray *constraintsArr = [NSMutableArray array];
    
    //模糊背景
    [constraintsArr addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[backView]-0-|" options:0 metrics:nil views:viewsDic]];
    [constraintsArr addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[backView]-0-|" options:0 metrics:nil views:viewsDic]];
    //主标题和副标题
    [constraintsArr addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vSpace-[primaryLabel]-(-4)-[secondaryLabel]-vSpace-|" options:NSLayoutFormatAlignAllLeft metrics:metricsDic views:viewsDic]];
    
    
    //选择按钮和右边详情
    [constraintsArr addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-vSpace-[selectedButton]-(-4)-[detailLabel]-vSpace-|" options:NSLayoutFormatAlignAllRight metrics:metricsDic views:viewsDic]];
    //水平方向
    [constraintsArr addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hSpace-[primaryLabel]-hSpace-[selectedButton]-hSpace-|" options:0 metrics:metricsDic views:viewsDic]];
    [constraintsArr addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[secondaryLabel]-hSpace-[detailLabel]" options:0 metrics:metricsDic views:viewsDic]];
    
    [NSLayoutConstraint activateConstraints:constraintsArr];
    
}




@end

@implementation TFMomentHeaderModel


@end

