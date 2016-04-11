//
//  TFNavigationBar.m
//  TFCoreFoundation
//
//  Created by Melvin on 4/11/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFNavigationBar.h"
#import "TFCoreFoundationMacro.h"
#import "TFDefaultStyle.h"
#import "UIView+TFCore.h"

@interface TFNavigationBar ()

@property (nonatomic, strong) UIImageView   *colorOverly;

@end

@implementation TFNavigationBar

static CGFloat const kSpaceToCoverStatusBars = 20.0f;

- (void)setBarBgColor:(UIColor *)color {
    
    Class clazz=NSClassFromString(@"_UINavigationBarBackground");
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:clazz]) {
            view.hidden=YES;
            break;
        }
    }
    
    [self insertSubview:self.colorOverly atIndex:0];
    
    
    UIGraphicsBeginImageContext(CGSizeMake(2, 2));
    [color set];
    UIRectFill(CGRectMake(0, 0, 2, 2));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _colorOverly.image = [image stretchableImageWithLeftCapWidth:1 topCapHeight:1];
    _colorOverly.alpha = .9;
}

- (UIImageView *)colorOverly {
    if (!_colorOverly) {
        if (!_colorOverly) {
            _colorOverly=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tf_width, self.tf_height+kSpaceToCoverStatusBars)];
            _colorOverly.frame = CGRectMake(0, -kSpaceToCoverStatusBars, self.tf_width, 64);
            _colorOverly.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        }
    }
    return _colorOverly;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
