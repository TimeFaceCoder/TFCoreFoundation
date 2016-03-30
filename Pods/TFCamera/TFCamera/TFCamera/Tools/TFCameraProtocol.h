//
//  TFCameraProtocol.h
//  TFCamera
//
//  Created by Melvin on 7/30/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

@import UIKit;

@class TFMediaFileModel;
@protocol TFCameraDelegate <NSObject>

- (void)cameraDidCancel;
- (void)cameraDidSelectAlbumPhoto:(UIImage *)image;
- (void)cameraDidTakePhoto:(UIImage *)image;
- (void)cameraDidTakeMedia:(TFMediaFileModel *)mediaFile;

@optional

- (void)cameraDidSavePhotoWithError:(NSError *)error;
- (void)cameraDidSavePhotoAtPath:(NSURL *)assetURL;
- (void)cameraWillTakePhoto;

@end