//
//  TFCameraViewController.h
//  TFCamera
//
//  Created by Melvin on 7/17/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFAlbum.h"
#import "TFAssetsLibrary.h"
#import "TFCamera.h"
#import "TFCameraNavigationController.h"

@interface TFCameraViewController : UIViewController

@property (weak) id<TFCameraDelegate> delegate;

@end
