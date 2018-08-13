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
        [UIView animateWithDuration:.3f animations:^{
            [self segmentViewUpdateToIndex:_currentItemIndex byPercent:1.0f];
        }];
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

- (CGRect)frameForLineUnderCell:(TFSegmentViewTitleCell*)cell {
    UIEdgeInsets lineInsets = _configModel.lineInsets;
    if (CGRectGetWidth(cell.frame) > _configModel.itemMinWidth) {
        CGFloat itemInsets = _configModel.itemSpace/2.0;
        lineInsets.left += itemInsets;
        lineInsets.right += itemInsets;
    }
    return UIEdgeInsetsInsetRect(cell.frame, lineInsets);
}

- (CGRect)frameForLineUnderCellFrame:(CGRect)cellFrame {
    UIEdgeInsets lineInsets = _configModel.lineInsets;
    if (CGRectGetWidth(cellFrame) > _configModel.itemMinWidth) {
        CGFloat itemInsets = _configModel.itemSpace/2.0;
        lineInsets.left += itemInsets;
        lineInsets.right += itemInsets;
    }
    return UIEdgeInsetsInsetRect(cellFrame, lineInsets);
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    TFSegmentViewTitleCell *cell = (TFSegmentViewTitleCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.titleLabel.textColor = _configModel.textColor;
}

- (void)segmentViewUpdateToIndex:(NSInteger)index byPercent:(CGFloat)percent {
    if (index < 0 || index >= [self collectionView:self.collectionView numberOfItemsInSection:0]) {

        UICollectionViewLayoutAttributes *currentAttributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentItemIndex inSection:0]];
        CGRect currentCellFrame = [self frameForLineUnderCellFrame:currentAttributes.frame];
        _lineView.frame = currentCellFrame;
        CGPoint lineCenter = _lineView.center;
        
        lineCenter.x = lineCenter.x + percent * ((index < 0) ? -CGRectGetWidth(currentCellFrame) : CGRectGetWidth(currentCellFrame));
        _lineView.center = lineCenter;
//        NSLog(@"------lineView frame:%@, index:%zd, percent:%f", NSStringFromCGRect(_lineView.frame), index, percent);
        return ;
    }
    else {

        UICollectionViewLayoutAttributes *currentAttributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentItemIndex inSection:0]];
        UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];

//        NSLog(@"targetCell:%@, frame:%@",attributes, NSStringFromCGRect(attributes.frame));
        CGFloat distance = attributes.center.x - currentAttributes.center.x;
        CGFloat offset = distance * percent;
        
        CGRect currentCellFrame = [self frameForLineUnderCellFrame:currentAttributes.frame];
        CGRect targetCellFrame = [self frameForLineUnderCellFrame:attributes.frame];
        CGFloat widthOffset = (CGRectGetWidth(targetCellFrame) - CGRectGetWidth(currentCellFrame)) * percent;
        
        
        currentCellFrame = UIEdgeInsetsInsetRect(currentCellFrame, UIEdgeInsetsMake(0, -widthOffset/2.0f, 0, -widthOffset/2.0f));;
        _lineView.frame = currentCellFrame;
        
        CGPoint lineCenter = _lineView.center;
        lineCenter.x = lineCenter.x + offset;
        _lineView.center = lineCenter;
    }
}

- (void)didScrollToIndex:(NSInteger)index {
    [self collectionView:self.collectionView didDeselectItemAtIndexPath:[NSIndexPath indexPathForItem:_currentItemIndex inSection:0]];
    _currentItemIndex = index;
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:_currentItemIndex inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:_currentItemIndex inSection:0]];
    
    [UIView animateWithDuration:.3f animations:^{
        [self segmentViewUpdateToIndex:_currentItemIndex byPercent:1.0f];
    }];
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

- (void)reloadData {
    [self.collectionView reloadData];
    self.lineView.hidden = self.itemArr.count == 0;
}

@end
