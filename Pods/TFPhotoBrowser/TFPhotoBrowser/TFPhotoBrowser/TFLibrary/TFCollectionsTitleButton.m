//
//  TFCollectionsTitleButton.m
//  TFPhotoBrowser
//
//  Created by Melvin on 2/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFCollectionsTitleButton.h"

@implementation TFCollectionsTitleButton

- (CGSize)sizeThatFits:(CGSize)size {
    size = [super sizeThatFits:size];
    size.width += self.titleEdgeInsets.right + self.titleEdgeInsets.left + self.imageEdgeInsets.right + self.imageEdgeInsets.left;
    
    return size;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGRect frame = [super imageRectForContentRect:contentRect];
    frame.origin.x = CGRectGetMaxX(contentRect) - CGRectGetWidth(frame) - self.imageEdgeInsets.right + self.imageEdgeInsets.left;
    return frame;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect frame = [super titleRectForContentRect:contentRect];
    frame.origin.x = CGRectGetMinX(frame) - CGRectGetWidth([self imageRectForContentRect:contentRect]);
    return frame;
}

@end
