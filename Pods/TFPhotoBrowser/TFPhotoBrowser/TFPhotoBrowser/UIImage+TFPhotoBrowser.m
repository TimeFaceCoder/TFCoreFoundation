//
//  UIImage+TFPhotoBrowser.m
//  TFPhotoBrowser
//
//  Created by Melvin on 11/13/15.
//  Copyright © 2015 TimeFace. All rights reserved.
//

#import "UIImage+TFPhotoBrowser.h"

@implementation UIImage (TFPhotoBrowser)

+ (UIImage *)imageForResourcePath:(NSString *)path ofType:(NSString *)type inBundle:(NSBundle *)bundle {
    return [UIImage imageWithContentsOfFile:[bundle pathForResource:path ofType:type]];
}

+ (UIImage *)clearImageWithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return blank;
}

@end
