//
//  ViewController.m
//  TFCoreFoundation
//
//  Created by Melvin on 3/30/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self removeStateView];
//    [self tf_showStateView:kTFViewStateDataError];
//    [self setViewState:kTFViewStateNetError];
    // Do any additional setup after loading the view, typically from a nib.
  
}

- (NSArray*)titlesForViewControllers {
    return @[@"VCA",@"VCBCCCCBBBB",@"VCC",@"VCBCCCCBBBB",@"VCC",@"VCBCCCCBBBB",@"VCC",@"VCBCCCCBBBB",@"VCC"];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    UIViewController* vc = [[UIViewController alloc]init];
    if (index==0) {
        vc.view.backgroundColor = [UIColor redColor];
    }
    else {
        vc.view.backgroundColor = [UIColor colorWithRed:arc4random() % 255/255.0f green:arc4random() % 255/255.0f blue:arc4random() % 255/255.0f alpha:1];
    }
    return vc;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
