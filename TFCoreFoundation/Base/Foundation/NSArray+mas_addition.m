//
//  NSArray+mas_addition.m
//  JALabor
//
//  Created by leoking870 on 16/9/30.
//  Copyright © 2016年 leoking870. All rights reserved.
//

#import "NSArray+mas_addition.h"

@implementation NSArray (mas_addition)

- (void)mas_alignAlongAxis:(MASAxisType)axisType fixedSpace:(id)fixedSpace leadSpace:(CGFloat)leadSpace {
    MAS_VIEW *tempSuperView = [self cdy_commonSuperviewOfViews];
    [self mas_alignAlongAxis:axisType fixedSpace:fixedSpace leadingTo:axisType == MASAxisTypeHorizontal ? tempSuperView.mas_leading:tempSuperView.mas_top leadSpace:leadSpace trailingTo:axisType == MASAxisTypeHorizontal ? tempSuperView.mas_trailing:tempSuperView.mas_bottom tailSpace:-1];
}

- (void)mas_alignAlongAxis:(MASAxisType)axisType fixedSpace:(id)fixedSpace leadSpace:(CGFloat)leadSpace tailSpace:(CGFloat)tailSpace {
    MAS_VIEW *tempSuperView = [self cdy_commonSuperviewOfViews];
    [self mas_alignAlongAxis:axisType fixedSpace:fixedSpace leadingTo:axisType == MASAxisTypeHorizontal ? tempSuperView.mas_leading:tempSuperView.mas_top leadSpace:leadSpace trailingTo:axisType == MASAxisTypeHorizontal ? tempSuperView.mas_trailing:tempSuperView.mas_bottom tailSpace:tailSpace];
}

- (void)mas_alignAlongAxis:(MASAxisType)axisType fixedSpace:(id)fixedSpace leadingTo:(MASViewAttribute *)leadingViewAttribute leadSpace:(CGFloat)leadSpace trailingTo:(MASViewAttribute *)trailingViewAttribute tailSpace:(CGFloat)tailSpace {
    MAS_VIEW *prev;
    for (int i = 0; i < self.count; i++) {
        MAS_VIEW *v = self[i];
        [v mas_makeConstraints:^(MASConstraintMaker *make) {
            if (prev) {
                CGFloat fixed = 0.0f;
                if ([fixedSpace isKindOfClass:[NSArray class]]) {
                    fixed = [fixedSpace[i-1] floatValue];
                }
                else if([fixedSpace isKindOfClass:[NSNumber class]]){
                    fixed = [fixedSpace floatValue];
                }
                
                if (axisType == MASAxisTypeHorizontal) {
                    make.leading.equalTo(prev.mas_trailing).offset(fixed);
                }
                else {
                    make.top.equalTo(prev.mas_bottom).offset(fixed);
                }
                if (i == self.count - 1 && tailSpace >= 0 && trailingViewAttribute) {//last one
                    if (axisType == MASAxisTypeHorizontal) {
                        make.trailing.equalTo(trailingViewAttribute).offset(-tailSpace);
                    }
                    else {
                        make.bottom.equalTo(trailingViewAttribute).offset(-tailSpace);
                    }
                    
                }
            }
            else {
                if (axisType == MASAxisTypeHorizontal) {
                    make.leading.equalTo(leadingViewAttribute).offset(leadSpace);
                }
                else {
                    make.top.equalTo(leadingViewAttribute).offset(leadSpace);
                }
            }
            
        }];
        [self _setViewHuggingAndCompressionResistancePrioity:v];
        prev = v;
    }
}
- (void)mas_alignAlongAxis:(MASAxisType)axisType spaceType:(MASAlignChildrenSpaceType)spaceType{
    
    [self mas_alignAlongAxis:axisType spaceType:spaceType leadSpace:0 trailSpace:0];
    
}


- (void)mas_alignAlongAxis:(MASAxisType)axisType spaceType:(MASAlignChildrenSpaceType)spaceType leadSpace:(CGFloat)leadSpace trailSpace:(CGFloat)trailSpace{
    
    MAS_VIEW *tempSuperView = [self cdy_commonSuperviewOfViews];
    if (!tempSuperView) {
        return;
    }
    MAS_VIEW *prev;
    MAS_VIEW* prevSpaceView;
    
    if (spaceType == MASAlignChildrenSpaceAround) {
        
        NSMutableArray* spaceViews = [NSMutableArray arrayWithCapacity:self.count+1];
        for (int i = 0; i < (self.count+1); ++i) {
            UIView* spaceView = [[UIView alloc]init];
            [tempSuperView addSubview:spaceView];
            [spaceViews addObject:spaceView];
        }
        
        for (int i = 0; i < self.count; i++) {
            MAS_VIEW *v = self[i];
            MAS_VIEW *space_V = spaceViews[i];
            if (prev) {
                if (MASAxisTypeHorizontal == axisType) {
                    [space_V mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.leading.equalTo(prev.mas_trailing);
                        if (i == 1) {
                            make.width.equalTo(prevSpaceView.mas_width).multipliedBy(2.0f);
                        }
                        else {
                            make.width.equalTo(prevSpaceView.mas_width);
                        }
                    }];
                    [v mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.leading.equalTo(space_V.mas_trailing);
                    }];
                }
                else {
                    [space_V mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(prev.mas_bottom);
                        if (i == 1) {
                            make.height.mas_equalTo(prevSpaceView.mas_height).multipliedBy(2.0f);
                        }
                        else {
                            make.height.equalTo(prevSpaceView.mas_height);
                        }
                        
                    }];
                    [v mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(space_V.mas_bottom);
                    }];
                }
                
            }
            else {
                if (axisType == MASAxisTypeHorizontal) {
                    [space_V mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.leading.equalTo(tempSuperView.mas_leading).offset(leadSpace);
                    }];
                    [v mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.leading.equalTo(space_V.mas_trailing);
                    }];
                }
                else {
                    [space_V mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(tempSuperView.mas_top).offset(leadSpace);
                    }];
                    [v mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(space_V.mas_bottom);
                    }];
                }
            }
            
            [self _setViewHuggingAndCompressionResistancePrioity:v];
            
            prev = v;
            prevSpaceView = space_V;
        }
        
        MAS_VIEW * lastSpaceView = spaceViews.lastObject;
        MAS_VIEW * lastV = self.lastObject;
        if (axisType == MASAxisTypeHorizontal) {
            [lastSpaceView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(lastV.mas_trailing);
                make.width.equalTo(prevSpaceView.mas_width).multipliedBy(.5f);
                make.trailing.equalTo(tempSuperView.mas_trailing).offset(-trailSpace);
            }];
        }
        else {
            [lastSpaceView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lastV.mas_bottom);
                make.height.equalTo(prevSpaceView.mas_height).multipliedBy(.5f);
                make.bottom.equalTo(tempSuperView.mas_bottom).offset(-trailSpace);
            }];
        }
    }
    else {
        NSMutableArray* spaceViews = [NSMutableArray arrayWithCapacity:self.count+1];
        for (int i = 0; i < (self.count-1); ++i) {
            UIView* spaceView = [[UIView alloc]init];
            [tempSuperView addSubview:spaceView];
            [spaceViews addObject:spaceView];
        }
        
        
        for (int i = 0; i < self.count; i++) {
            MAS_VIEW *v = self[i];
            MAS_VIEW *space_V = nil;
            if (i < spaceViews.count) {
                space_V = spaceViews[i];
            }
            
            if (prev) {
                if (axisType == MASAxisTypeHorizontal) {
                    [v mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.leading.equalTo(prevSpaceView.mas_trailing);
                    }];
                    if (space_V) {
                        
                        [space_V mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.leading.equalTo(v.mas_trailing);
                            make.width.equalTo(prevSpaceView.mas_width);
                        }];
                    }
                    else {
                        [v mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.trailing.equalTo(tempSuperView.mas_trailing).offset(-trailSpace);
                        }];
                    }
                }
                else {
                    [v mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(prevSpaceView.mas_bottom);
                    }];
                    if (space_V) {
                        
                        [space_V mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.top.equalTo(v.mas_bottom);
                            make.height.equalTo(prevSpaceView.mas_height);
                        }];
                    }
                    else {
                        [v mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.bottom.equalTo(tempSuperView.mas_bottom).offset(-trailSpace);
                        }];
                    }
                }
            }
            else {
                if (axisType == MASAxisTypeHorizontal) {
                    [v mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.leading.equalTo(tempSuperView.mas_leading).offset(leadSpace);
                    }];
                    [space_V mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.leading.equalTo(v.mas_trailing);
                    }];
                }
                else {
                    [v mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(tempSuperView.mas_top).offset(leadSpace);
                    }];
                    [space_V mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.equalTo(v.mas_bottom);
                    }];
                }
            }
            
            [self _setViewHuggingAndCompressionResistancePrioity:v];
            
            prev = v;
            prevSpaceView = space_V;
        }
    }
}


- (void)mas_alignHorizontallyCenterChildrenTogetherWithFixedSpacing:(CGFloat)fixedSpace leadingTo:(MASViewAttribute *)leadingViewAttribute leadSpace:(CGFloat)leadSpace trailingTo:(MASViewAttribute *)trailingViewAttribute tailSpace:(CGFloat)trailSpacing {
    MAS_VIEW *tempSuperView = [self cdy_commonSuperviewOfViews];
    
    NSMutableArray* spaceViews = [NSMutableArray arrayWithCapacity:self.count+1];
    for (int i = 0; i < (self.count+1); ++i) {
        UIView* spaceView = [[UIView alloc]init];
        [tempSuperView addSubview:spaceView];
        [spaceViews addObject:spaceView];
    }
    
    
    MAS_VIEW *prev;
    MAS_VIEW* prevSpaceView;
    for (int i = 0; i < self.count; i++) {
        MAS_VIEW *v = self[i];
        MAS_VIEW *space_V = spaceViews[i];
        if (prev) {
            [space_V mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(prev.mas_trailing);
                make.width.mas_equalTo(fixedSpace);
            }];
            [v mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(space_V.mas_trailing);
            }];
        }
        else {
            [space_V mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(leadingViewAttribute).offset(leadSpace);
            }];
            [v mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(space_V.mas_trailing);
            }];
        }
        [self _setViewHuggingAndCompressionResistancePrioity:v];
        prev = v;
        prevSpaceView = space_V;
    }
    
    MAS_VIEW * lastSpaceView = spaceViews.lastObject;
    MAS_VIEW * lastV = self.lastObject;
    prevSpaceView = spaceViews.firstObject;
    [lastSpaceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(lastV.mas_trailing);
        make.width.equalTo(prevSpaceView.mas_width);
        make.trailing.equalTo(trailingViewAttribute).offset(-trailSpacing);
    }];
}

- (void)mas_centerAlongAxis:(MASAxisType)axisType fixedSpace:(CGFloat)fixedSpace leadingTo:(MASViewAttribute *)leadingViewAttribute leadSpace:(CGFloat)leadSpace trailingTo:(MASViewAttribute *)trailingViewAttribute tailSpace:(CGFloat)trailSpacing {
    if (axisType == MASAxisTypeHorizontal) {
        [self mas_alignHorizontallyCenterChildrenTogetherWithFixedSpacing:fixedSpace leadingTo:leadingViewAttribute leadSpace:leadSpace trailingTo:trailingViewAttribute tailSpace:trailSpacing];
    }
    else {
        [self mas_alignVerticallyCenterChildrenTogetherWithFixedSpacing:fixedSpace topTo:leadingViewAttribute topSpace:leadSpace bottomTo:trailingViewAttribute bottomSpace:trailSpacing];
    }
}

- (void)mas_centerAlongAxis:(MASAxisType)axisType fixedSpace:(CGFloat)fixedSpace {
    MAS_VIEW *tempSuperView = [self cdy_commonSuperviewOfViews];
    if (axisType == MASAxisTypeHorizontal) {
        [self mas_centerAlongAxis:axisType fixedSpace:fixedSpace leadingTo:tempSuperView.mas_leading leadSpace:.0f trailingTo:tempSuperView.mas_trailing tailSpace:.0f];
    }
    else {
        [self mas_centerAlongAxis:axisType fixedSpace:fixedSpace leadingTo:tempSuperView.mas_top leadSpace:.0f trailingTo:tempSuperView.mas_bottom tailSpace:.0f];
    }
}

- (void)mas_centerAlongAxis:(MASAxisType)axisType fixedSpace:(CGFloat)fixedSpace leadSpace:(CGFloat)leadSpace trailSpace:(CGFloat)trailSpace {
    MAS_VIEW *tempSuperView = [self cdy_commonSuperviewOfViews];
    if (axisType == MASAxisTypeHorizontal) {
        [self mas_centerAlongAxis:axisType fixedSpace:fixedSpace leadingTo:tempSuperView.mas_leading leadSpace:leadSpace trailingTo:tempSuperView.mas_trailing tailSpace:trailSpace];
    }
    else {
        [self mas_centerAlongAxis:axisType fixedSpace:fixedSpace leadingTo:tempSuperView.mas_top leadSpace:leadSpace trailingTo:tempSuperView.mas_bottom tailSpace:trailSpace];
    }
}



- (void)mas_alignVerticallyCenterChildrenTogetherWithFixedSpacing:(CGFloat)fixedSpace topTo:(MASViewAttribute *)topViewAttribute topSpace:(CGFloat)topSpace bottomTo:(MASViewAttribute *)bottomViewAttribute bottomSpace:(CGFloat)bottomSpace {
    MAS_VIEW *tempSuperView = [self cdy_commonSuperviewOfViews];
    
    NSMutableArray* spaceViews = [NSMutableArray arrayWithCapacity:self.count+1];
    for (int i = 0; i < (self.count+1); ++i) {
        UIView* spaceView = [[UIView alloc]init];
        [tempSuperView addSubview:spaceView];
        [spaceViews addObject:spaceView];
    }
    
    
    MAS_VIEW *prev;
    MAS_VIEW* prevSpaceView;
    for (int i = 0; i < self.count; i++) {
        MAS_VIEW *v = self[i];
        MAS_VIEW *space_V = spaceViews[i];
        if (prev) {
            [space_V mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(prev.mas_bottom);
                make.height.mas_equalTo(fixedSpace);
            }];
            [v mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(space_V.mas_bottom);
            }];
        }
        else {
            [space_V mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(topViewAttribute).offset(topSpace);
            }];
            [v mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(space_V.mas_bottom);
            }];
        }
        [self _setViewHuggingAndCompressionResistancePrioity:v];
        prev = v;
        prevSpaceView = space_V;
    }
    
    MAS_VIEW * lastSpaceView = spaceViews.lastObject;
    MAS_VIEW * lastV = self.lastObject;
    prevSpaceView = spaceViews.firstObject;
    [lastSpaceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lastV.mas_bottom);
        make.height.equalTo(prevSpaceView.mas_height);
        make.bottom.equalTo(bottomViewAttribute).offset(-bottomSpace);
    }];
}



- (void)_setViewHuggingAndCompressionResistancePrioity:(MAS_VIEW*)view {
    [view setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [view setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [view setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [view setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
}


- (MAS_VIEW *)cdy_commonSuperviewOfViews
{
    if (self.count == 1) {
        return [self.firstObject superview];
    }
    if (self.count == 0) {
        return nil;
    }
    MAS_VIEW *commonSuperview = nil;
    MAS_VIEW *previousView = nil;
    for (id object in self) {
        if ([object isKindOfClass:[MAS_VIEW class]]) {
            MAS_VIEW *view = (MAS_VIEW *)object;
            if (previousView) {
                commonSuperview = [view mas_closestCommonSuperview:commonSuperview];
            } else {
                commonSuperview = view;
            }
            previousView = view;
        }
    }
    NSAssert(commonSuperview, @"Can't constrain views that do not share a common superview. Make sure that all the views in this array have been added into the same view hierarchy.");
    return commonSuperview;
}


- (void)mas_alignHorizontallyWithLineNumber:(NSInteger)lineNumber leadSpace:(CGFloat)leadSpace space:(CGFloat)spacing trailSpace:(CGFloat)trailSpace topSpace:(CGFloat)topSpace bottomSpace:(CGFloat)bottomSpace verticalSpace:(CGFloat)verticalSpace{
    [self mas_alignHorizontallyWithLineNumber:lineNumber leadSpace:leadSpace space:spacing trailSpace:trailSpace topSpace:topSpace bottomSpace:bottomSpace verticalSpace:verticalSpace separatorColor:nil separatorWidth:0];
}


- (void)mas_alignHorizontallyWithLineNumber:(NSInteger)lineNumber leadSpace:(CGFloat)leadSpace space:(CGFloat)spacing trailSpace:(CGFloat)trailSpace topSpace:(CGFloat)topSpace bottomSpace:(CGFloat)bottomSpace verticalSpace:(CGFloat)verticalSpace separatorColor:(UIColor*)separatorColor separatorWidth:(CGFloat)separatorWidth{
    MAS_VIEW *tempSuperView = [self cdy_commonSuperviewOfViews];
    [self mas_alignHorizontallyWithLineNumber:lineNumber leadSpace:leadSpace space:spacing trailSpace:trailSpace topTo:tempSuperView.mas_top topSpace:topSpace bottomTo:tempSuperView.mas_bottom bottomSpace:bottomSpace verticalSpace:verticalSpace separatorColor:separatorColor separatorWidth:separatorWidth];
}

- (void)mas_alignHorizontallyWithLineNumber:(NSInteger)lineNumber leadSpace:(CGFloat)leadSpace space:(CGFloat)spacing trailSpace:(CGFloat)trailSpace topTo:(MASViewAttribute *)topViewAttribute topSpace:(CGFloat)topSpace bottomTo:(MASViewAttribute *)bottomViewAttribute bottomSpace:(CGFloat)bottomSpace verticalSpace:(CGFloat)verticalSpace separatorColor:(UIColor *)separatorColor separatorWidth:(CGFloat)separatorWidth {
    if (self.count == 0) {
        return;
    }
    MAS_VIEW *tempSuperView = [self cdy_commonSuperviewOfViews];
    if (self.count <= lineNumber) {
        NSMutableArray* totalViews = [NSMutableArray arrayWithArray:self];
        for (NSInteger i = self.count; i < lineNumber; ++i) {
            UIView* view = [UIView new];
            [tempSuperView addSubview:view];
            [totalViews addObject:view];
        }
        [totalViews mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(topViewAttribute).with.offset(topSpace);
        }];
        [totalViews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:spacing leadSpacing:leadSpace tailSpacing:trailSpace];
        
        if (bottomViewAttribute && bottomSpace >= 0) {
            [totalViews mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(bottomViewAttribute).with.offset(-bottomSpace);
            }];
        }
    }
    else {
        NSInteger index = 0;
        NSArray* subviews = [self subarrayWithRange:NSMakeRange(index, lineNumber)];
        [subviews mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(topViewAttribute).with.offset(topSpace);
        }];
        UIView* topView = subviews.firstObject;
        [subviews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:spacing leadSpacing:leadSpace tailSpacing:trailSpace];
        index = lineNumber;
        for (NSInteger i = index; i < self.count; i += lineNumber) {
            if (i + lineNumber < self.count) {
                subviews = [self subarrayWithRange:NSMakeRange(i, lineNumber)];
                [subviews mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(topView.mas_bottom).with.offset(verticalSpace);
                }];
                [subviews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:spacing leadSpacing:leadSpace tailSpacing:trailSpace];
                topView = subviews.firstObject;
            }
            else {
                subviews = [self subarrayFromIndex:i];
                [subviews mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(topView.mas_bottom).with.offset(verticalSpace);
                    if (bottomViewAttribute && bottomSpace >= 0) {
                        make.bottom.equalTo(bottomViewAttribute).with.offset(-bottomSpace);
                    }
                    make.size.equalTo(topView);
                }];
                
                [subviews mas_alignAlongAxis:MASAxisTypeHorizontal fixedSpace:@(spacing) leadSpace:leadSpace];
            }
        }
    }
    if (separatorColor) {
        for (int i = 0; i < self.count; ++i) {
            UIView* targetView = self[i];
            UIView* bottomLine = [[UIView alloc]init];
            bottomLine.backgroundColor = separatorColor;
            [targetView.superview addSubview:bottomLine];
            [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
                if (i / lineNumber == (self.count/lineNumber) && bottomSpace > 0) {
                    make.top.equalTo(targetView.mas_bottom).with.offset(bottomSpace);
                }
                else {
                    make.top.equalTo(targetView.mas_bottom).with.offset(verticalSpace/2.0f);
                }
                if (i % lineNumber == 0) {
                    make.leading.equalTo(targetView.mas_leading).offset(-leadSpace);
                }
                else {
                    make.leading.equalTo(targetView.mas_leading).offset(-spacing/2.0f);
                }
                if (i % lineNumber == (lineNumber - 1)) {
                    make.trailing.equalTo(targetView.mas_trailing).with.offset(trailSpace);
                }
                else {
                    make.trailing.equalTo(targetView.mas_trailing).with.offset(spacing/2.0f);
                }
                make.height.mas_equalTo(separatorWidth);
            }];
            
            UIView* rightLine = [[UIView alloc]init];
            rightLine.backgroundColor = separatorColor;
            [targetView.superview addSubview:rightLine];
            [rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
                if (i / lineNumber == 0) {
                    make.top.equalTo(targetView.mas_top).offset(-topSpace);
                }
                else {
                    make.top.equalTo(targetView.mas_top).offset(-verticalSpace/2.0f);
                }
                
                if (i % lineNumber == (lineNumber - 1)) {
                    make.leading.equalTo(targetView.mas_trailing).with.offset(trailSpace);
                }
                else {
                    make.leading.equalTo(targetView.mas_trailing).with.offset(spacing/2.0f);
                }
                
                if (i / lineNumber == self.count / lineNumber && bottomSpace > 0) {
                    make.bottom.equalTo(targetView.mas_bottom).with.offset(bottomSpace);
                }
                else {
                    make.bottom.equalTo(targetView.mas_bottom).with.offset(verticalSpace/2.0f);
                }
                make.width.mas_equalTo(separatorWidth);
            }];
            
            
        }
    }
}


- (void)mas_alignSubviews:(NSArray*)subviews lineNumber:(NSInteger)lineNumber horizontallyEqualWidthWithLeading:(CGFloat)leading trailing:(CGFloat)trailing spacing:(CGFloat)spacing {
    UIView* superview = [subviews.firstObject superview];
    CGFloat value = leading + trailing + spacing * (lineNumber - 1);
    [subviews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(superview.mas_width).multipliedBy(1.0f/lineNumber).offset(value/lineNumber);
    }];
}


- (NSArray *)subarrayFromIndex:(NSUInteger)index {
    return [self subarrayWithRange:NSMakeRange(index, self.count - index)];
}

- (void)cdy_distributeViewsAlongAxis:(MASAxisType)axisType withFixedSpacing:(CGFloat)fixedSpacing leadSpacing:(CGFloat)leadSpacing tailSpacing:(CGFloat)tailSpacing {
    if (self.count < 2) {
        NSAssert(self.count>1,@"views to distribute need to bigger than one");
        return;
    }
    
    MAS_VIEW *tempSuperView = [self cdy_commonSuperviewOfViews];
    if (axisType == MASAxisTypeHorizontal) {
        MAS_VIEW *prev;
        for (int i = 0; i < self.count; i++) {
            MAS_VIEW *v = self[i];
            [v mas_makeConstraints:^(MASConstraintMaker *make) {
                if (prev) {
                    make.width.equalTo(prev);
                    make.left.equalTo(prev.mas_right).offset(fixedSpacing);
                    if (i == self.count - 1) {//last one
                        make.right.equalTo(tempSuperView).offset(-tailSpacing);
                    }
                }
                else {//first one
                    make.left.equalTo(tempSuperView).offset(leadSpacing);
                }
                
            }];
            prev = v;
        }
    }
    else {
        MAS_VIEW *prev;
        for (int i = 0; i < self.count; i++) {
            MAS_VIEW *v = self[i];
            [v mas_makeConstraints:^(MASConstraintMaker *make) {
                if (prev) {
                    make.height.equalTo(prev);
                    make.top.equalTo(prev.mas_bottom).offset(fixedSpacing);
                    if (i == self.count - 1) {//last one
                        make.bottom.equalTo(tempSuperView).offset(-tailSpacing);
                    }
                }
                else {//first one
                    make.top.equalTo(tempSuperView).offset(leadSpacing);
                }
                
            }];
            prev = v;
        }
    }
}

@end
