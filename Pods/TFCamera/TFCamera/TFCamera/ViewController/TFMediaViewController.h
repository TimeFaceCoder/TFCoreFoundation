//
//  TFMediaViewController.h
//  TFCamera
//
//  Created by Melvin on 7/28/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFCamera.h"
#import "TFMediaFileModel.h"

@interface TFMediaViewController : UIViewController

+ (instancetype)newWithDelegate:(id<TFCameraDelegate>)delegate mediaFile:(TFMediaFileModel *)mediaFile;

@end
