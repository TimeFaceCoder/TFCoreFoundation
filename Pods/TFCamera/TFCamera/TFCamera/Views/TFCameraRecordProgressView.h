//
//  TFCameraRecordProgressView.h
//  TFCamera
//
//  Created by Melvin on 7/22/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TFCameraRecordProgressView : UIView

@property (nonatomic) CGFloat minimumWidthLimit;
@property (nonatomic) CGFloat progress;
@property (nonatomic) CGFloat progressWidth;

- (void)startRecord;
- (void)stopRecord;

- (void)insertBlockView;
@end
