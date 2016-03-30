//
//  TFMediaFileModel.h
//  TFCamera
//
//  Created by Melvin on 7/28/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

@import Foundation;
@import UIKit;

typedef NS_ENUM(NSInteger, TFMediaFileType) {
    TFMediaFileTypePhoto = 0,
    TFMediaFileTypeVideo
};

@interface TFMediaFileModel : NSObject

@property (nonatomic ,strong) NSString        *title;
@property (nonatomic ,strong) NSString        *desc;
@property (nonatomic ,strong) UIImage         *image;
@property (nonatomic ,strong) NSString        *path;
@property (nonatomic ,assign) TFMediaFileType fileType;

- (instancetype)initWithPath:(NSString *)path image:(UIImage *)image;
- (instancetype)initWithPath:(NSString *)path fileType:(TFMediaFileType)fileType;

@end
