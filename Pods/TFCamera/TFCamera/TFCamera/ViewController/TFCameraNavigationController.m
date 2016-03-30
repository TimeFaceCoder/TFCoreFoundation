//
//  TFCameraNavigationController.m
//  TFCamera
//
//  Created by Melvin on 7/17/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "TFCameraNavigationController.h"
#import "TFCameraNavigationController.h"
#import "TFCameraViewController.h"
@import AVFoundation;

@interface TFCameraNavigationController ()

- (void)setupAuthorizedWithDelegate:(id<TFCameraDelegate>)delegate;
- (void)setupDenied;
- (void)setupNotDeterminedWithDelegate:(id<TFCameraDelegate>)delegate;

@end

@implementation TFCameraNavigationController

+ (instancetype)newWithCameraDelegate:(id<TFCameraDelegate>)delegate
{
    TFCameraNavigationController *navigationController = [super new];
    navigationController.navigationBarHidden = YES;
    
    if (navigationController) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        switch (status) {
            case AVAuthorizationStatusAuthorized:
                [navigationController setupAuthorizedWithDelegate:delegate];
                break;
                
            case AVAuthorizationStatusRestricted:
            case AVAuthorizationStatusDenied:
                [navigationController setupDenied];
                break;
                
            case AVAuthorizationStatusNotDetermined:
                [navigationController setupNotDeterminedWithDelegate:delegate];
                break;
        }
    }
    
    return navigationController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -
#pragma mark - Private methods

- (void)setupAuthorizedWithDelegate:(id<TFCameraDelegate>)delegate
{
    TFCameraViewController *viewController = [TFCameraViewController new];
    viewController.delegate = delegate;
    
    self.viewControllers = @[viewController];
}

- (void)setupDenied
{
//    UIViewController *viewController = [TFCameraAuthorizationViewController new];
//    self.viewControllers = @[viewController];
}

- (void)setupNotDeterminedWithDelegate:(id<TFCameraDelegate>)delegate
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            [self setupAuthorizedWithDelegate:delegate];
        } else {
            [self setupDenied];
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

@end
