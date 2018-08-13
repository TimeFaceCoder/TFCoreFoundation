//
//  YYImage+TFCore.h
//  TFCoreFoundation
//
//  Created by Melvin on 4/11/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <YYImage/YYImage.h>
NS_ASSUME_NONNULL_BEGIN
UIKIT_EXTERN NSString * const kTFDefaultLaunchImageSetName;
@interface YYImage (TFCore)

+ (instancetype)defaultLaunchImage;
+ (instancetype)launchImageNamed:(NSString *)name;

@end
NS_ASSUME_NONNULL_END
