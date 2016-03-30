//
//  TFAssetCell.h
//  TFPhotoBrowser
//
//  Created by Melvin on 2/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TFAssetCellClickType){
    /**
     *  无操作
     */
    TFAssetCellClickTypeNone           =    0,
    /**
     *  点击选择
     */
    TFAssetCellClickTypeSelect         =    1,
};


@protocol TFAssetCellDelegate <NSObject>

- (void)assetCellViewClick:(TFAssetCellClickType)type indexPath:(NSIndexPath*)indexPath;

@end

@interface TFAssetCell : UICollectionViewCell

@property (nonatomic, weak) id<TFAssetCellDelegate> tfAssetCellDelegate;
@property (nonatomic, copy  ) NSString      *representedAssetIdentifier;
@property (nonatomic, strong, nullable) PHAsset *asset;
@property (nonatomic) BOOL assetSelected;
@property (nonatomic, strong, readonly) UIButton *selectedBadgeButton;
@property (nonatomic, strong) NSIndexPath  *indexPath;

@end

NS_ASSUME_NONNULL_END