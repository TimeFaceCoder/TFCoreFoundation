//
//  TFZoomingScrollView.m
//  TFPhotoBrowser
//
//  Created by Melvin on 9/1/15.
//  Copyright © 2015 TimeFace. All rights reserved.
//

#import "TFZoomingScrollView.h"
#import "TFTapDetectingImageView.h"
#import "TFTapDetectingView.h"
#import "TFPhotoBrowser.h"
#import "TFPhoto.h"
#import <DACircularProgress/DACircularProgressView.h>
#import "UIImage+TFPhotoBrowser.h"
#import "TFPhotoBrowserPrivate.h"
#import "UIScrollView+ScrollIndicator.h"
#import <CoreMotion/CoreMotion.h>
#import <pop/POP.h>
#import "TFPhotoTagView.h"

#define isLandscape UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])


static const CGFloat TFMotionViewRotationMinimumTreshold = 0.1f;
static const CGFloat TFMotionGyroUpdateInterval = 1 / 100;
static const CGFloat TFMotionViewRotationFactor = 4.0f;

@interface TFZoomingScrollView()<UIScrollViewDelegate,TFTapDetectingViewDelegate,TFTapDetectingImageViewDelegate> {
    TFPhotoBrowser __weak   *_photoBrowser;
    TFTapDetectingView      *_tapView; // for background taps
    DACircularProgressView  *_loadingIndicator;
    UIImageView             *_loadingError;
    CMMotionManager         *_motionManager;
    CGFloat                 _motionRate;
    NSInteger               _minimumXOffset;
    NSInteger               _maximumXOffset;
    BOOL                    _stopTracking;
    CGPoint                 _startOffset;
}


@end

@implementation TFZoomingScrollView

- (id)initWithPhotoBrowser:(TFPhotoBrowser *)browser {
    if ((self = [super init])) {
        
        // Setup
        _index = NSUIntegerMax;
        _photoBrowser = browser;
        
        // Tap view for background
        _tapView = [[TFTapDetectingView alloc] initWithFrame:self.bounds];
        _tapView.tapDelegate = self;
        _tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tapView.backgroundColor = [UIColor clearColor];
        [self addSubview:_tapView];
        
        // Image view
        _photoImageView = [[TFTapDetectingImageView alloc] initWithFrame:CGRectZero];
        _photoImageView.tapDelegate = self;
//        _photoImageView.layer.borderColor = [UIColor yellowColor].CGColor;
//        _photoImageView.layer.borderWidth = 5;
        _photoImageView.contentMode = UIViewContentModeCenter;
        _photoImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_photoImageView];
        
        // Loading indicator
        _loadingIndicator = [[DACircularProgressView alloc] initWithFrame:CGRectMake(140.0f, 30.0f, 40.0f, 40.0f)];
        _loadingIndicator.userInteractionEnabled = NO;
        _loadingIndicator.thicknessRatio = 0.1;
        _loadingIndicator.roundedCorners = NO;
        _loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_loadingIndicator];
        
        // Listen progress notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setProgressFromNotification:)
                                                     name:TFPHOTO_PROGRESS_NOTIFICATION
                                                   object:nil];
        
        // Setup
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self disableScrollIndicator];
    [self stopMonitoring];
}

- (void)prepareForReuse {
    [self hideImageFailure];
    self.photo = nil;
    self.captionView = nil;
    self.selectedButton = nil;
    self.playButton = nil;
    _photoImageView.hidden = NO;
    _photoImageView.image = nil;
    _index = NSUIntegerMax;
    [self disableScrollIndicator];
    [self stopMonitoring];
}

- (BOOL)displayingVideo {
    return [_photo respondsToSelector:@selector(isVideo)] && _photo.isVideo;
}

- (void)setImageHidden:(BOOL)hidden {
    _photoImageView.hidden = hidden;
}

#pragma mark - Image

- (void)setPhoto:(id<TFPhoto>)photo {
    // Cancel any loading on old photo
    if (_photo && photo == nil) {
        if ([_photo respondsToSelector:@selector(cancelAnyLoading)]) {
            [_photo cancelAnyLoading];
        }
    }
    _photo = photo;
    UIImage *img = [_photoBrowser imageForPhoto:_photo];
    if (img) {
        [self displayImage];
    } else {
        // Will be loading so show loading
        [self showLoadingIndicator];
    }
}

// Get and display image
- (void)displayImage {
    if (_photo && _photoImageView.image == nil) {
        [self stopMonitoring];
        // Reset
        self.maximumZoomScale = 1;
        self.minimumZoomScale = 1;
        self.zoomScale = 1;
        self.contentSize = CGSizeMake(0, 0);
        
        // Get image from browser as it handles ordering of fetching
        UIImage *img = [_photoBrowser imageForPhoto:_photo];
        if (img) {
            
            // Hide indicator
            [self hideLoadingIndicator];
            
            // Set image
            _photoImageView.image = img;
            _photoImageView.hidden = NO;
            
            // Setup photo frame
            CGRect photoImageViewFrame;
            photoImageViewFrame.origin = CGPointZero;
            photoImageViewFrame.size = img.size;
            _photoImageView.frame = photoImageViewFrame;
            self.contentSize = photoImageViewFrame.size;
            
            // Set zoom to minimum zoom
            [self setMaxMinZoomScalesForCurrentBounds];
            
        } else  {
            
            // Show image failure
            [self displayImageFailure];
            
        }
        [self setNeedsLayout];
    }
}


// Image failed so just show black!
- (void)displayImageFailure {
    [self hideLoadingIndicator];
    _photoImageView.image = nil;
    
    // Show if image is not empty
    if (![_photo respondsToSelector:@selector(emptyImage)] || !_photo.emptyImage) {
        if (!_loadingError) {
            _loadingError = [UIImageView new];
            _loadingError.image = [UIImage imageForResourcePath:@"MWPhotoBrowser.bundle/ImageError" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]];
            _loadingError.userInteractionEnabled = NO;
            _loadingError.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
            UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
            [_loadingError sizeToFit];
            [self addSubview:_loadingError];
        }
        _loadingError.frame = CGRectMake(floorf((self.bounds.size.width - _loadingError.frame.size.width) / 2.),
                                         floorf((self.bounds.size.height - _loadingError.frame.size.height) / 2),
                                         _loadingError.frame.size.width,
                                         _loadingError.frame.size.height);
    }
    [self stopMonitoring];
}

- (void)hideImageFailure {
    if (_loadingError) {
        [_loadingError removeFromSuperview];
        _loadingError = nil;
    }
}

- (void)removeAllTags {
    for (UIView *view in [self subviews]) {
//        NSLog(@"view = %@",view);
        if ([view isKindOfClass:[TFPhotoTagView class]]) {
            view.hidden = YES;
            [view removeFromSuperview];
        }
    }
}

#pragma mark - Loading Progress

- (void)setProgressFromNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dict = [notification object];
        id <TFPhoto> photoWithProgress = [dict objectForKey:@"photo"];
        if (photoWithProgress == self.photo) {
            float progress = [[dict valueForKey:@"progress"] floatValue];
            _loadingIndicator.progress = MAX(MIN(1, progress), 0);
        }
    });
}

- (void)hideLoadingIndicator {
    _loadingIndicator.hidden = YES;
}

- (void)showLoadingIndicator {
    self.zoomScale = 0;
    self.minimumZoomScale = 0;
    self.maximumZoomScale = 0;
    _loadingIndicator.progress = 0;
    _loadingIndicator.hidden = NO;
    [self hideImageFailure];
}

#pragma mark - Setup

- (CGFloat)initialZoomScaleWithMinScale {
    CGFloat zoomScale = self.minimumZoomScale;
    if (_photoImageView && _photoBrowser.zoomPhotosToFill) {
        // Zoom image to fill if the aspect ratios are fairly similar
        CGSize boundsSize = self.bounds.size;
        CGSize imageSize = _photoImageView.image.size;
        CGFloat boundsAR = boundsSize.width / boundsSize.height;
        CGFloat imageAR = imageSize.width / imageSize.height;
        CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
        CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
        // Zooms standard portrait images on a 3.5in screen but not on a 4in screen.
        if (ABS(boundsAR - imageAR) < 0.17) {
            zoomScale = MAX(xScale, yScale);
            // Ensure we don't zoom in or out too far, just in case
            zoomScale = MIN(MAX(self.minimumZoomScale, zoomScale), self.maximumZoomScale);
        }
    }
    return zoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    
    // Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    
    // Bail if no image
    if (_photoImageView.image == nil) return;
    
    // Reset position
    _photoImageView.frame = CGRectMake(0, 0, _photoImageView.frame.size.width, _photoImageView.frame.size.height);
    
    // Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _photoImageView.image.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    
    // Calculate Max
    CGFloat maxScale = yScale;
    CGFloat imageRatio = imageSize.height / ([[UIScreen mainScreen] bounds].size.height*[[UIScreen mainScreen] scale]);
    //图片高度大于屏幕高度2倍以上。
    if (imageRatio > 2) {
        maxScale = xScale;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Let them go a bit bigger on a bigger screen!
        maxScale = 4;
    }
    
    // Image is smaller than screen so no zooming!
    if (xScale >= 1 && yScale >= 1) {
        minScale = 1.0;
    }
    
    // Set min/max zoom
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    
    // Initial zoom
    self.zoomScale = [self initialZoomScaleWithMinScale];
    
    // If we're zooming to fill then centralise
    if (self.zoomScale != minScale) {
        
        // Centralise
        self.contentOffset = CGPointMake((imageSize.width * self.zoomScale - boundsSize.width) / 2.0,
                                         (imageSize.height * self.zoomScale - boundsSize.height) / 2.0);
        
    }
    
    // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
    self.scrollEnabled = NO;
    
    // If it's a video then disable zooming
    if ([self displayingVideo]) {
        self.maximumZoomScale = self.zoomScale;
        self.minimumZoomScale = self.zoomScale;
    }
    // Layout
    [self setNeedsLayout];
    
}

#pragma mark - Layout

- (void)layoutSubviews {
    
    // Update tap view frame
    _tapView.frame = self.bounds;
    
    // Position indicators (centre does not seem to work!)
    if (!_loadingIndicator.hidden)
        _loadingIndicator.frame = CGRectMake(floorf((self.bounds.size.width - _loadingIndicator.frame.size.width) / 2.),
                                             floorf((self.bounds.size.height - _loadingIndicator.frame.size.height) / 2),
                                             _loadingIndicator.frame.size.width,
                                             _loadingIndicator.frame.size.height);
    if (_loadingError)
        _loadingError.frame = CGRectMake(floorf((self.bounds.size.width - _loadingError.frame.size.width) / 2.),
                                         floorf((self.bounds.size.height - _loadingError.frame.size.height) / 2),
                                         _loadingError.frame.size.width,
                                         _loadingError.frame.size.height);
    
    // Super
    [super layoutSubviews];
    
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _photoImageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    // Center
    if (!CGRectEqualToRect(_photoImageView.frame, frameToCenter))
        _photoImageView.frame = frameToCenter;
    
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _photoImageView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopMonitoring];
    [_photoBrowser cancelControlHiding];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self.scrollEnabled = YES; // reset
    [_photoBrowser cancelControlHiding];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [_photoBrowser hideControlsAfterDelay];
    if (self.zoomScale > self.minimumZoomScale) {
        [self startMonitoring];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Tap Detection

- (void)handleSingleTap:(CGPoint)touchPoint {
    [_photoBrowser performSelector:@selector(toggleControls) withObject:nil afterDelay:0.2];
}

- (void)handleDoubleTap:(CGPoint)touchPoint {
    
    // Dont double tap to zoom if showing a video
    if ([self displayingVideo]) {
        return;
    }
    
    // Cancel any single tap handling
    [NSObject cancelPreviousPerformRequestsWithTarget:_photoBrowser];
    
    // Delay controls
    [_photoBrowser hideControlsAfterDelay];
    // Zoom
    if (self.zoomScale == self.maximumZoomScale) {
        // Zoom out
        [self setZoomScale:self.minimumZoomScale animated:YES];
        [self stopMonitoring];
    } else {
        // Zoom in
        [self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
        [self startMonitoring];
    }
}

// Image View
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch {
    [self handleSingleTap:[touch locationInView:imageView]];
}
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:imageView]];
}

// Background View
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch {
    // Translate touch location to image view location
    CGFloat touchX = [touch locationInView:view].x;
    CGFloat touchY = [touch locationInView:view].y;
    touchX *= 1/self.zoomScale;
    touchY *= 1/self.zoomScale;
    touchX += self.contentOffset.x;
    touchY += self.contentOffset.y;
    [self handleSingleTap:CGPointMake(touchX, touchY)];
}
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch {
    // Translate touch location to image view location
    CGFloat touchX = [touch locationInView:view].x;
    CGFloat touchY = [touch locationInView:view].y;
    touchX *= 1/self.zoomScale;
    touchY *= 1/self.zoomScale;
    touchX += self.contentOffset.x;
    touchY += self.contentOffset.y;
    [self handleDoubleTap:CGPointMake(touchX, touchY)];
}


#pragma mark - Core Motion

- (void)startMonitoring {
    //motion
    [self enableScrollIndicator];
    _motionRate = _photoImageView.frame.size.width / self.frame.size.width * TFMotionViewRotationFactor;
    _maximumXOffset = self.contentSize.width - self.bounds.size.width;
    
    if (CGRectGetWidth(self.frame) >= _photoImageView.image.size.width) {
        return;
    }
    //    if (self.contentSize.width <= _photoImageView.image.size.width) {
    //        [self disableScrollIndicator];
    //        return;
    //    }
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.gyroUpdateInterval = TFMotionGyroUpdateInterval;
    }
    __weak __typeof(self)weakSelf = self;
    if (![_motionManager isGyroActive] && [_motionManager isGyroAvailable] ) {
        [_motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
                                    withHandler:^(CMGyroData *gyroData, NSError *error)
         {
             CGFloat rotationRate = isLandscape ? gyroData.rotationRate.x : gyroData.rotationRate.y;
             if (fabs(rotationRate) >= TFMotionViewRotationMinimumTreshold) {
                 CGFloat offsetX = weakSelf.contentOffset.x - rotationRate * _motionRate;
                 if (offsetX > _maximumXOffset) {
                     offsetX = _maximumXOffset;
                 } else if (offsetX < _minimumXOffset) {
                     offsetX = _minimumXOffset;
                 }
                 NSLog(@"offsetX:%@",@(offsetX));
                 if (!_stopTracking) {
                     [UIView animateWithDuration:0.3f
                                           delay:0.0f
                                         options:UIViewAnimationOptionBeginFromCurrentState |
                      UIViewAnimationOptionAllowUserInteraction |
                      UIViewAnimationOptionCurveEaseOut
                                      animations:^{
                                          [weakSelf setContentOffset:CGPointMake(offsetX, 0) animated:NO];
                                          _startOffset = CGPointMake(offsetX, 0);
                                      }
                                      completion:nil];
                 }
                 
             }
         }];
    } else {
        NSLog(@"There is not available gyro.");
    }
}

- (void)stopMonitoring
{
    [self disableScrollIndicator];
    [_motionManager stopGyroUpdates];
    _motionManager = nil;
}

- (CGPoint)normalizedPositionForPoint:(CGPoint)point {
    return   [self normalizedPositionForPoint:point inFrame:[self frameForImage]];
}

- (CGPoint)normalizedPositionForPoint:(CGPoint)point inFrame:(CGRect)frame
{
    CGFloat startX = self.frame.origin.x;
    if (startX > 10) {
        startX = 10;
    }
    point.x -= (frame.origin.x - startX);
    point.y -= (frame.origin.y - self.frame.origin.y);
    
    NSLog(@"point = %@,frame = %@",NSStringFromCGPoint(point),NSStringFromCGRect(frame));
    
    CGPoint normalizedPoint = CGPointMake(point.x / frame.size.width,
                                          point.y / frame.size.height);
    
    return normalizedPoint;
}
- (CGRect)frameForImage
{
    if(_photoImageView.image == nil){
        return CGRectZero;
    }
    //    return _photoImageView.frame;
    
    
    NSLog(@"image frame:%@",NSStringFromCGRect(_photoImageView.frame));
    NSLog(@"image bounds:%@",NSStringFromCGRect(_photoImageView.bounds));
    
    CGRect photoDisplayedFrame;
    if(_photoImageView.contentMode == UIViewContentModeScaleAspectFit){
        photoDisplayedFrame = AVMakeRectWithAspectRatioInsideRect(_photoImageView.image.size, _photoImageView.frame);
    } else if(_photoImageView.contentMode == UIViewContentModeCenter) {
        CGPoint photoOrigin = CGPointZero;
        photoOrigin.x = (_photoImageView.frame.size.width - (_photoImageView.image.size.width * self.zoomScale)) * 0.5;
        photoOrigin.y = (_photoImageView.frame.size.height - (_photoImageView.image.size.height * self.zoomScale)) * 0.5;
        photoDisplayedFrame = CGRectMake(photoOrigin.x,
                                         photoOrigin.y,
                                         _photoImageView.image.size.width*self.zoomScale,
                                         _photoImageView.image.size.height*self.zoomScale);
    } else {
        NSAssert(0, @"Don't know how to generate frame for photo with current content mode.");
    }
    
    return photoDisplayedFrame;
}

- (void)startNewTagPopover:(TFPhotoTagView *)popover
         atNormalizedPoint:(CGPoint)normalizedPoint
              pointOnImage:(CGPoint)pointOnImage
                      size:(CGSize)sizeOnImage
{
    TFPLog(@"normalized.x=%@,y=%@",@(normalizedPoint.x),@(normalizedPoint.y));
//        NSAssert(((normalizedPoint.x >= 0.0 && normalizedPoint.x <= 1.0) &&
//                  (normalizedPoint.y >= 0.0 && normalizedPoint.y <= 1.0)),
//                 @"Point is outside of photo.");
    
    
    CGRect photoFrame = [self frameForImage];
    
    CGPoint tagLocation =
    CGPointMake(photoFrame.origin.x + (photoFrame.size.width * normalizedPoint.x),
                photoFrame.origin.y + (photoFrame.size.height * normalizedPoint.y));
    
    [popover presentPopoverFromPoint:tagLocation inView:self animated:YES];
    [popover setNormalizedArrowPoint:normalizedPoint];
    [popover setPointOnImage:pointOnImage];
    [popover setSizeOnImage:sizeOnImage];
    if (!popover.text.length) {
//        [popover becomeFirstResponder];
        popover.text = NSLocalizedString(@"这是谁?", nil);
    }
}




@end
