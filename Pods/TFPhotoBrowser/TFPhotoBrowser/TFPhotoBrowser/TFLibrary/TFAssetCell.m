//
//  TFAssetCell.m
//  TFPhotoBrowser
//
//  Created by Melvin on 2/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFAssetCell.h"
#import "TFAssetImageView.h"
#import "TFiCloudDownloadHelper.h"
#import "SVProgressHUD.h"
#import "RMDownloadIndicator.h"

//NS_ASSUME_NONNULL_BEGIN

@interface TFAssetCell ()

@property (nonatomic, strong) TFAssetImageView *imageView;

@property (nonatomic, strong) UIButton *selectedBadgeButton;

@property (assign, nonatomic) BOOL assetIsInLocalAblum;

@property (strong, nonatomic) RMDownloadIndicator *downloadIndicator;
@end

const static CGFloat kPadding = 8.0f;

@implementation TFAssetCell

#pragma mark imageView
- (TFAssetImageView *)imageView {
    if (!_imageView) {
        _imageView = [[TFAssetImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [UIColor colorWithRed:0.921 green:0.921 blue:0.946 alpha:1.000];
        _imageView.layer.borderColor = [UIColor colorWithRed:0.401 green:0.682 blue:0.017 alpha:1.000].CGColor;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _imageView;
}

#pragma mark selectedBadgeButton
- (UIButton *)selectedBadgeButton {
    if (!_selectedBadgeButton) {
        _selectedBadgeButton = [[UIButton alloc] init];
        _selectedBadgeButton.backgroundColor = [UIColor clearColor];
        [_selectedBadgeButton addTarget:self
                                 action:@selector(actionForSelecteButton:)
                       forControlEvents:UIControlEventTouchUpInside];
        [_selectedBadgeButton setImage:[UIImage imageNamed:@"TFLibraryResource.bundle/images/TFLibraryCollectionUnSelected.png"] forState:UIControlStateNormal];
        [_selectedBadgeButton setImage:[UIImage imageNamed:@"TFLibraryResource.bundle/images/TFLibraryCollectionSelected.png"] forState:UIControlStateSelected];
        _selectedBadgeButton.contentMode = UIViewContentModeCenter;
        _selectedBadgeButton.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _selectedBadgeButton;
}


- (RMDownloadIndicator *)downloadIndicator {
    
    if (!_downloadIndicator) {
        
        _downloadIndicator = [[RMDownloadIndicator alloc] initWithFrame:CGRectZero type:kRMMixedIndictor];
        [_downloadIndicator setBackgroundColor:[UIColor clearColor]];
        [_downloadIndicator setFillColor:[UIColor colorWithWhite:0.9 alpha:1.0]];
        [_downloadIndicator setStrokeColor:[UIColor clearColor]];
        _downloadIndicator.radiusPercent = 0.45;
        _downloadIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _downloadIndicator;
}

- (void)setAsset:(nullable PHAsset *)asset {
    self.imageView.asset = asset;
    
    self.assetIsInLocalAblum = [self _qualityImageInLocalWithPHAsset:asset];
    
    if (self.assetIsInLocalAblum) {
        self.downloadIndicator.hidden = YES;
        self.selectedBadgeButton.hidden = NO;
    }
    else {
//        [self.progressView setTitle:@"0" forState:UIControlStateNormal];
        [self.downloadIndicator loadIndicator];
        [self.downloadIndicator updateWithTotalBytes:100 downloadedBytes:0];
        self.downloadIndicator.hidden= NO;
        self.selectedBadgeButton.hidden = YES;
    }
    
    [self _updateAccessibility];
}

- (nullable PHAsset *)asset {
    return self.imageView.asset;
}

- (void)setAssetSelected:(BOOL)assetSelected {
    _assetSelected = assetSelected;
    _selectedBadgeButton.selected = _assetSelected;
    if (assetSelected) {
        self.imageView.alpha = 0.8;
    }
    else {
        self.imageView.alpha = 1.0;
    }
    [self _updateAccessibility];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:NO];
    
    [self _updateAccessibility];
}

- (void)_init {
    
    //添加subview
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.selectedBadgeButton];
    [self.contentView addSubview:self.downloadIndicator];
    self.isAccessibilityElement = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDownloadQualityImage) name:TFImagePickeriCloudDownLoadFinish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadingQualityImage:) name:TFImagePickeriCloudDownLoading object:nil];
    
    //添加约束
    NSDictionary *viewsDic = @{@"imageView":self.imageView,@"selectedBadgeButton":self.selectedBadgeButton,@"downloadIndicator" : self.downloadIndicator};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]-0-|" options:0 metrics:nil views:viewsDic]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[imageView]-0-|" options:0 metrics:nil views:viewsDic]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[selectedBadgeButton]-5-|" options:0 metrics:nil views:viewsDic]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[selectedBadgeButton]-5-|" options:0 metrics:nil views:viewsDic]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[downloadIndicator(24)]-5-|" options:0 metrics:nil views:viewsDic]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[downloadIndicator(24)]-5-|" options:0 metrics:nil views:viewsDic]];
    
    [self.contentView layoutIfNeeded];
    
}

- (void)downloadingQualityImage:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[TFiCloudDownloadHelper sharedHelper].asset isEqual:self.asset]) {
            [self.downloadIndicator updateWithTotalBytes:100
                                         downloadedBytes:[notification.object floatValue] * 100];
        }
    });
}

- (void)didDownloadQualityImage {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[TFiCloudDownloadHelper sharedHelper].asset isEqual:self.asset]) {
            self.downloadIndicator.hidden = YES;
            self.selectedBadgeButton.hidden = NO;
//            [self actionForSelecteButton:nil];
        }
    });
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

#pragma mark - Tool
- (BOOL)_qualityImageInLocalWithPHAsset:(PHAsset *)phAsset {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = NO;
    option.synchronous = YES;
    
    __block BOOL isInLocalAblum = YES;
    
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:phAsset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        isInLocalAblum = imageData ? YES : NO;
    }];
    return isInLocalAblum;
}


//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    if (CGRectContainsPoint(UIEdgeInsetsInsetRect(_selectedBadgeButton.frame,UIEdgeInsetsMake(-20, -20, 0, 0)), point)) {
//        return _selectedBadgeButton;
//    }
//    return [super hitTest:point withEvent:event];
//}

@end

//NS_ASSUME_NONNULL_END