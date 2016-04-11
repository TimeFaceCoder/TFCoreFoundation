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
#import "TFStateView.h"
#import "TFCGUtilities.h"
#import "TFDefaultStyle.h"
#import "UIBarButtonItem+TFCore.h"
#import "UIImage+TFCore.h"
#import <FLAnimatedImage/FLAnimatedImage.h>
#import <FLAnimatedImage/FLAnimatedImageView.h>

@interface TFViewController ()<TFStateViewDelegate,TFStateViewDataSource> {
    
}
@property (nonatomic ,strong) CMMotionManager *manager;
@property (nonatomic ,strong) TFStateView *stateView;
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
    if (!_requestParams) {
        _requestParams = [NSMutableDictionary dictionary];
    }
    if (!_manager) {
        _manager = [[CMMotionManager alloc] init];
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
        [self performSelector:@selector(showMessage:) withObject:dic afterDelay:.5f];
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
        title = NSLocalizedString(@"网络数据异常", nil);
    }
    if (viewState == kTFViewStateLoading) {
        title = NSLocalizedString(@"正在加载数据", nil);
    }
    if (viewState == kTFViewStateNetError) {
        title = NSLocalizedString(@"网络连接错误", nil);
    }
    if (viewState == kTFViewStateNoData) {
        title = NSLocalizedString(@"网络数据为空", nil);
    }
    if (viewState == kTFViewStateTimeOut) {
        title = NSLocalizedString(@"网络连接超时", nil);
    }
    return title;
}

- (NSString *)stateViewButtonTitle:(NSInteger)viewState {
    NSString *title = @"";
    if (viewState == kTFViewStateDataError) {
        title = NSLocalizedString(@"重新加载", nil);
    }
    if (viewState == kTFViewStateLoading) {
    }
    if (viewState == kTFViewStateNetError) {
        title = NSLocalizedString(@"设置网络", nil);
    }
    if (viewState == kTFViewStateNoData) {
        title = NSLocalizedString(@"暂无内容", nil);
    }
    if (viewState == kTFViewStateTimeOut) {
        title = NSLocalizedString(@"重新加载", nil);
    }
    return title;
}



- (UIImage *)stateViewImage:(NSInteger)viewState {
    UIImage *image = [UIImage new];
    if (viewState == kTFViewStateDataError) {
        image =[UIImage imageNamed:NSLocalizedString(@"ViewDataError", nil)];
    }
    if (viewState == kTFViewStateLoading) {
    }
    if (viewState == kTFViewStateNetError) {
        image =[UIImage imageNamed:NSLocalizedString(@"ViewDataNetError", nil)];
    }
    if (viewState == kTFViewStateNoData) {
        image =[UIImage imageNamed:NSLocalizedString(@"ViewDataNetError", nil)];
    }
    if (viewState == kTFViewStateTimeOut) {
        image =[UIImage imageNamed:NSLocalizedString(@"ViewDataError", nil)];
    }    return image;
}
- (UIImage*)buttonBackgroundImageForStateView:(UIView *)view forState:(UIControlState)state {
    UIImage *image = [UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(236/2, 30)];
    return image;
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
    return TFSTYLEVAR(viewBackgroundColor);
}

- (CGFloat)spaceHeightForStateView:(UIView *)view {
    return 12;
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
