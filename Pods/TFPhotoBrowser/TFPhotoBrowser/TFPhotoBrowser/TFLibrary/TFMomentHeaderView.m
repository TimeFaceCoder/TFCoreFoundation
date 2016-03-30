//
//  TFMomentHeaderView.m
//  TFPhotoBrowser
//
//  Created by Melvin on 2/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFMomentHeaderView.h"

@interface TFMomentHeaderView () {
    UIVisualEffectView *_backgroundView;
    UIView *_centeringView;
}
@end

@implementation TFMomentHeaderView

- (void)_init {
    _backgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_backgroundView];
    
    _centeringView = [[UIView alloc] init];
    _centeringView.translatesAutoresizingMaskIntoConstraints = NO;
//    _centeringView.layer.borderWidth = 1;
    [self addSubview:_centeringView];
    
    _primaryLabel = [[UILabel alloc] init];
    _primaryLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    _primaryLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_centeringView addSubview:_primaryLabel];
    
    _secondaryLabel = [[UILabel alloc] init];
    _secondaryLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    _secondaryLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [_centeringView addSubview:_secondaryLabel];
    
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _detailLabel.textColor = [UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1];

    [_centeringView addSubview:_detailLabel];
    [_detailLabel setContentHuggingPriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
    
    _selectedButton = [[UIButton alloc]init];
    _selectedButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_selectedButton setTitleColor:[UIColor colorWithRed:6/255.0f green:155/255.0f blue:242/255.0f alpha:1] forState:UIControlStateNormal];
    [_selectedButton setTitle:@"全选" forState:UIControlStateNormal];
    [_selectedButton setTitle:@"取消全选" forState:UIControlStateSelected];
    _selectedButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    [_selectedButton setImage:[UIImage imageNamed:@"TFLibraryResource.bundle/images/TFLibraryCollectionUnSelected.png"] forState:UIControlStateNormal];
    [_selectedButton setImage:[UIImage imageNamed:@"TFLibraryResource.bundle/images/TFLibraryCollectionSelected.png"] forState:UIControlStateSelected];
    [_selectedButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
    [_selectedButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [_selectedButton addTarget:self action:@selector(onViewClick:) forControlEvents:UIControlEventTouchUpInside];

    [_centeringView addSubview:_selectedButton];
    
    
    [NSLayoutConstraint activateConstraints:@[
                                              [NSLayoutConstraint constraintWithItem:_backgroundView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0],
                                              [NSLayoutConstraint constraintWithItem:_backgroundView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
                                              [NSLayoutConstraint constraintWithItem:_backgroundView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
                                              [NSLayoutConstraint constraintWithItem:_backgroundView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                                              
                                              [NSLayoutConstraint constraintWithItem:_centeringView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:8],
                                              [NSLayoutConstraint constraintWithItem:_centeringView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:-8],
                                              [NSLayoutConstraint constraintWithItem:_centeringView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0],
                                              
                                              [NSLayoutConstraint constraintWithItem:_primaryLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_centeringView attribute:NSLayoutAttributeTop multiplier:1 constant:0],
                                              [NSLayoutConstraint constraintWithItem:_primaryLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_centeringView attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
                                              [NSLayoutConstraint constraintWithItem:_primaryLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_selectedButton attribute:NSLayoutAttributeLeading multiplier:1 constant:-8],
                                              [NSLayoutConstraint constraintWithItem:_primaryLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_centeringView attribute:NSLayoutAttributeWidth multiplier:1 constant:-112],
                                              
                                              
                                              [NSLayoutConstraint constraintWithItem:_selectedButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_centeringView attribute:NSLayoutAttributeTop multiplier:1 constant:0],
                                              [NSLayoutConstraint constraintWithItem:_selectedButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_primaryLabel attribute:NSLayoutAttributeTrailing multiplier:1 constant:8],
                                              [NSLayoutConstraint constraintWithItem:_selectedButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_centeringView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
                                              [NSLayoutConstraint constraintWithItem:_selectedButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_detailLabel attribute:NSLayoutAttributeTop multiplier:1 constant:0],
                                              
                                              
                                              
                                              [NSLayoutConstraint constraintWithItem:_secondaryLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_primaryLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                                              [NSLayoutConstraint constraintWithItem:_secondaryLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_centeringView attribute:NSLayoutAttributeLeading multiplier:1 constant:0],
                                              [NSLayoutConstraint constraintWithItem:_secondaryLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_centeringView attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                                              
                                              [NSLayoutConstraint constraintWithItem:_detailLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_selectedButton attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                                              [NSLayoutConstraint constraintWithItem:_detailLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_secondaryLabel attribute:NSLayoutAttributeTrailing multiplier:1 constant:8],
                                              [NSLayoutConstraint constraintWithItem:_detailLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_centeringView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0],
                                              [NSLayoutConstraint constraintWithItem:_detailLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_centeringView attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                                              ]];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

//- (void)prepareForReuse {
//    [super prepareForReuse];
//    _primaryLabel.text = nil;
//    _secondaryLabel.text = nil;
//    _detailLabel.text = nil;
//    _selectedButton.titleLabel.text = nil;
//}

- (void)onViewClick:(id)sender {
    UIButton *button = (UIButton*)sender;
    button.selected = !button.selected;
    
    NSDictionary *userInfo = @{
                               @"indexPath" : self.indexPath,
                               @"state"     : [NSString stringWithFormat:@"%@",@(button.selected)]
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTICE_RELOAD_COLLECTION_INDEXPATH" object:nil userInfo:userInfo];
}


@end
