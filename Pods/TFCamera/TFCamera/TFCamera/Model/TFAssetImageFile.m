//
//  TFAssetImageFile.m
//  TFCamera
//
//  Created by Melvin on 7/16/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "TFAssetImageFile.h"

@implementation TFAssetImageFile

- (instancetype)initWithPath:(NSString *)path image:(UIImage *)image {
    self = [self init];
    
    if (self) {
        self.path = path;
        self.image = image;
    }
    return self;
}

@end
