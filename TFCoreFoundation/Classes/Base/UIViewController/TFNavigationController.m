//
//  TFNavigationController.m
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFNavigationController.h"
#import "TFCoreFoundationMacro.h"
#import "TFDirectionalPanGestureRecognizer.h"
#import "TFViewTransitionAnimator.h"
#import "TFDefaultStyle.h"
#import "TFCGUtilities.h"
#import "UIDevice+TFCore.h"
#import "UIImage+TFCore.h"

@interface TFNavigationController()<UINavigationControllerDelegate,UIGestureRecognizerDelegate> {
    
}

@property (nonatomic ,strong) TFDirectionalPanGestureRecognizer             *panRecognizer;
@property (nonatomic ,strong) UIPercentDrivenInteractiveTransition          *interactionController;


@property (nonatomic, strong) UIVisualEffectView                            *visualEffectView;
@property (nonatomic, strong) UIView                                        *fakeNavigationBarBackground;

@property (nonatomic, assign) TFNavigationControllerNavigationBarVisibility navigationBarVisibility;
@property (nonatomic, strong) UIColor                                       *originalTintColor;
@property (nonatomic ,strong) TFViewTransitionAnimator                            *animator;

@end

@implementation TFNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)init {
    self = [super init];
    if(self) {
        // Custom initialization here, if needed.
        self.delegate = self;
        _canDragBack = YES;
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super init];
    if(self) {
        
        self.delegate = self;
        _canDragBack = YES;
        self.viewControllers = @[rootViewController];
       
    }
    
    return self;
}


- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_canDragBack) {
        if (!_panRecognizer) {
            _panRecognizer = [[TFDirectionalPanGestureRecognizer alloc]
                              initWithTarget:self
                              action:@selector(paningGestureReceive:)];
            _panRecognizer.direction = TFPanDirectionRight;
            _panRecognizer.maximumNumberOfTouches = 1;
            _panRecognizer.delegate = self;
            
            [self.view addGestureRecognizer:_panRecognizer];
        }
        self.animator = [[TFViewTransitionAnimator alloc] init];
    }
    
    
    self.navigationBarVisibility = TFNavigationControllerNavigationBarVisibilitySystem;
    self.originalTintColor = [self.navigationBar tintColor];
    
    [self setNavigationBarVisibilityForController:self.topViewController animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.delegate = nil;
    _panRecognizer.delegate = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:(BOOL)animated];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (self.viewControllers.count <= 1) {
        return NO;
    }
    return YES;
}

#pragma mark - Gesture Recognizer -

- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
{
    switch (recoginzer.state) {
        case UIGestureRecognizerStateBegan: {
            if (self.viewControllers.count > 1) {
                self.interactionController = [[UIPercentDrivenInteractiveTransition alloc] init];
                [self popViewControllerAnimated:YES];
            }
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [recoginzer translationInView:self.view];
            CGFloat percent = fabs(MAX(0, translation.x) / CGRectGetWidth(self.view.bounds));
            [self.interactionController updateInteractiveTransition:percent];
        }
            break;
        case UIGestureRecognizerStateEnded: {
            CGPoint translation = [recoginzer translationInView:self.view];
            CGFloat speed = [recoginzer velocityInView:self.view].x;
            if (translation.x > self.view.frame.size.width/2 || speed > 100) {
                [self.interactionController finishInteractiveTransition];
            } else {
                [self.interactionController cancelInteractiveTransition];
            }
            self.interactionController = nil;
        }
            break;
            
        case UIGestureRecognizerStateCancelled: {
            [self.interactionController cancelInteractiveTransition];
            self.interactionController = nil;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    
    CAGradientLayer *shadow = [CAGradientLayer layer];
    shadow.frame = CGRectMake(-6, 0, 6, viewController.view.frame.size.height);
    shadow.startPoint = CGPointMake(1.0, 0.5);
    shadow.endPoint = CGPointMake(0, 0.5);
    shadow.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0 alpha:0.2f] CGColor], (id)[[UIColor clearColor] CGColor], nil];
    [viewController.view.layer addSublayer:shadow];
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
    return self.interactionController;
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPop) {
        return self.animator;
    }
    return nil;
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return self.viewControllers.count > 1 && _canDragBack;
}

#pragma mark - Accessors

- (void)setNavigationBarVisibility:(TFNavigationControllerNavigationBarVisibility)navigationBarVisibility
{
    if (_navigationBarVisibility == navigationBarVisibility) return;
    
    if (_navigationBarVisibility == TFNavigationControllerNavigationBarVisibilitySystem) {
        if (navigationBarVisibility == TFNavigationControllerNavigationBarVisibilityHidden ||
            navigationBarVisibility == TFNavigationControllerNavigationBarVisibilityVisible) {
                        [self transitionFromSystemNavigationBarToCustom];
        }
    } else if (_navigationBarVisibility == TFNavigationControllerNavigationBarVisibilityHidden ||
               _navigationBarVisibility == TFNavigationControllerNavigationBarVisibilityVisible) {
        if (navigationBarVisibility == TFNavigationControllerNavigationBarVisibilitySystem) {
                        [self transitionFromCustomNavigationBarToSystem];
        }
    }
    
    if (navigationBarVisibility == TFNavigationControllerNavigationBarVisibilityUndefined) {
        NSLog(@"Error: This should not happen: somebody tried to transition from System/Hidden/Visible state to Undefined");
    }
    
    _navigationBarVisibility = navigationBarVisibility;
    [self setNeedsStatusBarAppearanceUpdate];
}

// For iOS 8+
- (UIView *)fakeNavigationBarBackground
{
    if (!_fakeNavigationBarBackground) {
        _fakeNavigationBarBackground = [[UIView alloc] initWithFrame:self.navigationBar.frame];
        _fakeNavigationBarBackground.frame = CGRectMake(0, -20.f, self.view.frame.size.width, 64.f);
        _fakeNavigationBarBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _fakeNavigationBarBackground.userInteractionEnabled = NO;
        _fakeNavigationBarBackground.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.9f];
        
        // Shadow line
        UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 63.5f, self.view.frame.size.width, 0.5f)];
        shadowView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2f];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [_fakeNavigationBarBackground addSubview:shadowView];
    }
    
    return _fakeNavigationBarBackground;
}

// For iOS 7
- (UIVisualEffectView *)visualEffectView
{
    if (!_visualEffectView) {
        // Create a the fake navigation bar background
        //         创建需要的毛玻璃特效类型
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        //  毛玻璃view 视图
        _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _visualEffectView.frame = CGRectMake(0, -20.f, self.view.frame.size.width, 64.f);
        _visualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _visualEffectView.userInteractionEnabled = NO;
        
        // Shadow line
        UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 63.5f, self.view.frame.size.width, 0.5f)];
        shadowView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2f];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self.visualEffectView.contentView addSubview:shadowView];
    }
    
    return _visualEffectView;
}
#pragma mark - UI support

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.navigationBarVisibility == TFNavigationControllerNavigationBarVisibilityHidden) {
        return UIStatusBarStyleLightContent;
    } else {
        return TFSTYLEVAR(defalutStatusBarStyle);
    }
}

#pragma mark - Navigation Controller overrides

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
    [self setNavigationBarVisibilityForController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *viewController = [super popViewControllerAnimated:animated];
    [self setNavigationBarVisibilityForController:self.topViewController animated:animated];
    return viewController;
}

#pragma mark - Core functions

/**
 Add custom navigation bar background, and set the colors for a hideable navigation bar
 */
- (void)transitionFromSystemNavigationBarToCustom
{
    // Hide the original navigation bar's background
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.translucent = YES;
    self.navigationBar.shadowImage = [UIImage new];
    
    if (kiOS8Later) {
        [self.navigationBar addSubview:self.visualEffectView];
        [self.navigationBar sendSubviewToBack:self.visualEffectView];
    }
    else {
        [self.navigationBar addSubview:self.fakeNavigationBarBackground];
        [self.navigationBar sendSubviewToBack:self.fakeNavigationBarBackground];
    }
}

/**
 Remove custom navigation bar background, and reset to the system default
 */
- (void)transitionFromCustomNavigationBarToSystem
{
    if (kiOS8Later) {
        [self.visualEffectView removeFromSuperview];
    }
    else {
        [self.fakeNavigationBarBackground removeFromSuperview];
    }
    
    // Revert to original values
    [self.navigationBar setBackgroundImage:[[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setTranslucent:[[UINavigationBar appearance] isTranslucent]];
    [self.navigationBar setShadowImage:[[UINavigationBar appearance] shadowImage]];
    [self.navigationBar setTitleTextAttributes:[[UINavigationBar appearance] titleTextAttributes]];
    [self.navigationBar setTintColor:self.originalTintColor];
}

/**
 Determines if the given view controller conforms to GKFadeNavigationControllerDelegate or not. If conforms, asks it about the desired navigation bar visibility (visible or hidden). If it does not conform, then falls back to system navigation controller.
 
 @param viewController The view controller which will be presented
 @param animated Present using animation or instantly
 */
- (void)setNavigationBarVisibilityForController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController conformsToProtocol:@protocol(TFNavigationControllerDelegate)]) {
        self.navigationBarVisibility = (TFNavigationControllerNavigationBarVisibility)[viewController performSelector:@selector(preferredNavigationBarVisibility)];
    } else {
        self.navigationBarVisibility = TFNavigationControllerNavigationBarVisibilitySystem;
    }
    
    if (self.navigationBarVisibility == TFNavigationControllerNavigationBarVisibilityVisible ||
        self.navigationBarVisibility == TFNavigationControllerNavigationBarVisibilityHidden) {
        [self setNeedsNavigationBarVisibilityUpdateAnimated:animated];
    }
}

/**
 Show or hide the navigation custom navigation bar
 
 @param show If YES, the navigation bar will be shown. If no, it will be hidden.
 @param animated Animate the change or not
 */
- (void)showCustomNavigaitonBar:(BOOL)show withFadeAnimation:(BOOL)animated
{
    [UIView animateWithDuration:(animated ? 0.2 : 0) animations:^{
        if (show) {
            if (kiOS8Later) {
                self.visualEffectView.alpha = 1;
            } else {
                self.fakeNavigationBarBackground.alpha = 1;
            }
            self.navigationBar.tintColor = [self originalTintColor];
            self.navigationBar.titleTextAttributes = [[UINavigationBar appearance] titleTextAttributes];
        } else {
            if (kiOS8Later) {
                self.visualEffectView.alpha = 0;
            } else {
                self.fakeNavigationBarBackground.alpha = 0;
            }
            self.navigationBar.tintColor = [UIColor whiteColor];
            self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor clearColor]};
        }
    } completion:^(BOOL finished) {
        [self setNeedsStatusBarAppearanceUpdate];
        self.navigationBarVisibility = show ? TFNavigationControllerNavigationBarVisibilityVisible : TFNavigationControllerNavigationBarVisibilityHidden;
    }];
}

#pragma mark Public

- (void)setNeedsNavigationBarVisibilityUpdateAnimated:(BOOL)animated
{
    if ([self.topViewController conformsToProtocol:@protocol(TFNavigationControllerDelegate)]) {
        TFNavigationControllerNavigationBarVisibility topControllerPrefersVisibility = (TFNavigationControllerNavigationBarVisibility)[self.topViewController performSelector:@selector(preferredNavigationBarVisibility)];
        
        if (topControllerPrefersVisibility == TFNavigationControllerNavigationBarVisibilityVisible) {
            [self showCustomNavigaitonBar:YES withFadeAnimation:animated];
        } else if (topControllerPrefersVisibility == TFNavigationControllerNavigationBarVisibilityHidden) {
            [self showCustomNavigaitonBar:NO withFadeAnimation:animated];
        }
    } else {
        NSLog(@"TFNavigationController error: setNeedsNavigationBarVisibilityUpdateAnimated is called but the current topmost view controller does not conform to TFNavigationControllerDelegate protocol!");
    }
}


@end
