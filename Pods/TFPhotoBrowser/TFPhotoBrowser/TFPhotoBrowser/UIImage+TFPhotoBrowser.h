//
//  UIImage+TFPhotoBrowser.h
//  TFPhotoBrowser
//
//  Created by Melvin on 11/13/15.
//  Copyright © 2015 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (TFPhotoBrowser)
+ (UIImage *)imageForResourcePath:(NSString *)path ofType:(NSString *)type inBundle:(NSBundle *)bundle;
+ (UIImage *)clearImageWithSize:(CGSize)size;
@end
