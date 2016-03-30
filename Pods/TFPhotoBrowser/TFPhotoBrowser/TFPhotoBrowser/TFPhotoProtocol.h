//
//  TFPhotoProtocol.h
//  TFPhotoBrowser
//
//  Created by Melvin on 8/28/15.
//  Copyright © 2015 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TFPhotoBrowserConstants.h"


// Notifications
#define TFPHOTO_LOADING_DID_END_NOTIFICATION @"TFPHOTO_LOADING_DID_END_NOTIFICATION"
#define TFPHOTO_PROGRESS_NOTIFICATION        @"TFPHOTO_PROGRESS_NOTIFICATION"


@protocol TFPhoto <NSObject>

@required
@property (nonatomic, strong) UIImage *underlyingImage;
- (void)loadUnderlyingImageAndNotify;
- (void)performLoadUnderlyingImageAndNotify;
- (void)unloadUnderlyingImage;

@optional

- (UIImage *)placeholderImage;

@property (nonatomic) BOOL emptyImage;

// Video
@property (nonatomic) BOOL isVideo;
- (void)getVideoURL:(void (^)(NSURL *url))completion;
- (NSString *)caption;
- (void)cancelAnyLoading;

@end