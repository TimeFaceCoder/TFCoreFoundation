//
//  UIScreen+TFCore.h
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface UIScreen (TFCore)
+ (CGFloat)screenScale;
- (CGRect)currentBounds NS_EXTENSION_UNAVAILABLE_IOS("");
- (CGRect)boundsForOrientation:(UIInterfaceOrientation)orientation;
@property (nonatomic, readonly) CGSize sizeInPixel;
@property (nonatomic, readonly) CGFloat pixelsPerInch;

@end
NS_ASSUME_NONNULL_END