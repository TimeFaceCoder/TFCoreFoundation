//
//  PHCollection+TFThumbnail.h
//  TFPhotoBrowser
//
//  Created by Melvin on 2/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PHCollection (TFThumbnail)

+ (void)tf_requestThumbnailForMomentsWithAssetsFetchOptions:(nullable PHFetchOptions *)assetFetchOptions completion:(void (^)(UIImage *__nullable result))resultHandler;
- (void)tf_requestThumbnailWithAssetsFetchOptions:(nullable PHFetchOptions *)assetFetchOptions completion:(void (^)(UIImage *__nullable result))resultHandler;
+ (void)tf_clearThumbnailCache;

@end

NS_ASSUME_NONNULL_END
