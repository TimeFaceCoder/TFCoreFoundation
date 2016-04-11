//
//  TFPhotoBrowser.m
//  TFPhotoBrowser
//
//  Created by Melvin on 8/28/15.
//  Copyright © 2015 TimeFace. All rights reserved.
//

#import "TFPhotoBrowser.h"
#import "TFPhotoCaptionView.h"
#import "TFZoomingScrollView.h"
#import <pop/POP.h>
#import "UIImage+TFPhotoBrowser.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <SDWebImage/SDWebImageManager.h>
#import "TFPhotoBrowserPrivate.h"
#import "TFPhotoBrowserBundle.h"
#import "TFPhotoTagView.h"

@interface TFPhotoBrowser() <TFPhotoTagViewDelegate> {
    BOOL            _tagOnView;
    CGPoint         _editPoint;
    TFPhotoTagView  *_currentTagView;
    BOOL            _willlayout;
}

@end

static void * TFVideoPlayerObservation = &TFVideoPlayerObservation;

@implementation TFPhotoBrowser

#pragma mark - Init

- (id)init {
    if ((self = [super init])) {
        [self _initialisation];
    }
    return self;
}

- (id)initWithDelegate:(id <TFPhotoBrowserDelegate>)delegate {
    if ((self = [self init])) {
        _delegate = delegate;
    }
    return self;
}

- (id)initWithDelegate:(id <TFPhotoBrowserDelegate>)delegate animatedFromView:(UIView*)view {
    if ((self = [self init])) {
        _delegate = delegate;
        _senderViewForAnimation = view;
    }
    return self;
}

- (id)initWithPhotos:(NSArray *)photosArray {
    if ((self = [self init])) {
        _fixedPhotosArray = photosArray;
    }
    return self;
}


- (id)initWithPhotos:(NSArray *)photosArray animatedFromView:(UIView*)view {
    if ((self = [self init])) {
        _fixedPhotosArray = photosArray;
        _senderViewForAnimation = view;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        [self _initialisation];
    }
    return self;
}

- (void)_initialisation {
    
    // Defaults
    NSNumber *isVCBasedStatusBarAppearanceNum = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIViewControllerBasedStatusBarAppearance"];
    if (isVCBasedStatusBarAppearanceNum) {
        _isVCBasedStatusBarAppearance = isVCBasedStatusBarAppearanceNum.boolValue;
    } else {
        _isVCBasedStatusBarAppearance = YES; // default
    }
    self.hidesBottomBarWhenPushed = YES;
    _hasBelongedToViewController = NO;
    _photoCount = NSNotFound;
    _previousLayoutBounds = CGRectZero;
    _currentPageIndex = 0;
    _previousPageIndex = NSUIntegerMax;
    _displayActionButton = YES;
    _displayNavArrows = NO;
    _zoomPhotosToFill = YES;
    _performingLayout = NO; // Reset on view did appear
    _rotating = NO;
    _viewIsActive = NO;
    _enableSwipeToDismiss = YES;
    _delayToHideElements = 5;
    _visiblePages = [[NSMutableSet alloc] init];
    _recycledPages = [[NSMutableSet alloc] init];
    _photos = [[NSMutableArray alloc] init];
    _thumbPhotos = [[NSMutableArray alloc] init];
    _tagInfos = [[NSMutableArray alloc] init];
    _currentGridContentOffset = CGPointMake(0, CGFLOAT_MAX);
    _didSavePreviousStateOfNavBar = NO;
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
        self.automaticallyAdjustsScrollViewInsets = NO;
    // Listen for TFPhoto notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTFPhotoLoadingDidEndNotification:)
                                                 name:TFPHOTO_LOADING_DID_END_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleSeletedTagInfoNotifiacation:)
                                                 name:kNoticeCustomBack
                                               object:nil];
    
    //Animation
    _animationDuration = 0.28;
    _senderViewForAnimation = nil;
    _scaleImage = nil;
    
    _isdraggingPhoto = NO;
    _applicationWindow = [[[UIApplication sharedApplication] delegate] window];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationCapturesStatusBarAppearance = YES;
    }
    else
    {
        _applicationTopViewController = [self topviewController];
        _previousModalPresentationStyle = _applicationTopViewController.modalPresentationStyle;
        _applicationTopViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
}

- (void)dealloc {
    [self clearCurrentVideo];
    _pagingScrollView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self releaseAllUnderlyingPhotos:NO];
    [[SDImageCache sharedImageCache] clearMemory]; // clear memory
}

- (void)releaseAllUnderlyingPhotos:(BOOL)preserveCurrent {
    // Create a copy in case this array is modified while we are looping through
    // Release photos
    NSArray *copy = [_photos copy];
    for (id p in copy) {
        if (p != [NSNull null]) {
            if (preserveCurrent && p == [self photoAtIndex:self.currentIndex]) {
                continue; // skip current
            }
            [p unloadUnderlyingImage];
        }
    }
    // Release thumbs
    copy = [_thumbPhotos copy];
    for (id p in copy) {
        if (p != [NSNull null]) {
            [p unloadUnderlyingImage];
        }
    }
}

- (void)didReceiveMemoryWarning {
    
    // Release any cached data, images, etc that aren't in use.
    [self releaseAllUnderlyingPhotos:YES];
    [_recycledPages removeAllObjects];
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
}

#pragma mark - View Loading

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    // View
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    self.view.clipsToBounds = YES;
    
    // Setup paging scrolling view
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    _pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
    _pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _pagingScrollView.pagingEnabled = YES;
    _pagingScrollView.delegate = self;
    _pagingScrollView.showsHorizontalScrollIndicator = NO;
    _pagingScrollView.showsVerticalScrollIndicator = NO;
    _pagingScrollView.backgroundColor = [UIColor clearColor];
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    [self.view addSubview:_pagingScrollView];
    
    // Transition animation
    [self performPresentAnimation];
    
    // Toolbar
    _toolbar = [[UIToolbar alloc] initWithFrame:[self frameForToolbarAtOrientation:[[UIApplication sharedApplication] statusBarOrientation]]];
    _toolbar.tintColor = [UIColor whiteColor];
    _toolbar.barTintColor = nil;
    [_toolbar setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [_toolbar setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsCompact];
    _toolbar.barStyle = UIBarStyleBlackTranslucent;
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    _navigationItem = [UINavigationItem new];
    _navigationBar = [[UINavigationBar alloc] initWithFrame:[self frameForNavbarAtOrientation:[[UIApplication sharedApplication] statusBarOrientation]]];
    _navigationBar.tintColor = [UIColor whiteColor];
    _navigationBar.barTintColor = nil;
    [_navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [_navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsCompact];
    _navigationBar.barStyle = UIBarStyleBlackTranslucent;
    _navigationBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    _navigationBar.items = @[_navigationItem];
//    _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
//                                                                target:self
//                                                                action:@selector(doneButtonPressed:)];
    NSInteger total;
    NSInteger current;
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowserSelecteNum)]) {
        NSDictionary *dic = [self.delegate photoBrowserSelecteNum];
        total = [[dic objectForKey:@"total"] integerValue];
        current = [[dic objectForKey:@"current"] integerValue];
    }
    
    _doneButton = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:@"完成%@/%@",@(current),@(total)] style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed:)];
    
    _backButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"返回", nil) style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPressed:)];
    
    // Toolbar Items
    if (self.displayActionButton) {
        _actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                      target:self
                                                                      action:@selector(actionButtonPressed:)];
    }
    
    // Update
    [self reloadData];
    
    // Swipe to dismiss
    if (_enableSwipeToDismiss) {
        // Gesture
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        [_panGesture setMinimumNumberOfTouches:1];
        [_panGesture setMaximumNumberOfTouches:1];
        [self.view addGestureRecognizer:_panGesture];
    }
    
    // Super
    [super viewDidLoad];
    
}

- (void)performLayout {
    
    // Setup
    _performingLayout = YES;
    
    // Setup pages
    [_visiblePages removeAllObjects];
    [_recycledPages removeAllObjects];
    
    
    // Toolbar items
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedSpace.width = 32; // To balance action button
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    // Left button - Grid
    [items addObject:fixedSpace];
    
    
    [items addObject:flexSpace];
    
    [items addObject:_actionButton];
    
    
    _toolbar.items = nil;
    if (self.customToolBarView) {
        UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:self.customToolBarView];
        [_toolbar setItems:@[flexSpace,customItem,flexSpace]];
    }
    else {
        // Toolbar visibility
        [_toolbar setItems:items];
    }
    
    if (_displaySelectionButtons) {
       _navigationItem.rightBarButtonItems = @[_doneButton,fixedSpace];
    }
    _navigationItem.leftBarButtonItems = @[_backButton];
    BOOL hideToolbar = YES;
    for (UIBarButtonItem* item in _toolbar.items) {
        if (item != fixedSpace && item != flexSpace) {
            hideToolbar = NO;
            break;
        }
    }
    if (hideToolbar) {
        [_toolbar removeFromSuperview];
    } else {
        [self.view addSubview:_toolbar];
    }
    
    [self.view addSubview:_navigationBar];
    
    // Update nav
    [self updateNavigation];
    
    // Content offset
    _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:_currentPageIndex];
    [self tilePages];
    _performingLayout = NO;
    
}

-(UIView*)customToolBarView
{
    if(!_customToolBarView)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:toolBarViewForPhotoAtIndex:)]) {
            _customToolBarView = [self.delegate photoBrowser:self toolBarViewForPhotoAtIndex:self.currentIndex];
        }
    }
    return _customToolBarView;
}

// Release any retained subviews of the main view.
- (void)viewDidUnload {
    _currentPageIndex = 0;
    _pagingScrollView = nil;
    _visiblePages = nil;
    _recycledPages = nil;
    _toolbar = nil;
    [super viewDidUnload];
}

- (BOOL)presentingViewControllerPrefersStatusBarHidden {
    UIViewController *presenting = self.presentingViewController;
    if (presenting) {
        return [presenting prefersStatusBarHidden];
    } else {
        return NO;
    }
}

#pragma mark - Animation
- (void)performPresentAnimation {
    self.view.alpha = 0.0f;
    _pagingScrollView.alpha = 0.0f;
    
    UIImage *imageFromView = _scaleImage ? _scaleImage : [self getImageFromView:_senderViewForAnimation];
    
    _senderViewOriginalFrame = [_senderViewForAnimation.superview convertRect:_senderViewForAnimation.frame toView:nil];
    
    UIView *fadeView = [[UIView alloc] initWithFrame:_applicationWindow.bounds];
    fadeView.backgroundColor = [UIColor clearColor];
    [_applicationWindow addSubview:fadeView];
    
    UIImageView *resizableImageView = [[UIImageView alloc] initWithImage:imageFromView];
    resizableImageView.frame = _senderViewOriginalFrame;
    resizableImageView.clipsToBounds = YES;
    resizableImageView.contentMode = _senderViewForAnimation ? _senderViewForAnimation.contentMode : UIViewContentModeScaleAspectFill;
    resizableImageView.backgroundColor = [UIColor clearColor];
    [_applicationWindow addSubview:resizableImageView];
    _senderViewForAnimation.hidden = YES;
    
    void (^completion)() = ^() {
        self.view.alpha = 1.0f;
        _pagingScrollView.alpha = 1.0f;
        resizableImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        [fadeView removeFromSuperview];
        [resizableImageView removeFromSuperview];
    };
    
    [UIView animateWithDuration:_animationDuration animations:^{
        fadeView.backgroundColor = [UIColor blackColor];
    } completion:nil];
    
    CGRect finalImageViewFrame = [self animationFrameForImage:imageFromView presenting:YES scrollView:nil];
    
    if(_usePopAnimation) {
        [self animateView:resizableImageView
                  toFrame:finalImageViewFrame
               completion:completion];
    }
    else
    {
        [UIView animateWithDuration:_animationDuration animations:^{
            resizableImageView.layer.frame = finalImageViewFrame;
        } completion:^(BOOL finished) {
            completion();
        }];
    }
}

- (void)performCloseAnimationWithScrollView:(TFZoomingScrollView *)scrollView {
    float fadeAlpha = 1 - fabs(scrollView.frame.origin.y)/scrollView.frame.size.height;
    
    UIImage *imageFromView = [scrollView.photo underlyingImage];
    if (!imageFromView && [scrollView.photo respondsToSelector:@selector(placeholderImage)]) {
        imageFromView = [scrollView.photo placeholderImage];
    }
    
    UIView *fadeView = [[UIView alloc] initWithFrame:_applicationWindow.bounds];
    fadeView.backgroundColor = [UIColor blackColor];
    fadeView.alpha = fadeAlpha;
    [_applicationWindow addSubview:fadeView];
    
    CGRect imageViewFrame = [self animationFrameForImage:imageFromView presenting:NO scrollView:scrollView];
    
    UIImageView *resizableImageView = [[UIImageView alloc] initWithImage:imageFromView];
    resizableImageView.frame = imageViewFrame;
    resizableImageView.contentMode = _senderViewForAnimation ? _senderViewForAnimation.contentMode : UIViewContentModeScaleAspectFill;
    resizableImageView.backgroundColor = [UIColor clearColor];
    resizableImageView.clipsToBounds = YES;
    [_applicationWindow addSubview:resizableImageView];
    self.view.hidden = YES;
    
    void (^completion)() = ^() {
        _senderViewForAnimation.hidden = NO;
        _senderViewForAnimation = nil;
        _scaleImage = nil;
        
        [fadeView removeFromSuperview];
        [resizableImageView removeFromSuperview];
        
        [self prepareForClosePhotoBrowser];
        [self dismissPhotoBrowserAnimated:NO];
    };
    
    [UIView animateWithDuration:_animationDuration animations:^{
        fadeView.alpha = 0;
        self.view.backgroundColor = [UIColor clearColor];
    } completion:nil];
    
    CGRect senderViewOriginalFrame = _senderViewForAnimation.superview ? [_senderViewForAnimation.superview convertRect:_senderViewForAnimation.frame toView:nil] : _senderViewOriginalFrame;
    
    if(_usePopAnimation)
    {
        [self animateView:resizableImageView
                  toFrame:senderViewOriginalFrame
               completion:completion];
    }
    else
    {
        [UIView animateWithDuration:_animationDuration animations:^{
            resizableImageView.layer.frame = senderViewOriginalFrame;
        } completion:^(BOOL finished) {
            completion();
        }];
    }
}

- (CGRect)animationFrameForImage:(UIImage *)image presenting:(BOOL)presenting scrollView:(UIScrollView *)scrollView
{
    if (!image) {
        return CGRectZero;
    }
    
    CGSize imageSize = image.size;
    
    CGFloat maxWidth = CGRectGetWidth(_applicationWindow.bounds);
    CGFloat maxHeight = CGRectGetHeight(_applicationWindow.bounds);
    
    CGRect animationFrame = CGRectZero;
    
    CGFloat aspect = imageSize.width / imageSize.height;
    if (maxWidth / aspect <= maxHeight) {
        animationFrame.size = CGSizeMake(maxWidth, maxWidth / aspect);
    }
    else {
        animationFrame.size = CGSizeMake(maxHeight * aspect, maxHeight);
    }
    
    animationFrame.origin.x = roundf((maxWidth - animationFrame.size.width) / 2.0f);
    animationFrame.origin.y = roundf((maxHeight - animationFrame.size.height) / 2.0f);
    
    if (!presenting) {
        animationFrame.origin.y += scrollView.frame.origin.y;
    }
    
    return animationFrame;
}

#pragma mark - Pan Gesture

- (void)panGestureRecognized:(id)sender {
    // Initial Setup
    TFZoomingScrollView *scrollView = [self pageDisplayedAtIndex:_currentPageIndex];
    
    static float firstX, firstY;
    
    float viewHeight = scrollView.frame.size.height;
    float viewHalfHeight = viewHeight/2;
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    
    // Gesture Began
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        [self setControlsHidden:YES animated:YES permanent:YES];
        
        firstX = [scrollView center].x;
        firstY = [scrollView center].y;
        
        _senderViewForAnimation.hidden = (_currentPageIndex == _initalPageIndex);
        
        _isdraggingPhoto = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    translatedPoint = CGPointMake(firstX, firstY+translatedPoint.y);
    [scrollView setCenter:translatedPoint];
    
    float newY = scrollView.center.y - viewHalfHeight;
    float newAlpha = 1 - fabsf(newY)/viewHeight; //abs(newY)/viewHeight * 1.8;
    
    self.view.opaque = YES;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0
                                                  alpha:newAlpha];
    
    // Gesture Ended
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        if(scrollView.center.y > viewHalfHeight+40 || scrollView.center.y < viewHalfHeight-40) // Automatic Dismiss View
        {
            if (_senderViewForAnimation && _currentPageIndex == _initalPageIndex) {
                [self performCloseAnimationWithScrollView:scrollView];
                return;
            }
            
            CGFloat finalX = firstX, finalY;
            
            CGFloat windowsHeigt = [_applicationWindow frame].size.height;
            
            if(scrollView.center.y > viewHalfHeight+30) // swipe down
                finalY = windowsHeigt*2;
            else // swipe up
                finalY = -viewHalfHeight;
            
            CGFloat animationDuration = 0.35;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationDelegate:self];
            [scrollView setCenter:CGPointMake(finalX, finalY)];
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            [UIView commitAnimations];
            
            [self performSelector:@selector(backButtonPressed:) withObject:self afterDelay:animationDuration];
        }
        else // Continue Showing View
        {
            _isdraggingPhoto = NO;
            [self setNeedsStatusBarAppearanceUpdate];
            
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
            
            CGFloat velocityY = (.35*[(UIPanGestureRecognizer*)sender velocityInView:self.view].y);
            
            CGFloat finalX = firstX;
            CGFloat finalY = viewHalfHeight;
            
            CGFloat animationDuration = (ABS(velocityY)*.0002)+.2;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDelegate:self];
            [scrollView setCenter:CGPointMake(finalX, finalY)];
            [UIView commitAnimations];
        }
    }
}


#pragma mark - pop Animation

- (void)animateView:(UIView *)view toFrame:(CGRect)frame completion:(void (^)(void))completion
{
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    [animation setSpringBounciness:6];
    [animation setDynamicsMass:1];
    [animation setToValue:[NSValue valueWithCGRect:frame]];
    [view pop_addAnimation:animation forKey:nil];
    
    if (completion)
    {
        [animation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
            completion();
        }];
    }
}

#pragma mark - Genaral

- (void)prepareForClosePhotoBrowser {
    // Gesture
    [_applicationWindow removeGestureRecognizer:_panGesture];
    // Controls
    [NSObject cancelPreviousPerformRequestsWithTarget:self]; // Cancel any pending toggles from taps
}

- (void)dismissPhotoBrowserAnimated:(BOOL)animated {
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self dismissViewControllerAnimated:animated completion:^{
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            _applicationTopViewController.modalPresentationStyle = _previousModalPresentationStyle;
        }
    }];
}

- (UIButton*)customToolbarButtonImage:(UIImage*)image imageSelected:(UIImage*)selectedImage action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:selectedImage forState:UIControlStateDisabled];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [button setContentMode:UIViewContentModeCenter];
    [button setFrame:CGRectMake(0,0, image.size.width, image.size.height)];
    return button;
}

- (UIImage*)getImageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 2);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIViewController *)topviewController
{
    UIViewController *topviewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topviewController.presentedViewController) {
        topviewController = topviewController.presentedViewController;
    }
    
    return topviewController;
}


#pragma mark - Appearance

- (void)viewWillAppear:(BOOL)animated {
    
    // Super
    [super viewWillAppear:animated];
    
    // Status bar
    if (!_viewHasAppearedInitially) {
        _leaveStatusBarAlone = [self presentingViewControllerPrefersStatusBarHidden];
        // Check if status bar is hidden on first appear, and if so then ignore it
        if (CGRectEqualToRect([[UIApplication sharedApplication] statusBarFrame], CGRectZero)) {
            _leaveStatusBarAlone = YES;
        }
    }
    // Set style
    if (!_leaveStatusBarAlone && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        _previousStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    }
    
    
    // Update UI
    [self hideControlsAfterDelay];
    
    // Initial appearance
    if (!_viewHasAppearedInitially) {
        
    }
    
    // If rotation occured while we're presenting a modal
    // and the index changed, make sure we show the right one now
    if (_currentPageIndex != _pageIndexBeforeRotation) {
        [self jumpToPageAtIndex:_pageIndexBeforeRotation animated:NO];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewIsActive = YES;
    
    // Autoplay if first is video
    if (!_viewHasAppearedInitially) {
        if (_autoPlayOnAppear) {
            TFPhoto *photo = [self photoAtIndex:_currentPageIndex];
            if ([photo respondsToSelector:@selector(isVideo)] && photo.isVideo) {
                [self playVideoAtIndex:_currentPageIndex];
            }
        }
    }
    
    _viewHasAppearedInitially = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    // Detect if rotation occurs while we're presenting a modal
    _pageIndexBeforeRotation = _currentPageIndex;
    
    // Check that we're being popped for good
    if ([self.navigationController.viewControllers objectAtIndex:0] != self &&
        ![self.navigationController.viewControllers containsObject:self]) {
        
        // State
        _viewIsActive = NO;
    }
    
    // Controls
    [_navigationBar.layer removeAllAnimations]; // Stop all animations on nav bar
    [NSObject cancelPreviousPerformRequestsWithTarget:self]; // Cancel any pending toggles from taps
    [self setControlsHidden:NO animated:NO permanent:YES];
    
    // Status bar
    if (!_leaveStatusBarAlone && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[UIApplication sharedApplication] setStatusBarStyle:_previousStatusBarStyle animated:animated];
    }
    
    // Super
    [super viewWillDisappear:animated];
    
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (parent && _hasBelongedToViewController) {
        [NSException raise:@"TFPhotoBrowser Instance Reuse" format:@"TFPhotoBrowser instances cannot be reused."];
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (!parent) _hasBelongedToViewController = YES;
}

#pragma mark - Nav Bar Appearance



#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (!_willlayout) {
        [self layoutVisiblePages];
        _willlayout = YES;
    }
    
    
}

- (void)layoutVisiblePages {
    NSLog(@"--------------layoutVisiblePages");
    // Flag
    _performingLayout = YES;
    
    // Toolbar
    _toolbar.frame = [self frameForToolbarAtOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    // Remember index
    NSUInteger indexPriorToLayout = _currentPageIndex;
    
    // Get paging scroll view frame to determine if anything needs changing
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    
    // Frame needs changing
    if (!_skipNextPagingScrollViewPositioning) {
        _pagingScrollView.frame = pagingScrollViewFrame;
    }
    _skipNextPagingScrollViewPositioning = NO;
    
    // Recalculate contentSize based on current orientation
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    
    // Adjust frames and configuration of each visible page
    for (TFZoomingScrollView *page in _visiblePages) {
        NSUInteger index = page.index;
        page.frame = [self frameForPageAtIndex:index];
        if (page.captionView) {
            page.captionView.frame = [self frameForCaptionView:page.captionView atIndex:index];
        }
        if (page.selectedButton) {
            page.selectedButton.frame = [self frameForSelectedButton:page.selectedButton atIndex:index];
        }
        if (page.playButton) {
            page.playButton.frame = [self frameForPlayButton:page.playButton atIndex:index];
        }
        
        // Adjust scales if bounds has changed since last time
        if (!CGRectEqualToRect(_previousLayoutBounds, self.view.bounds)) {
            // Update zooms for new bounds
            [page setMaxMinZoomScalesForCurrentBounds];
            _previousLayoutBounds = self.view.bounds;
        }
        
    }
    
    // Adjust video loading indicator if it's visible
    [self positionVideoLoadingIndicator];
    
    // Adjust contentOffset to preserve page location based on values collected prior to location
    
    _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
    [self didStartViewingPageAtIndex:_currentPageIndex]; // initial
    
    
    // Reset
    _currentPageIndex = indexPriorToLayout;
    _performingLayout = NO;
    
    NSArray *array = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:tagInfosAtIndex:)]) {
        array = [self.delegate photoBrowser:self tagInfosAtIndex:_currentPageIndex];
    }
    if (array && [array count] > 0) {
        //检查是否保存过人脸数据
//        NSMutableArray
        NSMutableArray *array_old = [_tagInfos objectAtIndex:_currentPageIndex];
        if ([array_old isKindOfClass:[NSNull class]] || [array_old count] <=0) {
            for (TFPhotoTag *tag in array) {
                if (tag) {
                    
                    [self addFaceRectOnView:tag];
                }
            }
            
        }
        [self configurePageTag:_currentPageIndex];
        
    }
    
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    // Remember page index before rotation
    _pageIndexBeforeRotation = _currentPageIndex;
    _rotating = YES;
    
    // In iOS 7 the nav bar gets shown after rotation, but might as well do this for everything!
    if ([self areControlsHidden]) {
        // Force hidden
    }
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    // Perform layout
    _currentPageIndex = _pageIndexBeforeRotation;
    
    // Delay control holding
    [self hideControlsAfterDelay];
    
    // Layout
    [self layoutVisiblePages];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    _rotating = NO;
    // Ensure nav bar isn't re-displayed
    if ([self areControlsHidden]) {
    }
}

#pragma mark - Data

- (NSUInteger)currentIndex {
    return _currentPageIndex;
}

- (void)reloadData {
    
    // Reset
    _photoCount = NSNotFound;
    
    // Get data
    NSUInteger numberOfPhotos = [self numberOfPhotos];
    [self releaseAllUnderlyingPhotos:YES];
    [_photos removeAllObjects];
    [_thumbPhotos removeAllObjects];
    for (int i = 0; i < numberOfPhotos; i++) {
        [_photos addObject:[NSNull null]];
        [_thumbPhotos addObject:[NSNull null]];
        [_tagInfos addObject:[NSNull null]];
    }
    
    // Update current page index
    if (numberOfPhotos > 0) {
        _currentPageIndex = MAX(0, MIN(_currentPageIndex, numberOfPhotos - 1));
    } else {
        _currentPageIndex = 0;
    }
    
    // Update layout
    if ([self isViewLoaded]) {
        while (_pagingScrollView.subviews.count) {
            [[_pagingScrollView.subviews lastObject] removeFromSuperview];
        }
        [self performLayout];
        [self.view setNeedsLayout];
    }
    
}

- (NSUInteger)numberOfPhotos {
    if (_photoCount == NSNotFound) {
        if ([_delegate respondsToSelector:@selector(numberOfPhotosInPhotoBrowser:)]) {
            _photoCount = [_delegate numberOfPhotosInPhotoBrowser:self];
        } else if (_fixedPhotosArray) {
            _photoCount = _fixedPhotosArray.count;
        }
    }
    if (_photoCount == NSNotFound) _photoCount = 0;
    return _photoCount;
}

- (id<TFPhoto>)photoAtIndex:(NSUInteger)index {
    id <TFPhoto> photo = nil;
    if (index < _photos.count) {
        if ([_photos objectAtIndex:index] == [NSNull null]) {
            if ([_delegate respondsToSelector:@selector(photoBrowser:photoAtIndex:)]) {
                photo = [_delegate photoBrowser:self photoAtIndex:index];
            } else if (_fixedPhotosArray && index < _fixedPhotosArray.count) {
                photo = [_fixedPhotosArray objectAtIndex:index];
            }
            if (photo) [_photos replaceObjectAtIndex:index withObject:photo];
        } else {
            photo = [_photos objectAtIndex:index];
        }
    }
    return photo;
}

- (id<TFPhoto>)thumbPhotoAtIndex:(NSUInteger)index {
    id <TFPhoto> photo = nil;
    if (index < _thumbPhotos.count) {
        if ([_thumbPhotos objectAtIndex:index] == [NSNull null]) {
            if ([_delegate respondsToSelector:@selector(photoBrowser:thumbPhotoAtIndex:)]) {
                photo = [_delegate photoBrowser:self thumbPhotoAtIndex:index];
            }
            if (photo) [_thumbPhotos replaceObjectAtIndex:index withObject:photo];
        } else {
            photo = [_thumbPhotos objectAtIndex:index];
        }
    }
    return photo;
}

- (TFPhotoCaptionView *)captionViewForPhotoAtIndex:(NSUInteger)index {
    TFPhotoCaptionView *captionView = nil;
    if ([_delegate respondsToSelector:@selector(photoBrowser:captionViewForPhotoAtIndex:)]) {
        captionView = [_delegate photoBrowser:self captionViewForPhotoAtIndex:index];
    } else {
        id <TFPhoto> photo = [self photoAtIndex:index];
        if ([photo respondsToSelector:@selector(caption)]) {
            if ([photo caption]) captionView = [[TFPhotoCaptionView alloc] initWithPhoto:photo];
        }
    }
    captionView.alpha = [self areControlsHidden] ? 0 : 1; // Initial alpha
    return captionView;
}

- (BOOL)photoIsSelectedAtIndex:(NSUInteger)index {
    BOOL value = NO;
    if (_displaySelectionButtons) {
        if ([self.delegate respondsToSelector:@selector(photoBrowser:isPhotoSelectedAtIndex:section:)]) {
            value = [self.delegate photoBrowser:self isPhotoSelectedAtIndex:index section:self.indexPath.section];
        }
    }
    return value;
}

- (void)setPhotoSelected:(BOOL)selected atIndex:(NSUInteger)index {
    if (_displaySelectionButtons) {
        if ([self.delegate respondsToSelector:@selector(photoBrowser:photoAtIndex:section:selectedChanged:)]) {
            [self.delegate photoBrowser:self photoAtIndex:index section:self.indexPath.section selectedChanged:selected];
        }
    }
}

- (UIImage *)imageForPhoto:(id<TFPhoto>)photo {
    if (photo) {
        // Get image or obtain in background
        if ([photo underlyingImage]) {
            return [photo underlyingImage];
        } else {
            [photo loadUnderlyingImageAndNotify];
        }
    }
    return nil;
}

- (UIImageView *)imageView {
    TFZoomingScrollView *page = [self pageDisplayedAtIndex:_currentPageIndex];
    if (page) {
        return (UIImageView *)page.photoImageView;
    }
    
    return nil;
}

- (void)loadAdjacentPhotosIfNecessary:(id<TFPhoto>)photo {
    TFZoomingScrollView *page = [self pageDisplayingPhoto:photo];
    if (page) {
        // If page is current page then initiate loading of previous and next pages
        [page displayImage];
//        if (_tagOnView) {
//            [self configurePageTag:_currentPageIndex];
//        }
        NSUInteger pageIndex = page.index;
        if (_currentPageIndex == pageIndex) {
            if (pageIndex > 0) {
                // Preload index - 1
                id <TFPhoto> photo = [self photoAtIndex:pageIndex-1];
                if (![photo underlyingImage]) {
                    [photo loadUnderlyingImageAndNotify];
                    TFPLog(@"Pre-loading image at index %lu", (unsigned long)pageIndex-1);
                }
            }
            if (pageIndex < [self numberOfPhotos] - 1) {
                // Preload index + 1
                id <TFPhoto> photo = [self photoAtIndex:pageIndex+1];
                if (![photo underlyingImage]) {
                    [photo loadUnderlyingImageAndNotify];
                    TFPLog(@"Pre-loading image at index %lu", (unsigned long)pageIndex+1);
                }
            }
        }
    }
    
    
}

#pragma mark - TFPhoto Loading Notification

- (void)handleTFPhotoLoadingDidEndNotification:(NSNotification *)notification {
    NSLog(@"%s",__func__);
    id <TFPhoto> photo = [notification object];
    TFZoomingScrollView *page = [self pageDisplayingPhoto:photo];
    if (page) {
        
        if ([photo underlyingImage]) {
            // Successful load
            [page displayImage];
            
//            if (_tagOnView) {
//                [self configurePageTag:_currentPageIndex];
//            }
            
            [self loadAdjacentPhotosIfNecessary:photo];
        } else {
            
            // Failed to load
            [page displayImageFailure];
        }
        // Update nav
        [self updateNavigation];
        

    }
}

#pragma mark - Selected Tag Info 
- (void)handleSeletedTagInfoNotifiacation:(NSNotification*)notifiaction {
    if (_currentTagView) {
        TFPhotoTag *tag = notifiaction.object;
        _currentTagView.tagTextField.text = nil;
        [_currentTagView setText:tag.tagName];
        _currentTagView.tagId = tag.tagId;
        tag.faceId = _currentTagView.faceId;

        NSArray *array = [_tagInfos objectAtIndex:_currentPageIndex];
        for (TFPhotoTag *ptag in array) {
            if ([ptag.faceId isEqualToString:tag.faceId]) {
                ptag.tagId = tag.tagId;
                ptag.tagName = tag.tagName;
            }
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:updateTagInfo:index:)]) {
            [self.delegate photoBrowser:self updateTagInfo:@{
                                                             @"tagId"  : tag
                                                             }index:0];
        }
    }
}

#pragma  mark - Contact Selected Notification

//- (void)handleContactsLoadedNotification:(NSNotification *)notification {
//    if ([notification userInfo]) {
//        NSDictionary *userInfo = [notification userInfo];
//        if ([[userInfo objectForKey:@"name"] length]) {
//            if (_editPoint.x > 0 && _editPoint.y > 0) {
//                NSMutableArray *array = [_tagInfos objectAtIndex:_currentPageIndex];
//                if (![array isKindOfClass:[NSNull class]]) {
//                    for (TFPhotoTag *model in array) {
//                        if (model.tagRect.origin.x == _editPoint.x && model.tagRect.origin.y == _editPoint.y) {
//                            model.tagName = [userInfo objectForKey:@"name"];
//                            model.selected = YES;
//                        }
//                    }
//                    [self configurePageTag:_currentPageIndex];
//                    
//                    if ([_delegate respondsToSelector:@selector(updatePhotoInfos:photoAtIndex:)]) {
//                        [_delegate updatePhotoInfos:array photoAtIndex:_currentPageIndex];
//                    }
//                }
//            }
//            
//        }
//    }
//}

#pragma mark - Paging

- (void)tilePages {
    
    // Calculate which pages should be visible
    // Ignore padding as paging bounces encroach on that
    // and lead to false page loads
    CGRect visibleBounds = _pagingScrollView.bounds;
    NSInteger iFirstIndex = (NSInteger)floorf((CGRectGetMinX(visibleBounds)+PADDING*2) / CGRectGetWidth(visibleBounds));
    NSInteger iLastIndex  = (NSInteger)floorf((CGRectGetMaxX(visibleBounds)-PADDING*2-1) / CGRectGetWidth(visibleBounds));
    if (iFirstIndex < 0) iFirstIndex = 0;
    if (iFirstIndex > [self numberOfPhotos] - 1) iFirstIndex = [self numberOfPhotos] - 1;
    if (iLastIndex < 0) iLastIndex = 0;
    if (iLastIndex > [self numberOfPhotos] - 1) iLastIndex = [self numberOfPhotos] - 1;
    
    // Recycle no longer needed pages
    NSInteger pageIndex;
    for (TFZoomingScrollView *page in _visiblePages) {
        pageIndex = page.index;
        if (pageIndex < (NSUInteger)iFirstIndex || pageIndex > (NSUInteger)iLastIndex) {
            [_recycledPages addObject:page];
            [page.captionView removeFromSuperview];
            [page.selectedButton removeFromSuperview];
            [page.playButton removeFromSuperview];
            [page prepareForReuse];
            [page removeFromSuperview];
            TFPLog(@"Removed page at index %lu", (unsigned long)pageIndex);
        }
    }
    [_visiblePages minusSet:_recycledPages];
    while (_recycledPages.count > 2) // Only keep 2 recycled pages
        [_recycledPages removeObject:[_recycledPages anyObject]];
    
    // Add missing pages
    for (NSUInteger index = (NSUInteger)iFirstIndex; index <= (NSUInteger)iLastIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            
            // Add new page
            TFZoomingScrollView *page = [self dequeueRecycledPage];
            if (!page) {
                page = [[TFZoomingScrollView alloc] initWithPhotoBrowser:self];
            }
            page.backgroundColor = [UIColor clearColor];
            page.opaque = YES;
            [_visiblePages addObject:page];
            [self configurePage:page forIndex:index];
            
            [_pagingScrollView addSubview:page];
            TFPLog(@"Added page at index %lu", (unsigned long)index);
            
            // Add caption
            TFPhotoCaptionView *captionView = [self captionViewForPhotoAtIndex:index];
            if (captionView) {
                captionView.frame = [self frameForCaptionView:captionView atIndex:index];
                [_pagingScrollView addSubview:captionView];
                page.captionView = captionView;
            }
            
            // Add play button if needed
            if (page.displayingVideo) {
                UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [playButton setImage:[UIImage imageForResourcePath:@"TFLibraryResource.bundle/images/PlayButtonOverlayLarge" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateNormal];
                [playButton setImage:[UIImage imageForResourcePath:@"TFLibraryResource.bundle/images/PlayButtonOverlayLargeTap" ofType:@"png" inBundle:[NSBundle bundleForClass:[self class]]] forState:UIControlStateHighlighted];
                [playButton addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                [playButton sizeToFit];
                playButton.frame = [self frameForPlayButton:playButton atIndex:index];
                [_pagingScrollView addSubview:playButton];
                page.playButton = playButton;
            }
            
            // Add selected button
            if (self.displaySelectionButtons) {
                //TFLibraryCollectionUnSelected
                UIButton *selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [selectedButton setImage:TFPhotoBrowserImageNamed(@"TFLibraryCollectionUnSelected")
                                forState:UIControlStateNormal];
                UIImage *selectedOnImage;
                if (self.customImageSelectedIconName) {
                    selectedOnImage = [UIImage imageNamed:self.customImageSelectedIconName];
                } else {
                    selectedOnImage = TFPhotoBrowserImageNamed(@"TFLibraryCollectionSelected");
                }
                [selectedButton setImage:selectedOnImage forState:UIControlStateSelected];
//                [selectedButton sizeToFit];
                selectedButton.frame = CGRectMake(0, 0, 40, 40);
                selectedButton.adjustsImageWhenHighlighted = NO;
                [selectedButton addTarget:self action:@selector(selectedButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                selectedButton.frame = [self frameForSelectedButton:selectedButton atIndex:index];
                [_pagingScrollView addSubview:selectedButton];
                page.selectedButton = selectedButton;
                selectedButton.selected = [self photoIsSelectedAtIndex:index];
            }
            
        }
    }
    
}

- (void)updateVisiblePageStates {
    NSSet *copy = [_visiblePages copy];
    for (TFZoomingScrollView *page in copy) {
        
        // Update selection
        page.selectedButton.selected = [self photoIsSelectedAtIndex:page.index];
        
    }
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
    for (TFZoomingScrollView *page in _visiblePages)
        if (page.index == index) return YES;
    return NO;
}

- (TFZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index {
    TFZoomingScrollView *thePage = nil;
    for (TFZoomingScrollView *page in _visiblePages) {
        if (page.index == index) {
            thePage = page; break;
        }
    }
    return thePage;
}

- (TFZoomingScrollView *)pageDisplayingPhoto:(id<TFPhoto>)photo {
    TFZoomingScrollView *thePage = nil;
    for (TFZoomingScrollView *page in _visiblePages) {
        if (page.photo == photo) {
            thePage = page; break;
        }
    }
    return thePage;
}

- (void)configurePage:(TFZoomingScrollView *)page forIndex:(NSUInteger)index {
    page.frame = [self frameForPageAtIndex:index];
    page.index = index;
    page.photo = [self photoAtIndex:index];
}

- (TFZoomingScrollView *)dequeueRecycledPage {
    TFZoomingScrollView *page = [_recycledPages anyObject];
    if (page) {
        [_recycledPages removeObject:page];
    }
    return page;
}

// Handle page changes
- (void)didStartViewingPageAtIndex:(NSUInteger)index {
    NSLog(@"-0-0-0-0-0-0-0-0-0-0-0-0-0-0-0__%s__",__func__);
    // Handle 0 photos
    if (![self numberOfPhotos]) {
        // Show controls
        [self setControlsHidden:NO animated:YES permanent:YES];
        return;
    }
    
    // Handle video on page change
    if (!_rotating || index != _currentVideoIndex) {
        [self clearCurrentVideo];
    }
    
    // Release images further away than +/-1
    NSUInteger i;
    if (index > 0) {
        // Release anything < index - 1
        for (i = 0; i < index-1; i++) {
            id photo = [_photos objectAtIndex:i];
            if (photo != [NSNull null]) {
                [photo unloadUnderlyingImage];
                [_photos replaceObjectAtIndex:i withObject:[NSNull null]];
                TFPLog(@"Released underlying image at index %lu", (unsigned long)i);
            }
        }
    }
    if (index < [self numberOfPhotos] - 1) {
        // Release anything > index + 1
        for (i = index + 2; i < _photos.count; i++) {
            id photo = [_photos objectAtIndex:i];
            if (photo != [NSNull null]) {
                [photo unloadUnderlyingImage];
                [_photos replaceObjectAtIndex:i withObject:[NSNull null]];
                TFPLog(@"Released underlying image at index %lu", (unsigned long)i);
            }
        }
    }
    
    // Load adjacent images if needed and the photo is already
    // loaded. Also called after photo has been loaded in background
    id <TFPhoto> currentPhoto = [self photoAtIndex:index];
    if ([currentPhoto underlyingImage]) {
        // photo loaded so load ajacent now
        [self loadAdjacentPhotosIfNecessary:currentPhoto];
    }
    
    // Notify delegate
    if (index != _previousPageIndex) {
        if ([_delegate respondsToSelector:@selector(photoBrowser:didDisplayPhotoAtIndex:)])
            [_delegate photoBrowser:self didDisplayPhotoAtIndex:index];
        _previousPageIndex = index;
    }
    
    // Update nav
    [self updateNavigation];

}

#pragma mark - Frame Calculations

- (CGRect)frameForPagingScrollView {
    CGRect frame = self.view.bounds;// [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return CGRectIntegral(frame);
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = _pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return CGRectIntegral(pageFrame);
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = _pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * [self numberOfPhotos], bounds.size.height);
}

- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index {
    CGFloat pageWidth = _pagingScrollView.bounds.size.width;
    CGFloat newOffset = index * pageWidth;
    return CGPointMake(newOffset, 0);
}

- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation {
    CGFloat height = 44;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone &&
        UIInterfaceOrientationIsLandscape(orientation)) height = 32;
    return CGRectIntegral(CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height));
}

- (CGRect)frameForNavbarAtOrientation:(UIInterfaceOrientation)orientation {
    CGFloat height = 64;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone &&
        UIInterfaceOrientationIsLandscape(orientation)) height = 52;
    return CGRectIntegral(CGRectMake(0, 0, self.view.bounds.size.width, height));
}

- (CGRect)frameForCaptionView:(TFPhotoCaptionView *)captionView atIndex:(NSUInteger)index {
    CGRect pageFrame = [self frameForPageAtIndex:index];
    CGSize captionSize = [captionView sizeThatFits:CGSizeMake(pageFrame.size.width, 0)];
    CGRect captionFrame = CGRectMake(pageFrame.origin.x,
                                     pageFrame.size.height - captionSize.height - (_toolbar.superview?_toolbar.frame.size.height:0),
                                     pageFrame.size.width,
                                     captionSize.height);
    return CGRectIntegral(captionFrame);
}

- (CGRect)frameForSelectedButton:(UIButton *)selectedButton atIndex:(NSUInteger)index {
    CGRect pageFrame = [self frameForPageAtIndex:index];
    CGFloat padding = 20;
    CGFloat yOffset = 0;
    if (![self areControlsHidden]) {
        yOffset = _navigationBar.frame.origin.y + _navigationBar.frame.size.height;
    }
    CGRect selectedButtonFrame = CGRectMake(pageFrame.origin.x + pageFrame.size.width - selectedButton.frame.size.width - padding,
                                            padding + yOffset,
                                            selectedButton.frame.size.width,
                                            selectedButton.frame.size.height);
    return CGRectIntegral(selectedButtonFrame);
}

- (CGRect)frameForPlayButton:(UIButton *)playButton atIndex:(NSUInteger)index {
    CGRect pageFrame = [self frameForPageAtIndex:index];
    return CGRectMake(floorf(CGRectGetMidX(pageFrame) - playButton.frame.size.width / 2),
                      floorf(CGRectGetMidY(pageFrame) - playButton.frame.size.height / 2),
                      playButton.frame.size.width,
                      playButton.frame.size.height);
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // Checks
    if (!_viewIsActive || _performingLayout || _rotating) return;
    
    // Tile pages
    [self tilePages];
    
    // Calculate current page
    CGRect visibleBounds = _pagingScrollView.bounds;
    NSInteger index = (NSInteger)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
    if (index > [self numberOfPhotos] - 1) index = [self numberOfPhotos] - 1;
    NSUInteger previousCurrentPage = _currentPageIndex;
    _currentPageIndex = index;
    if (_currentPageIndex != previousCurrentPage) {
        [[self pageDisplayedAtIndex:_currentPageIndex] removeAllTags];
        [self performSelector:@selector(layoutVisiblePages) withObject:nil afterDelay:.5f];
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // Hide controls when dragging begins
    [self setControlsHidden:YES animated:YES permanent:NO];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // Update nav when page changes
    [self updateNavigation];
}

#pragma mark - Navigation

- (void)updateNavigation {
    
    // Title
    NSUInteger numberOfPhotos = [self numberOfPhotos];
    if (numberOfPhotos > 1) {
        if ([_delegate respondsToSelector:@selector(photoBrowser:titleForPhotoAtIndex:)]) {
            _navigationItem.title = [_delegate photoBrowser:self titleForPhotoAtIndex:_currentPageIndex];
        } else {
            _navigationItem.title = [NSString stringWithFormat:@"%lu %@ %lu", (unsigned long)(_currentPageIndex+1), NSLocalizedString(@"of", @"Used in the context: 'Showing 1 of 3 items'"), (unsigned long)numberOfPhotos];
        }
    } else {
        _navigationItem.title = nil;
    }
    
    // Disable action button if there is no image or it's a video
    TFPhoto *photo = [self photoAtIndex:_currentPageIndex];
    if ([photo underlyingImage] == nil || ([photo respondsToSelector:@selector(isVideo)] && photo.isVideo)) {
        _actionButton.enabled = NO;
        _actionButton.tintColor = [UIColor clearColor]; // Tint to hide button
    } else {
        _actionButton.enabled = YES;
        _actionButton.tintColor = nil;
    }
    
}

- (void)jumpToPageAtIndex:(NSUInteger)index animated:(BOOL)animated {
    
    // Change page
    if (index < [self numberOfPhotos]) {
        CGRect pageFrame = [self frameForPageAtIndex:index];
        [_pagingScrollView setContentOffset:CGPointMake(pageFrame.origin.x - PADDING, 0) animated:animated];
        [self updateNavigation];
    }
    
    // Update timer to give more time
    [self hideControlsAfterDelay];
    
}

- (void)gotoPreviousPage {
    [self showPreviousPhotoAnimated:NO];
}
- (void)gotoNextPage {
    [self showNextPhotoAnimated:NO];
}

- (void)showPreviousPhotoAnimated:(BOOL)animated {
    [self jumpToPageAtIndex:_currentPageIndex-1 animated:animated];
}

- (void)showNextPhotoAnimated:(BOOL)animated {
    [self jumpToPageAtIndex:_currentPageIndex+1 animated:animated];
}

#pragma mark - Interactions

- (void)selectedButtonTapped:(id)sender {
    UIButton *selectedButton = (UIButton *)sender;
    selectedButton.selected = !selectedButton.selected;
    NSUInteger index = NSUIntegerMax;
    for (TFZoomingScrollView *page in _visiblePages) {
        if (page.selectedButton == selectedButton) {
            index = page.index;
            break;
        }
    }
    if (index != NSUIntegerMax) {
        [self setPhotoSelected:selectedButton.selected atIndex:index];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowserSelecteNum)]) {
        NSDictionary *dic = [self.delegate photoBrowserSelecteNum];
        NSInteger total = [[dic objectForKey:@"total"] integerValue];
        NSInteger current = [[dic objectForKey:@"current"] integerValue];
        if (_doneButton) {
            [_doneButton setTitle:[NSString stringWithFormat:@"完成%@/%@",@(current),@(total)]];
        }
    }
}

- (void)playButtonTapped:(id)sender {
    UIButton *playButton = (UIButton *)sender;
    NSUInteger index = NSUIntegerMax;
    for (TFZoomingScrollView *page in _visiblePages) {
        if (page.playButton == playButton) {
            index = page.index;
            break;
        }
    }
    if (index != NSUIntegerMax) {
        if (!_currentVideoPlayerViewController) {
            [self playVideoAtIndex:index];
        }
    }
}

#pragma mark - Video

- (void)playVideoAtIndex:(NSUInteger)index {
    id photo = [self photoAtIndex:index];
    if ([photo respondsToSelector:@selector(getVideoURL:)]) {
        
        // Valid for playing
        _currentVideoIndex = index;
        [self clearCurrentVideo];
        [self setVideoLoadingIndicatorVisible:YES atPageIndex:index];
        
        // Get video and play
        [photo getVideoURL:^(NSURL *url) {
            if (url) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self _playVideo:url atPhotoIndex:index];
                });
            } else {
                [self setVideoLoadingIndicatorVisible:NO atPageIndex:index];
            }
        }];
        
    }
}

- (void)_playVideo:(NSURL *)videoURL atPhotoIndex:(NSUInteger)index {
    
    // Setup player
    _currentVideoPlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    [_currentVideoPlayerViewController.moviePlayer prepareToPlay];
    _currentVideoPlayerViewController.moviePlayer.shouldAutoplay = YES;
    _currentVideoPlayerViewController.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    _currentVideoPlayerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    // Remove the movie player view controller from the "playback did finish" notification observers
    // Observe ourselves so we can get it to use the crossfade transition
    [[NSNotificationCenter defaultCenter] removeObserver:_currentVideoPlayerViewController
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:_currentVideoPlayerViewController.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_currentVideoPlayerViewController.moviePlayer];
    
    // Show
    [self presentViewController:_currentVideoPlayerViewController animated:YES completion:nil];
    
}

- (void)videoFinishedCallback:(NSNotification*)notification {
    
    // Remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:_currentVideoPlayerViewController.moviePlayer];
    
    // Clear up
    [self clearCurrentVideo];
    
    // Dismiss
    BOOL error = [[[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue] == MPMovieFinishReasonPlaybackError;
    if (error) {
        // Error occured so dismiss with a delay incase error was immediate and we need to wait to dismiss the VC
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)clearCurrentVideo {
    if (!_currentVideoPlayerViewController) return;
    [_currentVideoLoadingIndicator removeFromSuperview];
    _currentVideoPlayerViewController = nil;
    _currentVideoLoadingIndicator = nil;
    _currentVideoIndex = NSUIntegerMax;
}

- (void)setVideoLoadingIndicatorVisible:(BOOL)visible atPageIndex:(NSUInteger)pageIndex {
    if (_currentVideoLoadingIndicator && !visible) {
        [_currentVideoLoadingIndicator removeFromSuperview];
        _currentVideoLoadingIndicator = nil;
    } else if (!_currentVideoLoadingIndicator && visible) {
        _currentVideoLoadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        [_currentVideoLoadingIndicator sizeToFit];
        [_currentVideoLoadingIndicator startAnimating];
        [_pagingScrollView addSubview:_currentVideoLoadingIndicator];
        [self positionVideoLoadingIndicator];
    }
}

- (void)positionVideoLoadingIndicator {
    if (_currentVideoLoadingIndicator && _currentVideoIndex != NSUIntegerMax) {
        CGRect frame = [self frameForPageAtIndex:_currentVideoIndex];
        _currentVideoLoadingIndicator.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    }
}


#pragma mark - Control Hiding / Showing

// If permanent then we don't set timers to hide again
// Fades all controls on iOS 5 & 6, and iOS 7 controls slide and fade
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent {
    
    // Force visible
    if (![self numberOfPhotos] || _alwaysShowControls)
        hidden = NO;
    
    // Cancel any timers
    [self cancelControlHiding];
    
    // Animations & positions
    CGFloat animatonOffset = 20;
    CGFloat animationDuration = (animated ? 0.35 : 0);
    
    // Status bar
    if (!_leaveStatusBarAlone) {
        
        // Hide status bar
        if (!_isVCBasedStatusBarAppearance) {
            
            // Non-view controller based
            [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animated ? UIStatusBarAnimationSlide : UIStatusBarAnimationNone];
            
        } else {
            
            // View controller based so animate away
            _statusBarShouldBeHidden = hidden;
            [UIView animateWithDuration:animationDuration animations:^(void) {
                [self setNeedsStatusBarAppearanceUpdate];
            } completion:^(BOOL finished) {}];
            
        }
        
    }
    
    // Toolbar, nav bar and captions
    // Pre-appear animation positions for sliding
    if ([self areControlsHidden] && !hidden && animated) {
        
        // Toolbar
        _toolbar.frame = CGRectOffset([self frameForToolbarAtOrientation:[[UIApplication sharedApplication] statusBarOrientation]], 0, animatonOffset);
        
        // Captions
        for (TFZoomingScrollView *page in _visiblePages) {
            if (page.captionView) {
                TFPhotoCaptionView *v = page.captionView;
                // Pass any index, all we're interested in is the Y
                CGRect captionFrame = [self frameForCaptionView:v atIndex:0];
                captionFrame.origin.x = v.frame.origin.x; // Reset X
                v.frame = CGRectOffset(captionFrame, 0, animatonOffset);
            }
        }
        
    }
    [UIView animateWithDuration:animationDuration animations:^(void) {
        
        CGFloat alpha = hidden ? 0 : 1;
        
        // Nav bar slides up on it's own on iOS 7+
        // NavigationBar
        _navigationBar.frame = [self frameForNavbarAtOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        if (hidden) _navigationBar.frame = CGRectOffset(_navigationBar.frame, 0, -animatonOffset);
        _navigationBar.alpha = alpha;
        
        
        // Toolbar
        _toolbar.frame = [self frameForToolbarAtOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        if (hidden) _toolbar.frame = CGRectOffset(_toolbar.frame, 0, animatonOffset);
        _toolbar.alpha = alpha;
        
        // Captions
        for (TFZoomingScrollView *page in _visiblePages) {
            if (page.captionView) {
                TFPhotoCaptionView *v = page.captionView;
                // Pass any index, all we're interested in is the Y
                CGRect captionFrame = [self frameForCaptionView:v atIndex:0];
                captionFrame.origin.x = v.frame.origin.x; // Reset X
                if (hidden) captionFrame = CGRectOffset(captionFrame, 0, animatonOffset);
                v.frame = captionFrame;
                v.alpha = alpha;
            }
        }
        
        // Selected buttons
        for (TFZoomingScrollView *page in _visiblePages) {
            if (page.selectedButton) {
                UIButton *v = page.selectedButton;
                CGRect newFrame = [self frameForSelectedButton:v atIndex:0];
                newFrame.origin.x = v.frame.origin.x;
                v.frame = newFrame;
            }
        }
        
    } completion:^(BOOL finished) {}];
    
    // Control hiding timer
    // Will cancel existing timer but only begin hiding if
    // they are visible
    if (!permanent) [self hideControlsAfterDelay];
    
}

- (BOOL)prefersStatusBarHidden {
    if (!_leaveStatusBarAlone) {
        return _statusBarShouldBeHidden;
    } else {
        return [self presentingViewControllerPrefersStatusBarHidden];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (void)cancelControlHiding {
    // If a timer exists then cancel and release
    if (_controlVisibilityTimer) {
        [_controlVisibilityTimer invalidate];
        _controlVisibilityTimer = nil;
    }
}

// Enable/disable control visiblity timer
- (void)hideControlsAfterDelay {
    if (![self areControlsHidden]) {
        [self cancelControlHiding];
        _controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:self.delayToHideElements
                                                                   target:self
                                                                 selector:@selector(hideControls)
                                                                 userInfo:nil
                                                                  repeats:NO];
    }
}

- (BOOL)areControlsHidden { return (_toolbar.alpha == 0); }
- (void)hideControls { [self setControlsHidden:YES animated:YES permanent:NO]; }
- (void)showControls { [self setControlsHidden:NO animated:YES permanent:NO]; }
- (void)toggleControls { [self setControlsHidden:![self areControlsHidden] animated:YES permanent:NO]; }


#pragma mark - Tag Action

- (void)addFaceRectOnView:(TFPhotoTag*)photoTag {
    
    CGRect rect = CGRectMake(photoTag.tagRect.origin.x, photoTag.tagRect.origin.y, photoTag.tagRect.size.width, photoTag.tagRect.size.height);
    TFPhotoTag *model = [TFPhotoTag photoTagWithRect:rect tagId:photoTag.tagId tagName:photoTag.tagName];
    model.faceId = photoTag.faceId;
    [self updateImageTagInfo:model];
    
    
}

/**
 *  配置当前page tag view
 *
 *  @param index
 */
- (void)configurePageTag:(NSUInteger)index {
    //显示当前page tag
    if ([_tagInfos count]<=0)
        return;
    NSMutableArray *array = [_tagInfos objectAtIndex:index];
    if (array && [array isKindOfClass:[NSMutableArray class]]) {
        NSLog(@"current page tag is:%@",array);
        //remove all tags
        [[self pageDisplayedAtIndex:_currentPageIndex] removeAllTags];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[TFPhotoTag class]]) {
                    TFPhotoTag *model = (TFPhotoTag *)obj;
                    if (model) {
                        UIImageView *imageView = [self imageView];
                        
                        CGFloat scale = MIN(imageView.bounds.size.width / model.tagRect.size.width,
                                            imageView.bounds.size.height / model.tagRect.size.height);
                        CGFloat offsetX = (imageView.bounds.size.width - model.tagRect.size.width * scale) / 2;
                        CGFloat offsetY = (imageView.bounds.size.height - model.tagRect.size.height * scale) / 2;
                        
                        
                        CGFloat width = offsetX + model.tagRect.origin.x;
                        CGFloat height = offsetY + model.tagRect.origin.y;
                        
                        
                        CGPoint faceCenter = CGPointMake(model.tagRect.origin.x + model.tagRect.size.width / 2, model.tagRect.origin.y);
                        
                        
                        CGPoint pointOnView = [self.view convertPoint:faceCenter fromView:imageView];
                        CGPoint normalizedPoint = [[self pageDisplayedAtIndex:_currentPageIndex] normalizedPositionForPoint:pointOnView];
                        dispatch_main_sync_safe(^{
                            CGFloat scaleW = imageView.image.size.width  / self.view.frame.size.width;
                            NSLog(@"image.size.width = %@, image.size.height = %@",@(imageView.image.size.width),@(imageView.image.size.height));
                            TFPhotoTagView *tagView = [[TFPhotoTagView alloc] initWithDelegate:self frame:CGRectMake(0, 0, model.tagRect.size.width / 2/scaleW,  model.tagRect.size.height  / 2/scaleW + 40)];
                            tagView.faceId = model.faceId;
                            NSLog(@"pointOnView = %@, normalizedPoint = %@",NSStringFromCGPoint(pointOnView),NSStringFromCGPoint(normalizedPoint) );

                            if (normalizedPoint.x <0 ||normalizedPoint.y < 0 || normalizedPoint.x > 1 || normalizedPoint.y > 1) {
                                NSLog(@"Point is outside of photo.");
                                return ;
                            }
                            if (model.tagName.length) {
                                [tagView setText:model.tagName];
                            }
                            [[self pageDisplayedAtIndex:_currentPageIndex] startNewTagPopover:tagView
                                                                            atNormalizedPoint:normalizedPoint
                                                                                 pointOnImage:faceCenter
                                                                                         size:CGSizeMake(model.tagRect.size.width / 2, model.tagRect.size.height / 2)];
                        });
                    }
                    if ([_delegate respondsToSelector:@selector(updatePhotoInfos:photoAtIndex:)]) {
                        [_delegate updatePhotoInfos:array photoAtIndex:_currentPageIndex];
                    }
                }
            }];
        });
    }
}

#pragma mark - Properties

- (void)setCurrentPhotoIndex:(NSUInteger)index {
    // Validate
    NSUInteger photoCount = [self numberOfPhotos];
    if (photoCount == 0) {
        index = 0;
    } else {
        if (index >= photoCount)
            index = [self numberOfPhotos]-1;
    }
    _currentPageIndex = index;
    if ([self isViewLoaded]) {
        [self jumpToPageAtIndex:index animated:NO];
        if (!_viewIsActive)
            [self tilePages]; // Force tiling if view is not visible
    }
}

#pragma mark - Misc

- (void)doneButtonPressed:(id)sender {
    if (_doneButton) {
        if (_senderViewForAnimation && _currentPageIndex == _initalPageIndex) {
            TFZoomingScrollView *scrollView = [self pageDisplayedAtIndex:_currentPageIndex];
            [self performCloseAnimationWithScrollView:scrollView];
        }
        else {
            _senderViewForAnimation.hidden = NO;
            [self prepareForClosePhotoBrowser];
            [self dismissPhotoBrowserAnimated:YES];
        }
    }
}

- (void)backButtonPressed:(id)sender {
    // Only if we're modal and there's a done button
    if (_backButton) {
        if (_senderViewForAnimation && _currentPageIndex == _initalPageIndex) {
            TFZoomingScrollView *scrollView = [self pageDisplayedAtIndex:_currentPageIndex];
            [self performCloseAnimationWithScrollView:scrollView];
        }
        else {
            _senderViewForAnimation.hidden = NO;
            [self prepareForClosePhotoBrowser];
            [self dismissPhotoBrowserAnimated:YES];
        }
    }
}

#pragma mark - Actions

- (void)actionButtonPressed:(id)sender {
    
}

- (void)updateImageTagInfo:(TFPhotoTag *)model {
    NSMutableArray *array = [_tagInfos objectAtIndex:_currentPageIndex];
    if ([array isKindOfClass:[NSNull class]]) {
        //当前为空
        array = [NSMutableArray array];
        [array addObject:model];
    }
    else {
        //检查是否相同位置存在
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[TFPhotoTag class]]) {
                TFPhotoTag *oldModel = (TFPhotoTag *)obj;
                if (![oldModel.faceId isEqualToString:model.faceId]) {
                    [array addObject:model];
                    *stop = YES;
                }
                else {
                    NSLog(@"array already have tag model:%@",model.tagId);
                    //                    *stop = YES;
                }
            }
        }];
    }
    [_tagInfos replaceObjectAtIndex:_currentPageIndex withObject:array];
    if ([_delegate respondsToSelector:@selector(photoBrowser:infos:)]) {
        [_delegate photoBrowser:self infos:_tagInfos];
    }
}

#pragma mark TFPhotoTagViewDelegate

- (void)tagDidAppear:(TFPhotoTagView *)tagPopover {
    
}

- (void)tagPopoverDidEndEditing:(TFPhotoTagView *)tagPopover {

    CGRect rect = CGRectMake(tagPopover.pointOnImage.x, tagPopover.pointOnImage.y, tagPopover.sizeOnImage.width, tagPopover.sizeOnImage.height);
    TFPhotoTag *model = [TFPhotoTag photoTagWithRect:rect tagId:tagPopover.tagId tagName:tagPopover.text];
    [self updateImageTagInfo:model];
}
- (void)tagPopover:(TFPhotoTagView *)tagPopover didReceiveSingleTap:(UITapGestureRecognizer *)singleTap {
    
    //点击tagview，跳转页面
    if ([_delegate respondsToSelector:@selector(photoBrowser:didSelectTagAtIndex:tagId:)]) {
        UIViewController *viewController = [self.delegate photoBrowser:self
                                                   didSelectTagAtIndex:_currentPageIndex
                                                                 tagId:tagPopover.tagId];
        [self presentViewController:viewController animated:YES completion:nil];
        _currentTagView = tagPopover;
        _editPoint = tagPopover.pointOnImage;
    }
    

}

- (void)tagPopover:(TFPhotoTagView *)tagPopover didReceiveLongTap:(UITapGestureRecognizer *)longTap {
    //删除tag
    POPBasicAnimation *opacityAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacityAnimation.toValue = @(0);
    [opacityAnimation setCompletionBlock:^(POPAnimation *animation, BOOL finish) {
        if (finish) {
            [tagPopover removeFromSuperview];
        }
    }];
    [tagPopover.layer pop_addAnimation:opacityAnimation forKey:@"opacityAnimation"];
    
    NSMutableArray *array = [_tagInfos objectAtIndex:_currentPageIndex];
    if (![array isKindOfClass:[NSNull class]]) {
        //删除本地tag数据
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[TFPhotoTag class]]) {
                TFPhotoTag *model = (TFPhotoTag *)obj;
                if ([model.tagName isEqualToString:tagPopover.text]) {
                    [array removeObject:model];
                }
            }
        }];
    }
}



@end
