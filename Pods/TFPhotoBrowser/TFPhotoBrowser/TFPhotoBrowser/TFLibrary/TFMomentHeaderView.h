//
//  TFMomentHeaderView.h
//  TFPhotoBrowser
//
//  Created by Melvin on 2/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

static NSString *TFMomentHeaderViewNomalIdentifier = @"TFMomentHeaderViewNomal";
static NSString *TFMomentHeaderViewDetailIdentifier = @"TFMomentHeaderViewDetail";

@interface TFMomentHeaderNomalView : UICollectionReusableView

@property (nonatomic, strong) UIVisualEffectView *backView;///<背景view
@property (nonatomic, strong) UILabel *primaryLabel;///<主标题
@property (nonatomic, strong) UIButton *selectedButton;///<选择按钮
@property (nonatomic, strong) NSIndexPath  *indexPath;
@property (nonatomic, assign) BOOL  showAllSelectButton;

@end

@interface TFMomentHeaderDetailView : TFMomentHeaderNomalView

@property (nonatomic, strong) UILabel *secondaryLabel;///<副标题
@property (nonatomic, strong) UILabel *detailLabel;///<右边详情

@end

@interface TFMomentHeaderModel : NSObject

@property (nonatomic, strong) NSString *reuseIdentifier;///<重用标志符

@property (nonatomic, strong) NSString *primary;///<主标题

@property (nonatomic, strong) NSString *secondary;///<副标题

@property (nonatomic, strong) NSString *detail;///<详情

@end

NS_ASSUME_NONNULL_END