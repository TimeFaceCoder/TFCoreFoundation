//
//  SegmentView.m
//  DigitalConference
//
//  Created by Summer on 16/6/13.
//  Copyright © 2016年 TimeFace. All rights reserved.
//

#import "TFSegmentView.h"
#import "TFSegmentViewTitleCell.h"
#import "UIView+TFCore.h"
#import "UIColor+TFCore.h"

@interface TFSegmentView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) NSArray *itemWidthArr;///<每个item的宽度数组

@end

@implementation TFSegmentView



#pragma mark 初始化方法
- (instancetype)initWithFrame:(CGRect)frame itemArray:(NSArray<NSString *> *)itemArray {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
        self.itemArr = itemArray;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [self addSubview:self.collectionView];
    [self.collectionView addSubview:self.lineView];
    //默认常量
    self.font = [UIFont systemFontOfSize:16];
    self.textColor = UIColorHex(0x333333);
    self.selectedTextColor = UIColorHex(0x2f83eb);
    self.itemSpace = 10.0;
    self.itemMinWidth = 0.0;
    self.currentItemIndex = 0;
    self.lineInsets = UIEdgeInsetsMake(self.tf_height-4.0, 0.0, 0.0, 0.0);
    self.lineCornerRadius = 0.0;
    self.lineColor = UIColorHex(0x2f83eb);
    self.updateLinePosBySelf = YES;
    self.backgroundColor = [UIColor whiteColor];
}

+ (instancetype)itemWithFrame:(CGRect)frame itemArray:(NSArray<NSString *> *)itemArray {
    TFSegmentView *segementView = [[TFSegmentView alloc] initWithFrame:frame itemArray:itemArray];
    return segementView;
}

-(void)setCurrentItemIndex:(NSInteger)currentItemIndex
{
    if (_currentItemIndex != currentItemIndex) {
        [self collectionView:self.collectionView didDeselectItemAtIndexPath:[NSIndexPath indexPathForItem:_currentItemIndex inSection:0]];
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:currentItemIndex inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:currentItemIndex inSection:0]];
    }
    _currentItemIndex = currentItemIndex;
}



#pragma mark 宽度数组
- (void)calculateWidth {
    if (_itemArr.count!=0) {
        CGFloat currentWidth = 0.0;
        NSMutableArray *tempArr = [NSMutableArray array];
        for (NSString *item in _itemArr) {
            CGFloat width = MAX([item sizeWithAttributes:@{NSFontAttributeName:_font}].width + self.itemSpace, self.itemMinWidth);
            [tempArr addObject:@(width)];
            currentWidth += width;
        }
        _itemWidthArr = [NSArray arrayWithArray:tempArr];
        //注：为了防止item过少，用边距让collectioncell居中
        CGFloat sectionInset = 0.0;
        if (currentWidth<self.tf_width) {
            sectionInset = (self.tf_width - currentWidth)/2.0;
        }
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
        layout.sectionInset = UIEdgeInsetsMake(0, sectionInset, 0, sectionInset);
        
    }
}

- (CGFloat)currentWidth {
    if (_itemArr.count!=0) {
        CGFloat currentWidth = 0.0;
        for (NSNumber *itemWidth in _itemWidthArr) {
            currentWidth += [itemWidth floatValue];
        }
        return currentWidth;
    }
    return .0f;
}

#pragma mark UICollectionViewDelegate,UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _itemArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TFSegmentViewTitleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SegmentViewTitleCellIdentifier forIndexPath:indexPath];
    cell.titleLabel.text = _itemArr[indexPath.row];
    cell.titleLabel.font = self.font;
    if (indexPath.row==_currentItemIndex) {
        cell.titleLabel.textColor = _selectedTextColor;
        [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        [self moveLineWithCenterX:cell.tf_centerX currentCell:cell];
    }
    else {
        cell.titleLabel.textColor = _textColor;
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([_itemWidthArr[indexPath.row] floatValue], self.collectionView.tf_height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TFSegmentViewTitleCell *cell = (TFSegmentViewTitleCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.titleLabel.textColor = _selectedTextColor;
    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    if (_currentItemIndex!=indexPath.row) {
        _currentItemIndex = indexPath.row;
        //调用变化
        if (_changeBlock) {
            _changeBlock (_currentItemIndex,_itemArr[_currentItemIndex]);
        }
        if (self.updateLinePosBySelf) {
            [self moveLineWithCenterX:cell.tf_centerX currentCell:cell];
        }
    }
}

- (void)moveLineWithCenterX:(CGFloat)centerX currentCell:(TFSegmentViewTitleCell *)cell {
    
    [UIView animateWithDuration:0.3f delay:0.0f usingSpringWithDamping:0.3 initialSpringVelocity:0.7 options:UIViewAnimationOptionTransitionNone animations:^{
        UIEdgeInsets lineInsets = self.lineInsets;
        if (cell.tf_width > _itemMinWidth) {
            CGFloat itemInsets = _itemSpace/2.0;
            lineInsets.left += itemInsets;
            lineInsets.right += itemInsets;
        }
        _lineView.frame = UIEdgeInsetsInsetRect(cell.frame, lineInsets);
        _lineView.tf_centerX = centerX;
 
    } completion:nil];
}


- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    TFSegmentViewTitleCell *cell = (TFSegmentViewTitleCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.titleLabel.textColor = _textColor;
}


-(void)segmentViewUpdateCurrentSelectedIndexByContentOffset:(CGFloat)contentOffset inContentWidth:(CGFloat)contentWidth viewWidth:(CGFloat)viewWith;
{
    CGFloat targetCenterX = 0.0f;
    if (_currentItemIndex != (int)(contentOffset / viewWith)) {
        
        [self collectionView:self.collectionView didDeselectItemAtIndexPath:[NSIndexPath indexPathForItem:_currentItemIndex inSection:0]];
        _currentItemIndex = contentOffset / viewWith;
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:_currentItemIndex inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:_currentItemIndex inSection:0]];
  
    }

    
    TFSegmentViewTitleCell *cell = (TFSegmentViewTitleCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentItemIndex inSection:0]];
    targetCenterX = cell.tf_centerX;
    

    CGFloat sectionInset = 0.0;
    if ([self currentWidth]<self.tf_width) {
        sectionInset = (self.tf_width - [self currentWidth])/2.0;
    }
    CGFloat firstCellWidth = [self.itemWidthArr[0] floatValue];
    CGFloat leading = sectionInset + firstCellWidth/2.0f + [self currentWidth] * (contentOffset / contentWidth);
    _lineView.tf_centerX = leading;
    
    if (fabs(targetCenterX - _lineView.tf_centerX) < 10) {
        [self moveLineWithCenterX:targetCenterX currentCell:cell];
    }
}

#pragma mark - lazy load.

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0.0;
        layout.minimumInteritemSpacing = 0.0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.bounces = NO;
        _collectionView.contentInset = UIEdgeInsetsZero;
        [_collectionView registerClass:[TFSegmentViewTitleCell class] forCellWithReuseIdentifier:SegmentViewTitleCellIdentifier];
    }
    return _collectionView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        
    }
    return _lineView;
}

- (void)setItemArr:(NSArray *)itemArr {
    _itemArr = itemArr;
    //计算宽度
    [self calculateWidth];
    [self.collectionView reloadData];
}

- (void)setLineCornerRadius:(CGFloat)lineCornerRadius {
    _lineCornerRadius = lineCornerRadius;
    _lineView.layer.cornerRadius = lineCornerRadius;
    _lineView.layer.masksToBounds = YES;
}

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    _lineView.backgroundColor = lineColor;
}



@end
