//
//  UIImage+TFAspectDraw.m
//  TFPhotoBrowser
//
//  Created by Melvin on 2/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "UIImage+TFAspectDraw.h"

@implementation UIImage (TFAspectDraw)

- (void)tf_drawInRectWithAspectFill:(CGRect)rect {
    float hfactor = self.size.width / rect.size.width;
    float vfactor = self.size.height / rect.size.height;
    
    float factor = fmin(hfactor, vfactor);
    
    CGRect newRect = rect;
    newRect.size.width = self.size.width / factor;
    newRect.size.height = self.size.height / factor;
    newRect.origin.x -= (newRect.size.width - rect.size.width) / 2.0;
    newRect.origin.y -= (newRect.size.height - rect.size.height) / 2.0;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextClipToRect(context, rect);
    [self drawInRect:newRect];
    CGContextRestoreGState(context);
}

@end
