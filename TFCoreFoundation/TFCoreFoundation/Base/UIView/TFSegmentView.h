//
//  DCWorkGroupSegmentView.h
//  DigitalConference
//
//  Created by Summer on 16/6/13.
//  Copyright © 2016年 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFPageViewController.h"
#import "TFSegmentConfigModel.h"

typedef void(^SegmentViewChangeBlock)(NSInteger currentIndex,NSString *currentItem);

@interface TFSegmentView : UIView<SegmentViewDelegate>

@property (nonatomic, strong) NSArray *itemArr;///<数据数组

@property (nonatomic, assign) NSInteger currentItemIndex;///<当前选的项目索引

@property (nonatomic, copy) SegmentViewChangeBlock changeBlock;///<变化块

/**
 默认配置，当再次赋值时，会重新布局segmentView.
 */
@property (nonatomic, readonly) TFSegmentConfigModel *configModel;

/**
 *  初始化方法
 *
 *  @param itemArray 数据数组，注：必须是字符串类型
 *  @param configModel 默认segment配置包含字体等等
 *
 *  @return
 */
- (instancetype)initWithFrame:(CGRect)frame configModel:(TFSegmentConfigModel *)configModel itemArray:(NSArray<NSString *> *)itemArray;

/**
 *  初始化类方法
 *
 *  @param itemArray 同上
 *  @param configModel 默认segment配置包含字体等等
 *
 *  @return
 */
+ (instancetype)itemWithFrame:(CGRect)frame configModel:(TFSegmentConfigModel *)configModel itemArray:(NSArray<NSString *> *)itemArray;

/**
 *  更新底部线的位置
 *
 *  @param contentOffset
 *  @param contentWidth
 *  @param viewWidth
 *  @warning 使用该方法时，需将updateLinePosBySelf熟悉设置为NO
 */
- (void)segmentViewUpdateCurrentSelectedIndexByContentOffset:(CGFloat)contentOffset inContentWidth:(CGFloat)contentWidth viewWidth:(CGFloat)viewWith;
@end
