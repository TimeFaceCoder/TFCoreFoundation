//
//  TFTapDetectingView.m
//  TFPhotoBrowser
//
//  Created by Melvin on 9/1/15.
//  Copyright © 2015 TimeFace. All rights reserved.
//

#import "TFTapDetectingView.h"

@implementation TFTapDetectingView

- (id)init {
    if ((self = [super init])) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    NSUInteger tapCount = touch.tapCount;
    switch (tapCount) {
        case 1:
            [self handleSingleTap:touch];
            break;
        case 2:
            [self handleDoubleTap:touch];
            break;
        case 3:
            [self handleTripleTap:touch];
            break;
        default:
            break;
    }
    [[self nextResponder] touchesEnded:touches withEvent:event];
}

- (void)handleSingleTap:(UITouch *)touch {
    if ([_tapDelegate respondsToSelector:@selector(view:singleTapDetected:)])
        [_tapDelegate view:self singleTapDetected:touch];
}

- (void)handleDoubleTap:(UITouch *)touch {
    if ([_tapDelegate respondsToSelector:@selector(view:doubleTapDetected:)])
        [_tapDelegate view:self doubleTapDetected:touch];
}

- (void)handleTripleTap:(UITouch *)touch {
    if ([_tapDelegate respondsToSelector:@selector(view:tripleTapDetected:)])
        [_tapDelegate view:self tripleTapDetected:touch];
}

@end
