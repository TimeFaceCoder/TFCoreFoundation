//
//  SegmentView.m
//  DigitalConference
//
//  Created by Summer on 16/6/13.
//  Copyright © 2016年 TimeFace. All rights reserved.
//

#import "TFSegmentView.h"
#import "TFSegmentViewTitleCell.h"

static CGFloat kMinSegementItemWidth = 75.0;

@interface TFSegmentView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) NSArray *itemWidthArr;///<每个item的宽度数组

@end

@implementation TFSegmentView

#pragma mark collectionView
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

#pragma mark lineView
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
    }
    return _lineView;
}

#pragma mark lineHeight
- (void)setLineHeight:(CGFloat)lineHeight {
    _lineHeight = lineHeight;
    _lineView.tf_height = _lineHeight;
    _lineView.tf_bottom = self.tf_height;
}

#pragma mark itemArray
- (void)setItemArr:(NSArray *)itemArr {
    _itemArr = itemArr;
    [self calculateWidth];
    [self.collectionView reloadData];
}

#pragma mark font
- (void)setFont:(UIFont *)font {
    _font = font;
    [self calculateWidth];
    [self.collectionView reloadData];
}

#pragma mark lineColor
- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    _lineView.backgroundColor = lineColor;
}

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
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.collectionView];
    [self.collectionView addSubview:self.lineView];
    self.lineHeight = 4.0;
    self.lineColor = UIColorHex(0x2f83eb);
    self.lineSpace = 15.0;
    self.currentItemIndex = 0;
    self.textColor = UIColorHex(0x333333);
    self.selectedTextColor = UIColorHex(0x2f83eb);
    self.font = TFSTYLEVAR(font16);
    self.collectionView.frame = CGRectMake(0, 0, self.tf_width, self.tf_height);
}

-(void)setCurrentItemIndex:(NSInteger)currentItemIndex
{
    if (_currentItemIndex != currentItemIndex) {

        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:currentItemIndex inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:currentItemIndex inSection:0]];
        [self collectionView:self.collectionView didDeselectItemAtIndexPath:[NSIndexPath indexPathForItem:_currentItemIndex inSection:0]];

    }
    _currentItemIndex = currentItemIndex;
}

+ (instancetype)itemWithFrame:(CGRect)frame itemArray:(NSArray<NSString *> *)itemArray {
    TFSegmentView *segementView = [[TFSegmentView alloc] initWithFrame:frame itemArray:itemArray];
    return segementView;
}

#pragma mark 宽度数组
- (void)calculateWidth {
    if (_itemArr.count!=0) {
        CGFloat currentWidth = 0.0;
        NSMutableArray *tempArr = [NSMutableArray array];
        for (NSString *item in _itemArr) {
            CGFloat width = MAX([item sizeWithAttributes:@{NSFontAttributeName:_font}].width+20.0, kMinSegementItemWidth);
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

#pragma mark UICollectionViewDelegate,UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _itemArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TFSegmentViewTitleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SegmentViewTitleCellIdentifier forIndexPath:indexPath];
    cell.titleLabel.text = _itemArr[indexPath.row];
    if (indexPath.row==_currentItemIndex) {
        cell.titleLabel.textColor = _selectedTextColor;
        if (!cell.selected) {
            [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
            _lineView.tf_width = cell.tf_width - _lineSpace *2;
            _lineView.tf_left = cell.tf_left + _lineSpace;
        }
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
    [UIView animateWithDuration:0.3 animations:^{
        _lineView.tf_width = cell.tf_width - _lineSpace *2;
        _lineView.tf_left = cell.tf_left + _lineSpace;
    } completion:^(BOOL finished) {
        if (_currentItemIndex!=indexPath.row) {
            _currentItemIndex = indexPath.row;
            //调用变化
            if (_changeBlock) {
                _changeBlock (_currentItemIndex,_itemArr[_currentItemIndex]);
            }
        }
    }];
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    TFSegmentViewTitleCell *cell = (TFSegmentViewTitleCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.titleLabel.textColor = _textColor;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
