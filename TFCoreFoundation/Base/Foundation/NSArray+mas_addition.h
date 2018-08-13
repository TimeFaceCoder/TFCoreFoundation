//
//  NSArray+mas_addition.h
//  JALabor
//
//  Created by leoking870 on 16/9/30.
//  Copyright © 2016年 leoking870. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Masonry.h>
typedef enum : NSUInteger {
    MASAlignChildrenSpaceAround,    // 两边有间隔、是中间间隔一半
    MASAlignChildrenSpaceBetween,   // 两边无间隔
    
} MASAlignChildrenSpaceType;


#define SPACE_NOT_NEED  -1

@interface NSArray (mas_addition)


/**
 排列一组view，所有的view都必须有自己的intrinsicSize, super的大小需要确定，（也就是说super的大小不能依赖本数组里的view）

 @param axisType 方向
 @param fixedSpace view之间的space,注：id类型支持NSNumber类型即ItemSpace相等，和NSArray<NSNumber *>类型，即itemSpace不相等。
 @param leadSpace 第一个view与super之间的距离
 */
- (void)mas_alignAlongAxis:(MASAxisType)axisType
                fixedSpace:(id)fixedSpace
                 leadSpace:(CGFloat)leadSpace;


/**
 排列一组view，所有的view都必须有自己的intrinsicSize，可以用于cell中自适应contentView的高度，super的axisType指定的维度由本数组里的view确定

 @param axisType 方向
 @param fixedSpace view之间的space,注：id类型支持NSNumber类型即ItemSpace相等，和NSArray<NSNumber *>类型，即itemSpace不相等。
 @param leadSpace 第一个view与super之间的距离
 @param tailSpace 最后一个view与super之间的距离，不大于0时不考虑
 */
- (void)mas_alignAlongAxis:(MASAxisType)axisType
                fixedSpace:(id)fixedSpace
                 leadSpace:(CGFloat)leadSpace
                 tailSpace:(CGFloat)tailSpace;


/**
 排列一组view，所有的view都必须有自己的intrinsicSize，可以用于cell中自适应contentView的高度，super的axisType指定的维度由本数组里的view确定

 @param axisType 方向
 @param fixedSpace view之间的space,注：id类型支持NSNumber类型即ItemSpace相等，和NSArray<NSNumber *>类型，即itemSpace不相等。
 @param leadingViewAttribute leadingViewAttribute
 @param leadSpace 第一个view与leadingViewAttribute之间的距离
 @param trailingViewAttribute trailingViewAttribute
 @param tailSpace 最后一个view与trailingViewAttribute之间的距离，不大于0时不考虑
 */
- (void)mas_alignAlongAxis:(MASAxisType)axisType
                fixedSpace:(id)fixedSpace
                 leadingTo:(MASViewAttribute *)leadingViewAttribute
                 leadSpace:(CGFloat)leadSpace
                trailingTo:(MASViewAttribute *)trailingViewAttribute
                 tailSpace:(CGFloat)tailSpace;

#pragma mark - Space Around & Space Between


/**
 排列一组view，super的大小需要确定，或者被其他的subviews共同可以确定（也就是说super的大小不能依赖本数组里的view）

 @param axisType 方向
 @param spaceType 类型
 */
- (void)mas_alignAlongAxis:(MASAxisType)axisType
                 spaceType:(MASAlignChildrenSpaceType)spaceType;

- (void)mas_alignAlongAxis:(MASAxisType)axisType
                 spaceType:(MASAlignChildrenSpaceType)spaceType leadSpace:(CGFloat)leadSpace trailSpace:(CGFloat)trailSpace;



#pragma mark - Center Children


/**
 居中一组view，super的大小需要确定，或者被其他的subviews共同可以确定（也就是说super的大小不能依赖本数组里的view）

 @param axisType 方向
 @param fixedSpace view之间的距离
 @param leadingViewAttribute leadingViewAttribute
 @param leadSpace 整体偏离leadSpace
 @param trailingViewAttribute trailingViewAttribute
 @param trailSpacing 整体偏离trailSpace
 */
- (void)mas_centerAlongAxis:(MASAxisType)axisType
                         fixedSpace:(CGFloat)fixedSpace
                          leadingTo:(MASViewAttribute *)leadingViewAttribute
                          leadSpace:(CGFloat)leadSpace
                         trailingTo:(MASViewAttribute *)trailingViewAttribute
                          tailSpace:(CGFloat)trailSpacing;
/**
 将array里面的所有view居中在superview里，view之间的space为fixedSpace,，super的大小需要确定，或者被其他的subviews共同可以确定（也就是说super的大小不能依赖本数组里的view）
 @param fixedSpace fixedSpace 子view之间的距离
 */
- (void)mas_centerAlongAxis:(MASAxisType)axisType
                         fixedSpace:(CGFloat)fixedSpace;


- (void)mas_centerAlongAxis:(MASAxisType)axisType
                         fixedSpace:(CGFloat)fixedSpace
                     leadSpace:(CGFloat)leadSpace
                    trailSpace:(CGFloat)trailSpace;

#pragma mark - UICollection Like Interface

/**
 类似collectionview的布局，固定列数，横向排列，可以设置行之间的距离，也可以设置列之间的距离，还有整体与superview的spaceing
 
 @param lineNumber       行数
 @param leadSpace   最左边的view与superview的距离
 @param spacing          水平方向view之间的距离
 @param trailSpace 水平方向最右边的view与superview的距离
 @param topSpace       垂直方向最上面的view与superview的距离
 @param bottomSpace    垂直方向最下面的view与superview的距离
 @param verticalSpace  垂直方向view之间的距离
 */
- (void)mas_alignHorizontallyWithLineNumber:(NSInteger)lineNumber
                             leadSpace:(CGFloat)leadSpace
                                      space:(CGFloat)spacing
                            trailSpace:(CGFloat)trailSpace
                                 topSpace:(CGFloat)topSpace
                              bottomSpace:(CGFloat)bottomSpace
                            verticalSpace:(CGFloat)verticalSpace;




/**
 类似collectionview的布局，固定列数，横向排列，可以设置行之间的距离，也可以设置列之间的距离，还有整体与superview的spaceing
 
 @param lineNumber       行数
 @param leadSpace   最左边的view与superview的距离
 @param spacing          水平方向view之间的距离
 @param trailSpace 水平方向最右边的view与superview的距离
 @param topSpace       垂直方向最上面的view与superview的距离
 @param bottomSpace    垂直方向最下面的view与superview的距离
 @param verticalSpace  垂直方向view之间的距离
 @param separatorColor   view之间分割线的颜色
 @param separatorWidth   view之间分割线的宽度
 */
- (void)mas_alignHorizontallyWithLineNumber:(NSInteger)lineNumber
                             leadSpace:(CGFloat)leadSpace
                                      space:(CGFloat)spacing
                            trailSpace:(CGFloat)trailSpace
                                 topSpace:(CGFloat)topSpace
                              bottomSpace:(CGFloat)bottomSpace
                            verticalSpace:(CGFloat)verticalSpace
                             separatorColor:(UIColor*)separatorColor
                             separatorWidth:(CGFloat)separatorWidth;



/**
 最多参数的版本
 */
- (void)mas_alignHorizontallyWithLineNumber:(NSInteger)lineNumber
                                  leadSpace:(CGFloat)leadSpace
                                      space:(CGFloat)spacing
                                 trailSpace:(CGFloat)trailSpace
                                      topTo:(MASViewAttribute*)topViewAttribute
                                   topSpace:(CGFloat)topSpace
                                   bottomTo:(MASViewAttribute*)bottomViewAttribute
                                bottomSpace:(CGFloat)bottomSpace
                              verticalSpace:(CGFloat)verticalSpace
                             separatorColor:(UIColor*)separatorColor
                             separatorWidth:(CGFloat)separatorWidth;
@end
