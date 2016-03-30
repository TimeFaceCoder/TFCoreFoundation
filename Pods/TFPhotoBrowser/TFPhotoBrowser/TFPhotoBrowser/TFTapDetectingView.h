//
//  TFTapDetectingView.h
//  TFPhotoBrowser
//
//  Created by Melvin on 9/1/15.
//  Copyright © 2015 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TFTapDetectingViewDelegate;

@interface TFTapDetectingView : UIView
@property (nonatomic, weak) id <TFTapDetectingViewDelegate> tapDelegate;
@end

@protocol TFTapDetectingViewDelegate <NSObject>
@optional
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view tripleTapDetected:(UITouch *)touch;
@end