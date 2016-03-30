//
//  TFAssetsLibrary.h
//  TFCamera
//
//  Created by Melvin on 7/16/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "TFAssetImageFile.h"

typedef void(^TFAssetsResultCompletion)(NSURL *assetURL);
typedef void(^TFAssetsFailureCompletion)(NSError* error);
typedef void(^TFAssetsLoadImagesCompletion)(NSArray *items, NSError *error);



@interface TFAssetsLibrary : ALAssetsLibrary

+ (instancetype) new __attribute__
((unavailable("[+new] is not allowed, use [+defaultAssetsLibrary]")));

- (instancetype) init __attribute__
((unavailable("[-init] is not allowed, use [+defaultAssetsLibrary]")));

+ (TFAssetsLibrary *)defaultAssetsLibrary;

- (void)deleteFile:(TFAssetImageFile *)file;

- (NSArray *)loadImagesFromDocumentDirectory;
- (void)loadImagesFromAlbum:(NSString *)albumName withCallback:(TFAssetsLoadImagesCompletion)callback;

- (void)saveImage:(UIImage *)image resultBlock:(TFAssetsResultCompletion)resultBlock failureBlock:(TFAssetsFailureCompletion)failureBlock;
- (void)saveImage:(UIImage *)image withAlbumName:(NSString *)albumName resultBlock:(TFAssetsResultCompletion)resultBlock failureBlock:(TFAssetsFailureCompletion)failureBlock;
- (void)saveJPGImageAtDocumentDirectory:(UIImage *)image resultBlock:(TFAssetsResultCompletion)resultBlock failureBlock:(TFAssetsFailureCompletion)failureBlock;

- (void)latestPhotoWithCompletion:(void (^)(UIImage *photo))completion;


@end
