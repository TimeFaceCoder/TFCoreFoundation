//
//  AutoHiddenBarViewController.m
//  TFCoreFoundation
//
//  Created by TFAppleWork-Summer on 2016/10/22.
//  Copyright © 2016年 TimeFace. All rights reserved.
//

#import "AutoHiddenBarViewController.h"
#import "UIViewController+TFCore.h"

@interface AutoHiddenBarViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation AutoHiddenBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tf_hiddenNavigationBarWhenScrollViewDidScroll = YES;
    self.tf_hiddenTabBarWhenScrollViewDidScroll = YES;
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.scrollView];
    
    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375.0, 568)];
    redView.backgroundColor = [UIColor redColor];
    [self.scrollView addSubview:redView];
    
    UIView *blueView = [[UIView alloc] initWithFrame:CGRectMake(0, 568, 375.0, 568)];
    blueView.backgroundColor = [UIColor blueColor];
    [self.scrollView addSubview:blueView];
    
    UIView *cyanView = [[UIView alloc] initWithFrame:CGRectMake(0, 1136, 375.0, 568)];
    cyanView.backgroundColor = [UIColor yellowColor];
    [self.scrollView addSubview:cyanView];

}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _scrollView.frame = self.view.bounds;
    _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height*3);
}


- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor cyanColor];
    }
    return _scrollView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
