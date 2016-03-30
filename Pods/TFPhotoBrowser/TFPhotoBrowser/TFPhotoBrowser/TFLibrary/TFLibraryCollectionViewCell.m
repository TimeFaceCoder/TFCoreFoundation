//
//  TFLibraryCollectionViewCell.m
//  TFPhotoBrowser
//
//  Created by Melvin on 12/17/15.
//  Copyright © 2015 TimeFace. All rights reserved.
//

#import "TFLibraryCollectionViewCell.h"
#import <pop/POP.h>
#import <Photos/Photos.h>
#import "TFCollectionOverlayProgressView.h"

@interface TFLibraryCollectionViewCell() {
}

@property (nonatomic ,strong) UIImageView                     *imageView;
@property (nonatomic ,strong) UIImageView                     *livePhotoBadgeImageView;
@property (nonatomic ,strong) UIImageView                     *iCloudBadgeImageView;
@property (nonatomic ,strong) UIButton                        *selectedButton;
@property (nonatomic ,strong) TFCollectionOverlayProgressView *progressView;
@property (nonatomic ,assign) PHImageRequestID                assetRequestID;
@property (nonatomic ,assign) UIView                          *overlayView;


@end

@implementation TFLibraryCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.opaque                       = NO;
        self.alpha                        = 1;
        self.contentMode                  = UIViewContentModeCenter;
        self.showsOverlayViewWhenSelected = NO;
        [self setupViews];
    }
    
    return self;
}


- (void)setupViews {
    
    
    UIView *overlayView = [[UIView alloc] initWithFrame:self.contentView.bounds];
    overlayView.backgroundColor = [UIColor clearColor];
    self.overlayView = overlayView;
    [self.contentView addSubview:self.overlayView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    self.imageView = imageView;
    [self.contentView addSubview:self.imageView];
    
    UIImageView *livePhotoBadgeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
    livePhotoBadgeImageView.contentMode = UIViewContentModeScaleAspectFill;
    livePhotoBadgeImageView.clipsToBounds = YES;
    self.livePhotoBadgeImageView = livePhotoBadgeImageView;
    [self.contentView addSubview:self.livePhotoBadgeImageView];
    
    
    UIImageView *iCloudBadgeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 38, 24)];
    iCloudBadgeImageView.contentMode = UIViewContentModeScaleAspectFill;
    iCloudBadgeImageView.clipsToBounds = YES;
    self.iCloudBadgeImageView = iCloudBadgeImageView;
    [self.contentView addSubview:self.iCloudBadgeImageView];
    
    
    self.progressView = [[TFCollectionOverlayProgressView alloc] initWithFrame:self.contentView.bounds];
    self.progressView.hidden = YES;
    [self.contentView addSubview:self.progressView];
    
    
    UIImage *image = [UIImage imageNamed:@"TFLibraryResource.bundle/images/TFLibraryCollectionSelected.png"];
    CGFloat imageWidth = image.size.width;
    UIButton *selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectedButton setImage:[UIImage imageNamed:@"TFLibraryResource.bundle/images/TFLibraryCollectionUnSelected.png"] forState:UIControlStateNormal];
    [selectedButton setImage:image forState:UIControlStateHighlighted];
    [selectedButton setImage:image forState:UIControlStateSelected];
    selectedButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 4 - imageWidth,4,  imageWidth, imageWidth);
    [selectedButton addTarget:self action:@selector(onViewClick:) forControlEvents:UIControlEventTouchUpInside];
    selectedButton.userInteractionEnabled = NO;
    self.selectedButton = selectedButton;
    [self.contentView addSubview:self.selectedButton];
    
}


- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    //检查iCloud状态
    if (selected && self.showsOverlayViewWhenSelected) {
        [self showOverlayView];
    } else {
        [self hideOverlayView];
    }
    self.selectedButton.selected = selected;
    
}

- (void)setImageDownloadingFromCloud:(BOOL)imageDownloadingFromCloud {
    _imageDownloadingFromCloud = imageDownloadingFromCloud;
    self.progressView.hidden = !_imageDownloadingFromCloud;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.livePhotoBadgeImageView.image = nil;
    [[PHImageManager defaultManager] cancelImageRequest:self.assetRequestID];
    [self.progressView setProgress:0];
    [self.progressView setHidden:YES];
}

- (void)onViewClick:(UIButton *)button {
    [self setSelected:!button.selected];
}
- (void)showOverlayView {
    POPBasicAnimation *backgroundColorAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewBackgroundColor];
    backgroundColorAnimation.toValue = [UIColor colorWithWhite:0 alpha:0.5];
    [self.overlayView pop_addAnimation:backgroundColorAnimation forKey:@"showBackgroundColorAnimation"];
}

- (void)hideOverlayView {
    POPBasicAnimation *backgroundColorAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewBackgroundColor];
    backgroundColorAnimation.toValue = [UIColor clearColor];
    [self.overlayView pop_addAnimation:backgroundColorAnimation forKey:@"hideBackgroundColorAnimation"];
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage imageResultIsInCloud:(BOOL)imageResultIsInCloud {
    self.imageView.image = thumbnailImage;
    self.iCloudBadgeImageView.image = imageResultIsInCloud?[UIImage imageNamed:@"TFLibraryResource.bundle/images/TFLibraryCollectioniCloud.png"]:nil;
    
}

- (void)setLivePhotoBadgeImage:(UIImage *)livePhotoBadgeImage {
    self.livePhotoBadgeImageView.image = livePhotoBadgeImage;
}

- (void)startDownloadImageFromiCloud {
    
}

- (void)updateDownLoadStateByProgress:(double)progress {
    NSLog(@"updateDownLoadStateByProgress progress:%f",progress);
    if (self.progressView.hidden) {
        self.progressView.hidden = NO;
    }
    [self.progressView setProgress:progress];
    if (progress >=1) {
        //下载完成
        self.progressView.hidden = YES;
    }
}



@end
