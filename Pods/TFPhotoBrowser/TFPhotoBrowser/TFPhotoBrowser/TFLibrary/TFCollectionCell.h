//
//  TFCollectionCell.h
//  TFPhotoBrowser
//
//  Created by Melvin on 2/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface TFCollectionCell : UITableViewCell

@property (nonatomic, readonly, strong) UILabel     *titleLabel;
@property (nonatomic, readonly, strong) UILabel     *subtitleLabel;
@property (nonatomic, readonly, strong) UIImageView *thumbnailView;

@end
NS_ASSUME_NONNULL_END