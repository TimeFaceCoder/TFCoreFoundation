//
//  TFAssetCell.m
//  TFPhotoBrowser
//
//  Created by Melvin on 2/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFAssetCell.h"
#import "TFAssetImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFAssetCell ()

@property (nonatomic, strong) TFAssetImageView *imageView;
@property (nonatomic, strong) UIImageView *selectedBadgeImageView;

@end

const static CGFloat kPadding = 8.0f;

@implementation TFAssetCell

- (void)setAsset:(nullable PHAsset *)asset {
    self.imageView.asset = asset;
    
    [self _updateAccessibility];
}

- (nullable PHAsset *)asset {
    return self.imageView.asset;
}

- (void)setAssetSelected:(BOOL)assetSelected {
    _assetSelected = assetSelected;
    
//    self.selectedBadgeImageView.hidden = !_assetSelected;
    _selectedBadgeButton.selected = _assetSelected;
    
    [self _updateAccessibility];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:NO];
    
    [self _updateAccessibility];
}

- (void)_init {
    _imageView = [[TFAssetImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    _imageView.backgroundColor = [UIColor colorWithRed:0.921 green:0.921 blue:0.946 alpha:1.000];
    _imageView.layer.borderColor = [UIColor colorWithRed:0.401 green:0.682 blue:0.017 alpha:1.000].CGColor;
    [self.contentView addSubview:_imageView];
    
    _selectedBadgeButton = [[UIButton alloc] init];
    _selectedBadgeButton.backgroundColor = [UIColor clearColor];
    [_selectedBadgeButton addTarget:self
                             action:@selector(actionForSelecteButton:)
                   forControlEvents:UIControlEventTouchUpInside];
    [_selectedBadgeButton setImage:[UIImage imageNamed:@"TFLibraryResource.bundle/images/TFLibraryCollectionUnSelected.png"] forState:UIControlStateNormal];
    [_selectedBadgeButton setImage:[UIImage imageNamed:@"TFLibraryResource.bundle/images/TFLibraryCollectionSelected.png"] forState:UIControlStateSelected];
    _selectedBadgeButton.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:_selectedBadgeButton];
    
    
    self.isAccessibilityElement = YES;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _imageView.frame = self.contentView.bounds;
    CGFloat width = 30;
    CGFloat height = 30;

    
    CGFloat x = CGRectGetWidth(self.contentView.bounds) - kPadding - width;
    _selectedBadgeButton.frame = CGRectMake(x, kPadding, width, height);
}

- (void)actionForSelecteButton:(id)sender {
    if (self.tfAssetCellDelegate && [self.tfAssetCellDelegate respondsToSelector:@selector(assetCellViewClick:indexPath:)]) {
        [self.tfAssetCellDelegate assetCellViewClick:TFAssetCellClickTypeSelect indexPath:self.indexPath];
    }
}

- (void)_updateAccessibility {
    static dispatch_queue_t queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // by using a serial queue, we ensure that the final values set will be applied last
        queue = dispatch_queue_create("-[TNKAssetCell _updateAccessibility]", DISPATCH_QUEUE_SERIAL);
    });
    
    
    NSDate *creationDate = self.asset.creationDate;
    
    dispatch_async(queue, ^{
        NSString *date = [NSDateFormatter localizedStringFromDate:creationDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
        NSString *accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"Photo, %@", nil), date];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.accessibilityLabel = accessibilityLabel;
            if (self.assetSelected) {
                self.accessibilityTraits |= UIAccessibilityTraitSelected;
            } else {
                self.accessibilityTraits &= ~UIAccessibilityTraitSelected;
            }
        });
    });
}

@end

NS_ASSUME_NONNULL_END