//
//  TFDirectionalPanGestureRecognizer.h
//  TFCoreFoundation
//
//  Created by Melvin on 4/11/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, TFPanDirection) {
    TFPanDirectionRight,
    TFPanDirectionDown,
    TFPanDirectionLeft,
    TFPanDirectionUp
};
@interface TFDirectionalPanGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic) TFPanDirection direction;

@end
