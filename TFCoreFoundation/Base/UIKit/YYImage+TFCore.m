//
//  YYImage+TFCore.m
//  TFCoreFoundation
//
//  Created by Melvin on 4/11/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "YYImage+TFCore.h"
#import "UIDevice+TFCore.h"
#import "NSString+TFCore.h"
#import "TFCoreFoundationMacro.h"
#import "TFCGUtilities.h"
#import "UIDevice+TFCore.h"

TFSYNTH_DUMMY_CLASS(YYImage_TFCore)

NSString * const kTFDefaultLaunchImageSetName = @"LaunchImage";

@implementation YYImage (TFCore)
+ (instancetype)defaultLaunchImage {
    return [self launchImageNamed:kTFDefaultLaunchImageSetName];
}

+ (instancetype)launchImageNamed:(NSString *)name {
    NSMutableString *imageName = [NSMutableString stringWithString:name];
    
    CGFloat height = CGRectGetHeight([UIScreen mainScreen].bounds);
    
    if ([[UIDevice currentDevice] isPad]) {
        if ([self isLandscape]) {
            [imageName appendString:@"-700-Landscape"];
        } else {
            [imageName appendString:@"-700-Portrait"];
        }
        
        [imageName appendString:@"~ipad"];
    } else if (height == 568.f) {
        [imageName appendString:@"-700-568h"];
    } else if (height == 667.f) {
        [imageName appendString:@"-800-667h"];
    } else if (height == 736.f || height == 414.f) {
        if ([self isLandscape]) {
            [imageName appendString:@"-800-Landscape-736h"];
        } else {
            [imageName appendString:@"-800-Portrait-736h"];
        }
    } else {
        [imageName appendString:@"-700"];
    }
    [imageName appendString:@".png"];
    return [YYImage imageNamed:imageName];
}

+ (BOOL) isLandscape {
    return UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
}

@end
