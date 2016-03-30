//
//  TFTintedButton.m
//  TFCamera
//
//  Created by Melvin on 7/16/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "TFTintedButton.h"
#import "TFCameraColor.h"

@interface TFTintedButton ()

- (void)updateTintIfNeeded;

@end

@implementation TFTintedButton

- (void)setNeedsLayout {
    [super setNeedsLayout];
    [self updateTintIfNeeded];
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state {
    if (state != UIControlStateNormal) {
        return;
    }
    
    UIImageRenderingMode renderingMode = self.disableTint ? UIImageRenderingModeAlwaysOriginal : UIImageRenderingModeAlwaysTemplate;
    [super setBackgroundImage:[image imageWithRenderingMode:renderingMode] forState:state];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (state != UIControlStateNormal) {
        return;
    }
    UIImageRenderingMode renderingMode = self.disableTint ? UIImageRenderingModeAlwaysOriginal : UIImageRenderingModeAlwaysTemplate;
    [super setImage:[image imageWithRenderingMode:renderingMode] forState:state];
}


- (void)updateTintIfNeeded {
    UIColor *color = self.customTintColorOverride != nil ? self.customTintColorOverride : [TFCameraColor tintColor];
    
    UIImageRenderingMode renderingMode = self.disableTint ? UIImageRenderingModeAlwaysOriginal : UIImageRenderingModeAlwaysTemplate;
    
    if(self.tintColor != color) {
        [self setTintColor:color];
        
        UIImage * __weak backgroundImage = [[self backgroundImageForState:UIControlStateNormal] imageWithRenderingMode:renderingMode];
        [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        
        UIImage * __weak image = [[self imageForState:UIControlStateNormal] imageWithRenderingMode:renderingMode];
        [self setImage:image forState:UIControlStateNormal];
        
    }
}


@end
