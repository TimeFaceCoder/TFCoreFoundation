//
//  UIButton+TFCameraButton.h
//  TFCamera
//
//  Created by Melvin on 7/20/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (TFCameraButton)

+ (UIButton*) tfcCreateButtonWithFrame:(CGRect)frame
                                target:(id)target
                              selector:(SEL)selector
                                 image:(NSString *)image
                          imagePressed:(NSString *)imagePressed;

+ (UIButton *) tfcCreateButtonWithImage:(NSString *)image
                           imagePressed:(NSString *)imagePressed
                                 target:(id)target
                               selector:(SEL)selector;

+ (UIButton *) tfcCreateButtonWithFrame:(CGRect)frame
                                  title:(NSString *)title
                                 target:(id)target
                               selector:(SEL)selector;

+ (UIButton *) tfcCreateButtonWithTitle:(NSString *)title
                                 target:(id)target
                               selector:(SEL)selector;

- (void)tfcUpdateButtonImage:(NSString *)image
                imagePressed:(NSString *)imagePressed;

@end
