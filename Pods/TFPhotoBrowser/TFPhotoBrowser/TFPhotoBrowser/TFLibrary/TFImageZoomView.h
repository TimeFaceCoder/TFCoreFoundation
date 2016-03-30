//
//  TFImageZoomView.h
//  TFPhotoBrowser
//
//  Created by Melvin on 2/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFImageZoomView : UIScrollView

@property (nonatomic) CGSize imageSize;
@property (nonatomic, strong, nullable) UIImage *image;

@property (nonatomic, readonly) UIView                 *imageView;
@property (nonatomic, readonly) CGFloat                fullZoomLevel;
@property (nonatomic, readonly) CGFloat                defaultZoomLevel;
@property (nonatomic, readonly) UITapGestureRecognizer *zoomRecognizer;

@end

NS_ASSUME_NONNULL_END
