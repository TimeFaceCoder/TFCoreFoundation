//
//  TFTapDetectingImageView.h
//  TFPhotoBrowser
//
//  Created by Melvin on 8/28/15.
//  Copyright © 2015 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TFTapDetectingImageViewDelegate;

@interface TFTapDetectingImageView : UIImageView
@property (nonatomic, weak) id <TFTapDetectingImageViewDelegate> tapDelegate;
@end

@protocol TFTapDetectingImageViewDelegate <NSObject>
@optional
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView tripleTapDetected:(UITouch *)touch;
@end
