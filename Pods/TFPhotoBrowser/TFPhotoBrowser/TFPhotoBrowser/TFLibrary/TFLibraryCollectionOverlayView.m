//
//  TFLibraryCollectionOverlayView.m
//  TFPhotoBrowser
//
//  Created by Melvin on 1/4/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFLibraryCollectionOverlayView.h"

@interface TFLibraryCollectionOverlayView() {
    
}
@property (nonatomic, strong) UIImageView *checkmarkView;

@end

@implementation TFLibraryCollectionOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // View settings
        
        self.backgroundColor = [UIColor clearColor];
        
        // Create a checkmark view
        UIImage *image = [UIImage imageNamed:@"TFLibraryResource.bundle/images/TFLibraryCollectionUnSelected.png"];
        CGFloat imageWidth = image.size.width;
        _checkmarkView = [[UIImageView alloc] initWithImage:image];
        _checkmarkView.highlightedImage = [UIImage imageNamed:@"TFLibraryResource.bundle/images/TFLibraryCollectionSelected.png"];
        _checkmarkView.userInteractionEnabled = NO;
        _checkmarkView.frame = CGRectMake(CGRectGetWidth(self.bounds) - 4 - imageWidth,4,  imageWidth, imageWidth);
        [self addSubview:_checkmarkView];
    }
    
    return self;
}

- (void)checkMark:(BOOL)selected {
    _checkmarkView.highlighted = selected;
}

@end
