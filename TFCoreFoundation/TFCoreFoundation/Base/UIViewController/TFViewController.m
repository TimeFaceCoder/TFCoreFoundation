//
//  TFViewController.m
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "TFCoreFoundationMacro.h"
#import "TFCGUtilities.h"
#import "TFDefaultStyle.h"
#import "UIBarButtonItem+TFCore.h"
#import <FLAnimatedImage/FLAnimatedImage.h>
#import <FLAnimatedImage/FLAnimatedImageView.h>

@interface TFViewController ()<TFStateViewDelegate,TFStateViewDataSource> {
    
}
@property (nonatomic ,strong) CMMotionManager *manager;
@end

@implementation TFViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView {
    if (nil != self.nibName) {
        [super loadView];
    } else {
        self.view = [[UIView alloc] initWithFrame:TFScreenBounds()];
        self.view.autoresizesSubviews = YES;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.view.backgroundColor = TFSTYLEVAR(viewBackgroundColor);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //手机敲击左手返回
    __weak __typeof(self)weakSelf = self;
    if (_manager.deviceMotionAvailable) {
        _manager.deviceMotionUpdateInterval = 0.01f;
        [_manager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                      withHandler:^(CMDeviceMotion *data, NSError *error) {
                                          if (data.userAcceleration.x < -2.5f) {
                                              NSString *classname = weakSelf.class.description;
                                              if ([classname isEqualToString:@"CircleQuickViewController"]) {
                                                  return ;
                                              }
                                              [weakSelf.navigationController popViewControllerAnimated:YES];
                                          }
                                      }];
    }
//    [self checkGuide];
}
-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_manager stopDeviceMotionUpdates];
//    [self removeGuideView];
}

- (void)dealloc {
    if (!_stateView) {
        _stateView.stateDataSource = nil;
        _stateView.stateDelegate = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!_manager) {
        _manager = [[CMMotionManager alloc] init];
    }
    if (!_requestParams) {
        _requestParams = [NSMutableDictionary dictionary];
    }
    [self showStateView:kTFViewStateLoading];
    self.navigationController.view.backgroundColor = TFSTYLEVAR(viewBackgroundColor);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLeftNavClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Public


- (TFStateView *)stateView {
    if (!_stateView) {
        _stateView = [[TFStateView alloc] initWithFrame:self.view.bounds];
        _stateView.stateDataSource = self;
        _stateView.stateDelegate = self;
        _stateView.userInteractionEnabled = YES;
    }
    return _stateView;
}

- (void)showStateView:(NSInteger)viewState {
    _viewState = viewState;
    [self.stateView showStateView];
}
- (void)removeStateView {
    [self.stateView removeStateView];
}

- (void)showBackButton {
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@""]
                                                                      selectedImage:[UIImage imageNamed:@""]
                                                                             target:self
                                                                             action:@selector(onLeftNavClick:)];
}

- (void)reloadData {
    
}

- (void)showToastMessage:(NSString *)message messageType:(TFMessageType)messageType {
    TFMainRun(^{
        
        NSDictionary *dic = @{
                              @"message"     :   message ? message : @"",
                              @"type"        :   @(messageType)
                              };
//        [self performSelector:@selector(showMessage:) withObject:dic afterDelay:.5f];
        
        [self showMessage:dic];
    });
}

- (void)showMessage:(NSDictionary*)params {
    NSString *message = [params objectForKey:@"message"];
    TFMessageType messageType  = [[params objectForKey:@"type"] integerValue];
    [SVProgressHUD setMinimumDismissTimeInterval:0.8];
    switch (messageType) {
        case TFMessageTypeDefault:
            [SVProgressHUD showWithStatus:message];
            break;
        case TFMessageTypeSuccess:
            [SVProgressHUD showSuccessWithStatus:message];
            break;
        case TFMessageTypeFaild:
            [SVProgressHUD showErrorWithStatus:message];
            break;
        default:
            [SVProgressHUD showInfoWithStatus:message];
            break;
    }
}

- (void)dismissToastView {
    TFMainRun(^{
        [SVProgressHUD dismiss];
    });
}

- (NSString *)stateViewTitle:(NSInteger)viewState {
    NSString *title = @"";
    if (viewState == kTFViewStateDataError) {
        title = TFSTYLEVAR(viewStateDataErrorTitle);
    }
    if (viewState == kTFViewStateLoading) {
        title = TFSTYLEVAR(viewStateDataLoadingTitle);
    }
    if (viewState == kTFViewStateNetError) {
        title = TFSTYLEVAR(viewStateDataNetErrorTitle);
    }
    if (viewState == kTFViewStateNoData) {
        title = TFSTYLEVAR(viewStateDataNoDataTitle);
    }
    if (viewState == kTFViewStateTimeOut) {
        title = TFSTYLEVAR(viewStateDataTimeOutTitle);
    }
    return title;
}



- (NSString *)stateViewButtonTitle:(NSInteger)viewState {
    NSString *title = @"";
    if (viewState == kTFViewStateDataError) {
        title = TFSTYLEVAR(viewStateDataErrorButtonTitle);
    }
    if (viewState == kTFViewStateLoading) {
        
    }
    if (viewState == kTFViewStateNetError) {
        
        title = TFSTYLEVAR(viewStateDataNetErrorButtonTitle);
    }
    if (viewState == kTFViewStateNoData) {
        title = TFSTYLEVAR(viewStateDataNoDataButtonTitle);
    }
    if (viewState == kTFViewStateTimeOut) {
        title = TFSTYLEVAR(viewStateDataErrorButtonTitle);
    }
    return title;
}



- (UIImage *)stateViewImage:(NSInteger)viewState {
    UIImage *image = [UIImage new];
    if (viewState == kTFViewStateDataError) {
        image =[UIImage imageNamed:TFSTYLEVAR(viewStateDataErrorImage)];
    }
    if (viewState == kTFViewStateLoading) {
    }
    if (viewState == kTFViewStateNetError) {
        image =[UIImage imageNamed:TFSTYLEVAR(viewStateDataNetErrorImage)];
    }
    if (viewState == kTFViewStateNoData) {
        image =[UIImage imageNamed:TFSTYLEVAR(viewStateDataNoDataImage)];
    }
    if (viewState == kTFViewStateTimeOut) {
        image =[UIImage imageNamed:TFSTYLEVAR(viewStateDataNetErrorImage)];
    }    return image;
}
- (UIImage*)buttonBackgroundImageForStateView:(UIView *)view forState:(UIControlState)state {
    return nil;
}

- (UIColor *)buttonBackgroundColorForStateView:(UIView *)view {
    return TFSTYLEVAR(viewStateButtonBackgroundColor);
}

- (CGSize)buttonSizeForStateView:(UIView *)view {
    return TFSTYLEVAR(viewStateButtonSize);
}

- (CGFloat)buttonCornerRadiusForStateView:(UIView *)view {
    return TFSTYLEVAR(viewStateButtonCornerRadius);
}

- (UIColor *)buttonBorderColorForStateView:(UIView *)view {
    return TFSTYLEVAR(viewStateButtonBorderColor);
}

- (CGRect)frameForStateView:(UIView *)view {
    return self.view.bounds;
}

- (CGPoint)offsetForStateView:(UIView *)view {
    return CGPointZero;
}

#pragma mark - Private

#ifdef __IPHONE_9_0
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#else
- (NSUInteger)supportedInterfaceOrientations
#endif
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}

#pragma mark - EmptyDataSetSource

- (NSAttributedString *)titleForStateView:(UIView *)view {
    
    NSDictionary *attributes = @{NSFontAttributeName:TFSTYLEVAR(loadingTextFont),
                                 NSForegroundColorAttributeName:TFSTYLEVAR(loadingTextColor)};
    
    NSString *text = [self stateViewTitle:_viewState];
    return [[NSAttributedString alloc] initWithString:text
                                           attributes:attributes];
}

- (NSAttributedString *)buttonTitleForStateView:(UIView *)view forState:(UIControlState)state {
    
    NSDictionary *attributes = @{NSFontAttributeName:TFSTYLEVAR(font16),
                                 NSForegroundColorAttributeName:TFSTYLEVAR(loadingTextColor)};
    NSString *text = [self stateViewButtonTitle:_viewState];
    return [[NSAttributedString alloc] initWithString:text
                                           attributes:attributes];
    
}

- (UIImage *)imageForStateView:(UIView *)view {
    UIImage *image = [self stateViewImage:_viewState];
    return image;
}

- (FLAnimatedImage *)animationImageForStateView:(UIView *)view {
    if (_viewState == kTFViewStateLoading) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"TFViewLoading" withExtension:@"gif"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:data];
        return image;
    }
    return nil;
}

- (UIColor *)backgroundColorForStateView:(UIView *)view {
    return TFSTYLEVAR(viewStateBackgroundColor);
}


- (CGFloat)spaceHeightForStateView:(UIView *)view {
    return TFSTYLEVAR(viewStateSpaceHeight);
}

- (void)stateViewDidTapButton:(UIView *)view {
    [self reloadData];
}

- (void)stateViewDidTapView:(UIView *)view {
    [self reloadData];
}

- (void)stateViewWillAppear:(UIView *)view {
    [UIView animateWithDuration:.25 animations:^{
        [self.view addSubview:self.stateView];
    }];
}
- (void)stateViewWillDisappear:(UIView *)view {
    [UIView animateWithDuration:.25 animations:^{
        [self.stateView removeFromSuperview];
    }];
}


#pragma mark - 页面引导


#pragma mark - Delegate

#pragma mark - TFStateViewDelegate

#pragma mark - TFStateViewDataSource

@end
