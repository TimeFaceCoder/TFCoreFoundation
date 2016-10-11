//
//  ASDisplayNode+TFCore.h
//  TFCoreFoundation
//
//  Created by Summer on 2016/9/22.
//  Copyright © 2016年 TimeFace. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

@interface ASDisplayNode (TFCore)

/**
 * Shortcut for CGRectGetWidth(self.frame)
 *
 * Sets frame.size.width = width
 */
@property (nonatomic,assign) CGFloat tf_width;

/**
 * Shortcut for CGRectGetHeight(self.frame)
 *
 * Sets frame.size.height = height
 */
@property (nonatomic,assign) CGFloat tf_height;

/**
 * Shortcut for self.frame.size
 *
 * Sets frame.size.height = size
 */
@property (nonatomic,assign) CGSize tf_size;

/**
 * Shortcut for CGRectGetMinX(self.frame)
 *
 * Sets frame.origin.x = left
 */
@property (nonatomic,assign) CGFloat tf_left;

/**
 * Shortcut for CGRectGetMinY(self.frame)
 *
 * Sets frame.origin.y = top
 */
@property (nonatomic,assign) CGFloat tf_top;

/**
 * Shortcut for CGRectGetMaxX(self.frame)
 *
 * Sets frame.origin.x = right - CGRectGetWidth(frame);
 */
@property (nonatomic,assign) CGFloat tf_right;

/**
 * Shortcut for CGRectGetMaxY(self.frame)
 *
 * Sets frame.origin.y = bottom - CGRectGetHeight(frame)
 */
@property (nonatomic,assign) CGFloat tf_bottom;

/**
 * Shortcut for self.frame.origin
 *
 * Sets frame.origin.x = leftTop.x,frame.origin.y = leftTop.y
 */
@property (nonatomic,assign) CGPoint tf_origin;


/**
 Shortcut for 
 */
@property (nonatomic, assign) CGPoint tf_center;

/**
 * Shortcut for CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame))
 *
 * Sets frame.origin.x = rightTop.x-CGRectGetWidth(frame),frame.origin.y = rightTop.y
 */
@property (nonatomic,assign) CGPoint tf_rightTop;

/**
 * Shortcut for CGPointMake(CGRectGetMinX(frame),CGRectGetMinY(frame))
 *
 * Sets rame.origin.x = leftBottom.x,frame.origin.y = leftBottom.y + CGRectGetHeight(frame)
 */
@property (nonatomic,assign) CGPoint tf_leftBottom;

/**
 * Shortcut for CGPointMake(self.right, self.top)
 *
 * Sets frame.origin.x = rightBottom.x,rightBottom.y + CGRectGetHeight(frame)
 */
@property (nonatomic,assign) CGPoint tf_rightBottom;

/**
 * Shortcut for CGRectGetMidX(self.frame)
 *
 * Sets frame.origin.x = centerX - CGRectGetWidth(frame)/2.0
 */
@property (nonatomic,assign) CGFloat tf_centerX;

/**
 * Shortcut for CGRectGetMidY(self.frame)
 *
 * Sets frame.origin.y = centerY - CGRectGetHeight(frame)/2.0
 */
@property (nonatomic,assign) CGFloat tf_centerY;


@end
