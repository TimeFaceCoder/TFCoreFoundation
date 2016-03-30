//
//  TFAlbum.h
//  TFCamera
//
//  Created by Melvin on 7/16/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface TFAlbum : NSObject

+ (BOOL)isAvailable;

+ (UIImage *)imageWithMediaInfo:(NSDictionary *)info;
+ (UIImagePickerController *)imagePickerControllerWithDelegate:(id<UINavigationControllerDelegate, UIImagePickerControllerDelegate>)delegate;

@end
