//
//  TFSplashView.m
//  TFCoreFoundation
//
//  Created by Melvin on 4/11/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFSplashView.h"
#import "YYImage.h"
#import "TFKVStorage.h"
#import "UIApplication+TFCore.h"
#import "TFCoreFoundationMacro.h"
#import "TFCGUtilities.h"
#import <SDWebImage/SDWebImageManager.h>
#import "YYImage+TFCore.h"

@interface TFSplashViewViewController : UIViewController

@property (nonatomic, strong          ) UIView             *customView;
@property (nonatomic, strong          ) NSDictionary       *adObject;
@property (nonatomic, strong          ) TFSplashCompletion completion;
@property (nonatomic, strong, readonly) UIImageView        *imageView;
@property (nonatomic, strong, readonly) UIImageView        *adImageView;
@property (nonatomic, strong) TFKVStorage *storeage;
@property (nonatomic, copy) NSString *adURL;

- (instancetype)initWithSplashImage:(YYImage *)image
                         completion:(TFSplashCompletion)completion
                           adObject:(NSDictionary *)adObject;

@end

@implementation TFSplashViewViewController

- (instancetype)initWithSplashImage:(YYImage *)image
                         completion:(TFSplashCompletion)completion
                           adObject:(NSDictionary *)adObject
{
    if ((self = [super init])) {
        _imageView = [[YYAnimatedImageView alloc] initWithImage:image];
        _adImageView = [[YYAnimatedImageView alloc] init];
        _completion = completion;
        _adObject = adObject;
    }
    
    return self;
}

- (void)setCustomView:(UIView *)customView
{
    if (customView == _customView) {
        return;
    }
    
    [self.customView removeFromSuperview];
    _customView = customView;
    [self.view addSubview:self.customView];
    [self.customView setFrame:self.view.bounds];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.imageView];
    [self.imageView setFrame:self.view.bounds];
    
    [self.view addSubview:self.adImageView];
    CGRect frame = self.view.bounds;
    frame.size.height = frame.size.height * 0.82;
    [self.adImageView setFrame:frame];
    
    //读取闪屏广告数据
    if (_adObject) {
        NSString *adImgUrl = [_adObject objectForKey:@"adImgUrl"];
        _adURL = [_adObject objectForKey:@"adUri"];
        BOOL adImageExists = [[SDWebImageManager sharedManager] cachedImageExistsForURL:[NSURL URLWithString:adImgUrl]];
        if (!adImageExists) {
            return;
        }
        NSString *cacheKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:adImgUrl]];
        UIImage *image = [[[SDWebImageManager sharedManager] imageCache] imageFromDiskCacheForKey:cacheKey];
        //custom splash image
        CATransition *animation = [CATransition animation];
        animation.duration = .35;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.type = kCATransitionFade;
        self.adImageView.image = image;
        [[self.adImageView layer] addAnimation:animation forKey:@"animation"];
        
        
        self.adImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *imageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(viewTapAction:)];
        [self.adImageView addGestureRecognizer:imageViewTap];
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

#ifdef __IPHONE_9_0
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#else
- (NSUInteger)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskAll;
}

- (void)viewTapAction:(UIGestureRecognizer *)gestureRecognizer {
    if (_completion) {
        _completion(_adURL);
    }
}

@end


@implementation TFSplashView {
    id _object;
}

- (instancetype)initWithSplashImage:(YYImage *)image
{
    if ((self = [self initWithFrame:CGRectZero])) {
        self.windowLevel = UIWindowLevelNormal + 1.f;
        self.hidden = YES;
        __weak typeof(self) _self = self;
        
        // We use a simple root view controller here instead of adding subviews to the window
        // because the VC gives us rotation handling for free.
        self.rootViewController = [[TFSplashViewViewController alloc] initWithSplashImage:image
                                                                                     completion:^(id object)
                                   {
                                       [_self dismissSplashWithObject:object];
                                   } adObject:_adObject];
    }
    
    return self;
}

+ (instancetype) sharedSplash {
    static TFSplashView *splashView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        splashView = [[self alloc] initWithSplashImage:[YYImage defaultLaunchImage]];
    });
    return splashView;
}

#pragma mark - Launch Image

- (YYImage *)image {
    return (YYImage *)((TFSplashViewViewController *)self.rootViewController).adImageView.image;
}

- (void)setImage:(YYImage *)image {
    ((TFSplashViewViewController *)self.rootViewController).adImageView.image = image;
}

#pragma mark - Custom View

- (UIView *)customView {
    return ((TFSplashViewViewController *)self.rootViewController).customView;
}

- (void)setCustomView:(UIView *)customView {
    ((TFSplashViewViewController *)self.rootViewController).customView = customView;
}

#pragma mark - Display

- (void)showSplash {
    self.rootViewController.view.alpha = 1.f;
    self.rootViewController.view.transform = CGAffineTransformIdentity;
    
    CGRect frame = [UIApplication sharedApplication].keyWindow.frame;
    
    if (CGRectEqualToRect(frame, CGRectZero)) {
        frame = [UIScreen mainScreen].applicationFrame;
        if (![UIApplication sharedApplication].isStatusBarHidden) {
            CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
            frame.origin.y -= statusBarHeight;
            frame.size.height += statusBarHeight;
        }
    }
    
    [self setFrame:frame];
    
    self.hidden = NO;
}

- (void)dismissSplashWithObject:(id)object {
    _object = [object copy];
    [self dismissSplashWithAnimation:TFSplashAnimationFade
                            duration:0.35
                               delay:0
                             options:UIViewAnimationOptionCurveEaseIn];
}

- (void)showSplashWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
    UINib *nib = [UINib nibWithNibName:nibName bundle:nibBundle];
    NSArray *nibItems = [nib instantiateWithOwner:nil options:nil];
    
    [self setCustomView:[nibItems firstObject]];
    
    [self showSplash];
}

#pragma mark - Dismissal

- (void)dismissSplashWithAnimation:(TFSplashAnimation)animation {
    [self dismissSplashWithAnimation:animation
                            duration:0.6f];
}

- (void)dismissSplashWithAnimation:(TFSplashAnimation)animation
                          duration:(NSTimeInterval)duration {
    [self dismissSplashWithAnimation:animation
                            duration:duration
                               delay:0.f
                             options:UIViewAnimationOptionCurveEaseIn];
}

- (void)dismissSplashWithAnimation:(TFSplashAnimation)animation
                          duration:(NSTimeInterval)duration
                             delay:(NSTimeInterval)delay
                           options:(UIViewAnimationOptions)options {
    if (self.hidden) {
        return;
    }
    switch (animation) {
        case TFSplashAnimationNone:
            self.hidden = YES;
            if (self.completion) {
                self.completion(_object);
            }
            break;
            
        case TFSplashAnimationFade:
        case TFSplashAnimationGrowFade:
        case TFSplashAnimationDrop:
            
            [UIView animateWithDuration:duration
                                  delay:delay
                                options:options
                             animations:^
             {
                 
                 if (animation == TFSplashAnimationFade || animation == TFSplashAnimationFade) {
                     self.rootViewController.view.alpha = 0.f;
                 }
                 
                 if (animation == TFSplashAnimationFade) {
                     self.rootViewController.view.transform = CGAffineTransformMakeScale(2.f, 2.f);
                 }
                 
                 if (animation == TFSplashAnimationDrop) {
                     CGFloat angle = M_PI_2;
                     angle *= arc4random_uniform(100) / 100.f;
                     if (arc4random_uniform(2) == 0) {
                         angle = -angle;
                     }
                     CGAffineTransform transform = CGAffineTransformMakeTranslation(0, 1.5f * CGRectGetHeight([[UIScreen mainScreen] bounds]));
                     transform = CGAffineTransformRotate(transform, angle);
                     self.rootViewController.view.transform = transform;
                 }
             } completion:^(BOOL finished) {
                 self.hidden = YES;
                 if (self.completion) {
                     self.completion(_object);
                 }
             }];
            
            break;
    }
}

- (void)clearMemory {
    _object = nil;
}


@end
