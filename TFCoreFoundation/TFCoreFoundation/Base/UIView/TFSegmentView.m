//
//  SegmentView.m
//  DigitalConference
//
//  Created by Summer on 16/6/13.
//  Copyright © 2016年 TimeFace. All rights reserved.
//

#import "TFSegmentView.h"
#import "TFSegmentViewTitleCell.h"

@interface TFSegmentView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) NSArray *itemWidthArr;///<每个item的宽度数组

@property (nonatomic, readwrite) TFSegmentConfigModel *configModel;

@end

@implementation TFSegmentView

#pragma mark 初始化方法
- (instancetype)initWithFrame:(CGRect)frame configModel:(TFSegmentConfigModel *)configModel itemArray:(NSArray<NSString *> *)itemArray {
    self = [super initWithFrame:frame];
    if (self) {
        if (configModel) {
            _configModel = configModel;
        }
        else {
            _configModel = [[TFSegmentConfigModel alloc] init];
            _configModel.lineInsets = UIEdgeInsetsMake(CGRectGetHeight(self.frame)-4.0, 5.0, 0.0, 5.0);
        }
        [self initialize];
        self.itemArr = itemArray;
    }
    return self;
}

- (void)initialize {
    [self addSubview:self.collectionView];
    [self.collectionView addSubview:self.lineView];
    self.currentItemIndex = 0;
    self.updateLinePosBySelf = YES;
    self.backgroundColor = [UIColor whiteColor];
    self.lineView.backgroundColor = _configModel.lineColor;
    self.lineView.layer.cornerRadius = _configModel.lineCornerRadius;

}

+ (instancetype)itemWithFrame:(CGRect)frame configModel:(TFSegmentConfigModel *)configModel itemArray:(NSArray<NSString *> *)itemArray {
    TFSegmentView *segementView = [[TFSegmentView alloc] initWithFrame:frame configModel:configModel itemArray:itemArray];
    return segementView;
}

#pragma mark 宽度数组
- (void)calculateWidth {
    if (_itemArr.count!=0) {
        CGFloat currentWidth = 0.0;
        NSMutableArray *tempArr = [NSMutableArray array];
        for (NSString *item in _itemArr) {
            CGFloat width = MAX([item sizeWithAttributes:@{NSFontAttributeName:_configModel.font}].width + _configModel.itemSpace, _configModel.itemMinWidth);
            [tempArr addObject:@(width)];
            currentWidth += width;
        }
        _itemWidthArr = [NSArray arrayWithArray:tempArr];
        //注：为了防止item过少，用边距让collectioncell居中
        CGFloat sectionInset = 0.0;
        CGFloat viewWidth = CGRectGetWidth(self.frame);
        if (currentWidth<CGRectGetWidth(self.frame)) {
            sectionInset = (viewWidth - currentWidth)/2.0;
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
    cell.titleLabel.font = _configModel.font;
    if (indexPath.row==_currentItemIndex) {
        cell.titleLabel.textColor = _configModel.selectedTextColor;
        [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        [self moveLineWithCenterX:CGRectGetMidX(cell.frame) currentCell:cell];
    }
    else {
        cell.titleLabel.textColor = _configModel.textColor;
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([_itemWidthArr[indexPath.row] floatValue], CGRectGetHeight(self.collectionView.frame));
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TFSegmentViewTitleCell *cell = (TFSegmentViewTitleCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.titleLabel.textColor = _configModel.selectedTextColor;
    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    if (_currentItemIndex!=indexPath.row) {
        _currentItemIndex = indexPath.row;
        //调用变化
        if (_changeBlock) {
            _changeBlock (_currentItemIndex,_itemArr[_currentItemIndex]);
        }
        if (self.updateLinePosBySelf) {
            [self moveLineWithCenterX:CGRectGetMidX(cell.frame) currentCell:cell];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row==self.currentItemIndex) {
        [self.collectionView sendSubviewToBack:self.lineView];
    }
}

- (void)moveLineWithCenterX:(CGFloat)centerX currentCell:(TFSegmentViewTitleCell *)cell {
    [UIView animateWithDuration:0.3f delay:0.0f usingSpringWithDamping:0.3 initialSpringVelocity:0.7 options:UIViewAnimationOptionTransitionNone animations:^{
        UIEdgeInsets lineInsets = _configModel.lineInsets;
        if (CGRectGetWidth(cell.frame) > _configModel.itemMinWidth) {
            CGFloat itemInsets = _configModel.itemSpace/2.0;
            lineInsets.left += itemInsets;
            lineInsets.right += itemInsets;
        }
        _lineView.frame = UIEdgeInsetsInsetRect(cell.frame, lineInsets);
        CGPoint lineCenter = _lineView.center;
        lineCenter.x = centerX;
        _lineView.center = lineCenter;
 
    } completion:nil];
}


- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    TFSegmentViewTitleCell *cell = (TFSegmentViewTitleCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.titleLabel.textColor = _configModel.textColor;
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
    targetCenterX = CGRectGetMidX(cell.frame);
    
    CGFloat sectionInset = 0.0;
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    if ([self currentWidth]<viewWidth) {
        sectionInset = (viewWidth - [self currentWidth])/2.0;
    }
    CGFloat firstCellWidth = [self.itemWidthArr[0] floatValue];
    CGFloat leading = sectionInset + firstCellWidth/2.0f + [self currentWidth] * (contentOffset / contentWidth);
    CGPoint lineCenter = _lineView.center;
    lineCenter.x = leading;
    _lineView.center = lineCenter;
    
    if (fabs(targetCenterX - leading) < 10) {
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

-(void)setCurrentItemIndex:(NSInteger)currentItemIndex
{
    if (_currentItemIndex != currentItemIndex) {
        [self collectionView:self.collectionView didDeselectItemAtIndexPath:[NSIndexPath indexPathForItem:_currentItemIndex inSection:0]];
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:currentItemIndex inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:currentItemIndex inSection:0]];
    }
    _currentItemIndex = currentItemIndex;
}



@end
