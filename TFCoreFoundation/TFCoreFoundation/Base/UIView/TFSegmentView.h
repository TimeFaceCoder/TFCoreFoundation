//
//  DCWorkGroupSegmentView.h
//  DigitalConference
//
//  Created by Summer on 16/6/13.
//  Copyright © 2016年 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFPageViewController.h"
typedef void(^SegmentViewChangeBlock)(NSInteger currentIndex,NSString *currentItem);

@interface TFSegmentView : UIView<SegmentViewDelegate>

@property (nonatomic, assign) CGFloat lineHeight;///<底部线的高度，默认4pt

@property (nonatomic, assign) CGFloat lineSpace;///<线的边距,默认15pt

@property (nonatomic, strong) UIColor *lineColor;///<线的颜色

@property (nonatomic, strong) UIFont *font;///<字体

@property (nonatomic, strong) UIColor *textColor;///<字体颜色

@property (nonatomic, strong) UIColor *selectedTextColor;///<选中字体颜色

@property (nonatomic, strong) NSArray *itemArr;///<数据数组

@property (nonatomic, assign) NSInteger currentItemIndex;///<当前选的项目

@property (nonatomic, copy) SegmentViewChangeBlock changeBlock;///<变化块

@property (nonatomic, assign) BOOL updateLinePosBySelf;///<line是否由segmentView自己更新位置，默认是YES

/**
 *  初始化方法
 *
 *  @param itemArray 数据数组，注：必须是字符串类型
 *
 *  @return
 */
- (instancetype)initWithFrame:(CGRect)frame itemArray:(NSArray<NSString *> *)itemArray;

/**
 *  初始化类方法
 *
 *  @param itemArray 同上
 *
 *  @return
 */
+ (instancetype)itemWithFrame:(CGRect)frame itemArray:(NSArray<NSString *> *)itemArray;


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
