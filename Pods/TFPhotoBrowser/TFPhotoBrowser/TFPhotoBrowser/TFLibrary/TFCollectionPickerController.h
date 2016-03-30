//
//  TFCollectionPickerController.h
//  TFPhotoBrowser
//
//  Created by Melvin on 2/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TFCollectionPickerController;
@class PHAssetCollection;
@class PHCollectionList;
@class PHFetchOptions;

NS_ASSUME_NONNULL_BEGIN

@protocol TFCollectionPickerControllerDelegate <NSObject>

- (void)collectionPicker:(TFCollectionPickerController *)collectionPicker didSelectCollection:(nullable PHAssetCollection *)collection;
@end

@interface TFCollectionPickerController : UITableViewController

@property (nonatomic, weak, nullable) id<TFCollectionPickerControllerDelegate> delegate;

@property (nonatomic, copy, nullable) NSArray<PHAssetCollection *> *additionalAssetCollections;

@property (nonatomic, strong, nullable) PHCollectionList *collectionList;

@property (nonatomic, copy, nullable) PHFetchOptions *assetFetchOptions;

@end

NS_ASSUME_NONNULL_END
