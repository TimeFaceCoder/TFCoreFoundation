//
//  TFPhotoCaptionView.h
//  TFPhotoBrowser
//
//  Created by Melvin on 11/18/15.
//  Copyright © 2015 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFPhotoProtocol.h"

typedef NS_ENUM(NSUInteger, TFPanGestureRecognizerDirection) {
    TFPanGestureRecognizerDirectionUndefined,
    TFPanGestureRecognizerDirectionUp,
    TFPanGestureRecognizerDirectionDown,
    TFPanGestureRecognizerDirectionLeft,
    TFPanGestureRecognizerDirectionRight
};

@interface TFPhotoCaptionView : UIView

// Init
- (id)initWithPhoto:(id<TFPhoto>)photo;
- (id)initWithPhoto:(id<TFPhoto>)photo width:(CGFloat)width frame:(CGRect)frame;
- (void)setupCaption;
- (CGSize)sizeThatFits:(CGSize)size;
- (void)setupCaptionToolBarView:(UIView *)toolBarView;

@end
