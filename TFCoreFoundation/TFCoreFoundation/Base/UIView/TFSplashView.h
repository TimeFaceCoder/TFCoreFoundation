//
//  TFSplashView.h
//  TFCoreFoundation
//
//  Created by Melvin on 4/11/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFModel.h"

@interface TFSplashModel : TFModel
@property (copy, nonatomic) NSString *imageURL;
@property (copy, nonatomic) NSString *targetURL;
@property (assign, nonatomic) NSTimeInterval splashTime;
@property (assign, nonatomic) CGFloat splashHeightRatio;
@end

typedef void (^TFSplashCompletion)(NSString *targetURL);

@class YYImage;
@interface TFSplashView : UIWindow

typedef NS_ENUM(NSUInteger, TFSplashAnimation) {
    TFSplashAnimationNone,       // No animation
    TFSplashAnimationFade,       // Fade out
    TFSplashAnimationGrowFade,   // Grow and fade out
    TFSplashAnimationDrop,       // Rotate and drop
};


+ (instancetype) sharedSplash;


@property (nonatomic, strong) YYImage          *image;

@property (nonatomic, strong) TFSplashCompletion completion;

@property (nonatomic, strong) UIView           *customView;

- (void) showSplashWithSplashModel:(TFSplashModel *)splashModel;

- (void) showSplashWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle;


- (void) dismissSplashWithAnimation:(TFSplashAnimation)animation;


- (void) dismissSplashWithAnimation:(TFSplashAnimation)animation
                           duration:(NSTimeInterval)duration;

- (void) dismissSplashWithAnimation:(TFSplashAnimation)animation
                           duration:(NSTimeInterval)duration
                              delay:(NSTimeInterval)delay
                            options:(UIViewAnimationOptions)options;

@end
