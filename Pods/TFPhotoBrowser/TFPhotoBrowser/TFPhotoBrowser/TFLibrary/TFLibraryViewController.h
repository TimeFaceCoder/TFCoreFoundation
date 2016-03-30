//
//  TFLibraryViewController.h
//  TFPhotoBrowser
//
//  Created by Melvin on 12/15/15.
//  Copyright © 2015 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFAsset.h"

@protocol TFLibraryViewControllerDelegate;

@interface TFLibraryViewController : UIViewController


@property (nonatomic, weak  ) id<TFLibraryViewControllerDelegate  > libraryControllerDelegate;
/**
 *  多选
 */
@property (nonatomic, assign) BOOL                              allowsMultipleSelection;
/**
 *  单选模式下打开图片裁剪
 */
@property (nonatomic, assign) BOOL                              allowsImageCrop;
@property (nonatomic, assign) NSUInteger                        minimumNumberOfSelection;
@property (nonatomic, assign) NSUInteger                        maximumNumberOfSelection;
@property (nonatomic, assign) CGSize                            imageCropSize;
@property (nonatomic, strong) UIColor                           *barButtonColor;
/**
 *  已选择的图片数组
 */
@property (nonatomic, strong) NSMutableArray                    *selectedAssets;
/**
 *  最多可选图片数量
 */
@property (nonatomic, assign) NSInteger                         maxSelectedCount;

@end



/**
 *  照片选择回调
 */
@protocol TFLibraryViewControllerDelegate <NSObject>

@optional
- (void)didSelectPHAssets:(NSArray<TFAsset *> *)assets
               removeList:(NSArray<TFAsset *> *)removeList
                    infos:(NSMutableArray *)infos;
- (void)didSelectImage:(UIImage *)image;

/**
 *  图片检测尺寸
 *
 *  @return
 */
- (CGSize)sizeOfImageCrop;



@end
