//
//  TFPhotoBrowserBundle.m
//  TFPhotoBrowser
//
//  Created by Melvin on 2/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFPhotoBrowserBundle.h"
#import "TFPhotoBrowser.h"

NSBundle *TFPhotoBrowserBundle() {
    return [NSBundle bundleWithURL:[[NSBundle bundleForClass:[TFPhotoBrowser class]] URLForResource:@"TFLibraryResource" withExtension:@"bundle"]];
}

UIImage *TFPhotoBrowserImageNamed(NSString *imageName) {
    //    @"TFLibraryResource.bundle/images/"
    return [UIImage imageNamed:[@"TFLibraryResource.bundle/images/" stringByAppendingString:imageName]];
//    return [UIImage imageNamed:imageName inBundle:TFPhotoBrowserBundle() compatibleWithTraitCollection:nil];
}

NSString *TFPhotoBrowserLocalizedStrings(NSString *key) {
    NSBundle *localizedStringBundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"TFPhotoBrowserLocalizations" withExtension:@"bundle"]];
    NSString *valueStr = [localizedStringBundle localizedStringForKey:key value:@"" table:@"TFPhotoBrowserLocalString"];
    return valueStr;
}

