//
//  TFCameraGridView.h
//  TFCamera
//
//  Created by Melvin on 7/16/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TFCameraGridView : UIView

@property (nonatomic ,strong) UIColor    *lineColor;

@property (nonatomic ,assign) CGFloat    lineWidth;

@property (nonatomic ,assign) NSUInteger numberOfColumns;

@property (nonatomic ,assign) NSUInteger numberOfRows;

+ (void)disPlayGridView:(TFCameraGridView *)gridView;


@end
