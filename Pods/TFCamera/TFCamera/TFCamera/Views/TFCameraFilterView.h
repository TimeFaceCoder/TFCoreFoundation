//
//  TFCameraFilterView.h
//  TFCamera
//
//  Created by Melvin on 7/17/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TFCameraFilterView : UIView

- (void)addToView:(UIView *)view aboveView:(UIView *)aboveView;
- (void)removeFromSuperviewAnimated;

@end
