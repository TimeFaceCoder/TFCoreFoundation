//
//  TFMediaFileModel.m
//  TFCamera
//
//  Created by Melvin on 7/28/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "TFMediaFileModel.h"

@implementation TFMediaFileModel

- (instancetype)initWithPath:(NSString *)path image:(UIImage *)image {
    self = [self init];
    if (self) {
        self.path  = path;
        self.image = image;
    }
    return self;
}

- (instancetype)initWithPath:(NSString *)path fileType:(TFMediaFileType)fileType {
    self = [self init];
    if (self) {
        self.path     = path;
        self.fileType = fileType;
    }
    return self;
}
@end
