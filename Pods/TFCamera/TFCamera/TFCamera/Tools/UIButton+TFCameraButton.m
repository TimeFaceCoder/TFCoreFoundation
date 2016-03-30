//
//  UIButton+TFCameraButton.m
//  TFCamera
//
//  Created by Melvin on 7/20/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "UIButton+TFCameraButton.h"

@implementation UIButton (TFCameraButton)

+ (UIButton*) tfcCreateButtonWithFrame:(CGRect)frame
                                target:(id)target
                              selector:(SEL)selector
                                 image:(NSString *)image
                          imagePressed:(NSString *)imagePressed {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    UIImage *newImage = [UIImage imageNamed: image];
    [button setBackgroundImage:newImage forState:UIControlStateNormal];
    UIImage *newPressedImage = [UIImage imageNamed: imagePressed];
    [button setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (UIButton *) tfcCreateButtonWithImage:(NSString *)image
                           imagePressed:(NSString *)imagePressed
                                 target:(id)target
                               selector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttomImage = [UIImage imageNamed:image];
    UIImage *buttomImageH = [UIImage imageNamed:imagePressed];
    [button setFrame:CGRectMake(0, 0, buttomImage.size.width, buttomImage.size.width)];
    [button setImage:buttomImage forState:UIControlStateNormal];
    [button setImage:buttomImageH forState:UIControlStateHighlighted];
    [button setImage:buttomImageH forState:UIControlStateSelected];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (UIButton *) tfcCreateButtonWithFrame:(CGRect)frame
                                  title:(NSString *)title
                                 target:(id)target
                               selector:(SEL)selector {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:frame];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (UIButton *) tfcCreateButtonWithTitle:(NSString *)title
                                 target:(id)target
                               selector:(SEL)selector {
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    return button;
}


- (void)tfcUpdateButtonImage:(NSString *)image
                imagePressed:(NSString *)imagePressed {
    UIImage *buttomImage = [UIImage imageNamed:image];
    UIImage *buttomImageH = [UIImage imageNamed:imagePressed];
    [self setImage:buttomImage forState:UIControlStateNormal];
    [self setImage:buttomImageH forState:UIControlStateHighlighted];
    [self setImage:buttomImageH forState:UIControlStateSelected];
}

@end
