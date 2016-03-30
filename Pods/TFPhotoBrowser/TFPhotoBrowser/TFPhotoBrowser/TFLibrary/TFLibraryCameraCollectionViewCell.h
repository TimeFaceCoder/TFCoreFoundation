//
//  TFLibraryCameraCollectionViewCell.h
//  TFPhotoBrowser
//
//  Created by Melvin on 1/5/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TFLibraryCameraCollectionViewCellDelegate <NSObject>
@optional;
- (void)cameraViewDidAppear;
- (void)cameraViewDidDisappear;

@end

@interface TFLibraryCameraCollectionViewCell : UICollectionViewCell

@property (nonatomic ,weak) id<TFLibraryCameraCollectionViewCellDelegate> delegate;
- (void)startCamera;
- (void)removeCamera;

@end
