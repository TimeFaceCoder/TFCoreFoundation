//
//  TFZoomingScrollView.h
//  TFPhotoBrowser
//
//  Created by Melvin on 9/1/15.
//  Copyright © 2015 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFPhotoProtocol.h"


@class TFPhotoBrowser,TFPhoto,TFPhotoCaptionView,TFTapDetectingImageView,TFPhotoTagView;
@interface TFZoomingScrollView : UIScrollView

@property () NSUInteger index;
@property (nonatomic) id <TFPhoto> photo;
@property (nonatomic, weak) TFPhotoCaptionView *captionView;
@property (nonatomic, weak) UIButton *selectedButton;
@property (nonatomic, weak) UIButton *playButton;
@property (nonatomic, strong) TFTapDetectingImageView *photoImageView;

- (id)initWithPhotoBrowser:(TFPhotoBrowser *)browser;
- (void)displayImage;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)prepareForReuse;
- (BOOL)displayingVideo;
- (void)setImageHidden:(BOOL)hidden;

/**
 *  图片复位
 */
- (void)imageRest;

- (void)faceFeature;

- (void)removeAllTags;

- (CGPoint)normalizedPositionForPoint:(CGPoint)point;

- (void)startNewTagPopover:(TFPhotoTagView *)popover atNormalizedPoint:(CGPoint)normalizedPoint pointOnImage:(CGPoint)pointOnImage;

@end
