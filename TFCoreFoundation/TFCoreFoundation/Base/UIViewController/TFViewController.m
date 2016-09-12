//
//  TFViewController.m
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "TFCoreFoundationMacro.h"
#import "TFCGUtilities.h"
#import "TFDefaultStyle.h"
#import "UIBarButtonItem+TFCore.h"
#import "UIViewController+EmptyState.h"

@interface TFViewController () {
    
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

-(void)viewDidAppear:(BOOL)animated {
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
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_manager stopDeviceMotionUpdates];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!_manager) {
        _manager = [[CMMotionManager alloc] init];
    }
    self.navigationController.view.backgroundColor = TFSTYLEVAR(viewBackgroundColor);
    self.view.backgroundColor = TFSTYLEVAR(viewBackgroundColor);
    [self tf_showStateView:kTFViewStateNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
