//
//  PHCollection+TFThumbnail.m
//  TFPhotoBrowser
//
//  Created by Melvin on 2/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "PHCollection+TFThumbnail.h"
#import "UIImage+TFAspectDraw.h"
#import "PHPhotoLibrary+TFBlockObservers.h"
#import "PHImageManager+TFRequestImages.h"


#define TFMomentsIdentifier @"Moments"

#define TFPrimaryThumbnailWidth     68.0
#define TFTotalThumbnailWidth       76.0
#define TFListRows                  3.0

NS_ASSUME_NONNULL_BEGIN

@implementation PHCollection (TFThumbnail)

+ (NSCache *)_tf_thumbnailImageCache {
    static NSCache *imageCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageCache = [[NSCache alloc] init];
        imageCache.name = @"PHCollection/TFThumbnail";
        
        [[PHPhotoLibrary sharedPhotoLibrary] tf_registerChangeObserverBlock:^(PHChange *change) {
            [PHCollection tf_clearThumbnailCache];
        }];
    });
    
    return imageCache;
}

+ (NSString *)_tf_cacheKeyForOptions:(PHFetchOptions *)assetFetchOptions
{
    NSMutableString *keyString = [NSMutableString new];
    
    [keyString appendString:assetFetchOptions.predicate.predicateFormat];
    
    for (NSSortDescriptor *sortDescriptor in assetFetchOptions.sortDescriptors) {
        [keyString appendString:sortDescriptor.key];
        [keyString appendFormat:@"%d", sortDescriptor.ascending];
    }
    
    [keyString appendFormat:@"%d", assetFetchOptions.includeAllBurstAssets];
    [keyString appendFormat:@"%d", assetFetchOptions.includeHiddenAssets];
    
    return [NSString stringWithFormat:@"%lu", (unsigned long)[keyString hash]];
}

+ (void)tf_requestThumbnailForMomentsWithAssetsFetchOptions:(nullable PHFetchOptions *)assetFetchOptions completion:(void (^)(UIImage *__nullable result))resultHandler
{
    NSString *cacheKey = nil;
    if (assetFetchOptions == nil) {
        cacheKey = TFMomentsIdentifier;
    } else {
        cacheKey = [NSString stringWithFormat:@"%@/%@", TFMomentsIdentifier, [PHCollection _tf_cacheKeyForOptions:assetFetchOptions]];
    }
    
    UIImage *thumbnail = [[PHCollection _tf_thumbnailImageCache] objectForKey:cacheKey];
    if (thumbnail == nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [PHCollection _tf_requestThumbnailForMomentsWithAssetsFetchOptions:assetFetchOptions completion:^(UIImage *result) {
                if (result == nil) {
                    [[PHCollection _tf_thumbnailImageCache] setObject:[NSNull null] forKey:cacheKey];
                } else {
                    [[PHCollection _tf_thumbnailImageCache] setObject:result forKey:cacheKey];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultHandler(result);
                });
            }];
        });
    } else {
        if ([thumbnail isKindOfClass:[NSNull class]]) {
            resultHandler(nil);
        } else {
            resultHandler(thumbnail);
        }
    }
}

+ (void)_tf_requestThumbnailForMomentsWithAssetsFetchOptions:(nullable PHFetchOptions *)assetFetchOptions completion:(void (^)(UIImage *__nullable result))resultHandler
{
    CGSize assetSize = CGSizeMake(TFPrimaryThumbnailWidth, TFPrimaryThumbnailWidth);
    assetSize.width *= [UIScreen mainScreen].scale;
    assetSize.height *= [UIScreen mainScreen].scale;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    NSMutableArray *assets = [NSMutableArray new];
    PHFetchResult *moments = [PHAssetCollection fetchMomentsWithOptions:nil];
    [moments enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PHAssetCollection *moment, NSUInteger idx, BOOL *stop) {
        PHFetchResult *keyResult = [PHAsset fetchAssetsInAssetCollection:moment options:assetFetchOptions];
        
        [keyResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
            [assets addObject:asset];
            
            *stop = assets.count >= 3;
        }];
        
        *stop = assets.count >= 3;
    }];
    
    [[PHImageManager defaultManager] tf_requestImagesForAssets:assets targetSize:assetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(NSDictionary *results, NSDictionary *infos) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(TFTotalThumbnailWidth, TFTotalThumbnailWidth), NO, 0.0);
        
        for (NSInteger index = 2; index >= 0; index--) {
            CGRect assetFrame;
            assetFrame.origin.y = (2 - index) * 2.0;
            assetFrame.origin.x = index * 2.0 + 4.0;
            assetFrame.size.width = TFPrimaryThumbnailWidth - index * 4.0;
            assetFrame.size.height = TFPrimaryThumbnailWidth - index * 4.0;
            
            UIImage *image = nil;
            if (assets.count > index) {
                PHAsset *asset = assets[index];
                image = results[asset.localIdentifier];
            }
            
            if (image != nil) {
                [image tf_drawInRectWithAspectFill:assetFrame];
            }
            
            CGFloat lineWidth = 1.0 / [UIScreen mainScreen].scale;
            CGRect borderRect = CGRectInset(assetFrame, -lineWidth / 2.0, -lineWidth / 2.0);
            UIBezierPath *border = [UIBezierPath bezierPathWithRect:borderRect];
            border.lineWidth = lineWidth;
            [[UIColor whiteColor] setStroke];
            [border stroke];
        }
        
        UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        resultHandler(retImage);
    }];
}

- (void)tf_requestThumbnailWithAssetsFetchOptions:(nullable PHFetchOptions *)assetFetchOptions completion:(void (^)(UIImage *__nullable result))resultHandler
{
    NSString *cacheKey = nil;
    if (assetFetchOptions == nil) {
        cacheKey = self.localIdentifier;
    } else {
        cacheKey = [NSString stringWithFormat:@"%@/%@", self.localIdentifier, [PHCollection _tf_cacheKeyForOptions:assetFetchOptions]];
    }
    
    UIImage *thumbnail = [[PHCollection _tf_thumbnailImageCache] objectForKey:cacheKey];
    if (thumbnail == nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self _tf_requestThumbnailWithAssetsFetchOptions:assetFetchOptions completion:^(UIImage *result) {
                if (result == nil) {
                    [[PHCollection _tf_thumbnailImageCache] setObject:[NSNull null] forKey:cacheKey];
                } else {
                    [[PHCollection _tf_thumbnailImageCache] setObject:result forKey:cacheKey];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultHandler(result);
                });
            }];
        });
    } else {
        if ([thumbnail isKindOfClass:[NSNull class]]) {
            resultHandler(nil);
        } else {
            resultHandler(thumbnail);
        }
    }
}

- (void)_tf_requestThumbnailWithAssetsFetchOptions:(nullable PHFetchOptions *)assetFetchOptions completion:(void (^)(UIImage *__nullable result))resultHandler
{
    resultHandler(nil);
}

+ (void)tf_clearThumbnailCache
{
    [[PHCollection _tf_thumbnailImageCache] removeAllObjects];
}

@end


@implementation PHAssetCollection (TFThumbnail)

- (void)_tnk_requestThumbnailWithAssetsFetchOptions:(nullable PHFetchOptions *)assetFetchOptions completion:(void (^)(UIImage *__nullable result))resultHandler {
    CGSize assetSize = CGSizeMake(TFPrimaryThumbnailWidth, TFPrimaryThumbnailWidth);
    assetSize.width *= [UIScreen mainScreen].scale;
    assetSize.height *= [UIScreen mainScreen].scale;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    PHFetchResult *keyResult = [PHAsset fetchKeyAssetsInAssetCollection:self options:nil];
    if (keyResult.count <= 0) {
        PHFetchOptions *fetchOptions = [assetFetchOptions copy];
        fetchOptions.sortDescriptors = @[
                                         [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO],
                                         ];
        keyResult = [PHAsset fetchAssetsInAssetCollection:self options:fetchOptions];
    }
    
    if (keyResult.count == 0) {
        resultHandler(nil);
        return;
    }
    
    NSMutableArray *assets = [NSMutableArray new];
    for (NSUInteger i = 0; i < 3; i++) {
        if (keyResult.count > i) {
            [assets addObject:[keyResult objectAtIndex:i]];
        }
    }
    
    [[PHImageManager defaultManager] tf_requestImagesForAssets:assets targetSize:assetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(NSDictionary *results, NSDictionary *infos) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(TFTotalThumbnailWidth, TFTotalThumbnailWidth), NO, 0.0);
        
        for (NSInteger index = 2; index >= 0; index--) {
            CGRect assetFrame;
            assetFrame.origin.y = (2 - index) * 2.0;
            assetFrame.origin.x = index * 2.0 + 4.0;
            assetFrame.size.width = TFPrimaryThumbnailWidth - index * 4.0;
            assetFrame.size.height = TFPrimaryThumbnailWidth - index * 4.0;
            
            UIImage *image = nil;
            if (assets.count > index) {
                PHAsset *asset = assets[index];
                image = results[asset.localIdentifier];
            }
            
            if (image != nil) {
                [image tf_drawInRectWithAspectFill:assetFrame];
            }
            
            CGFloat lineWidth = 1.0 / [UIScreen mainScreen].scale;
            CGRect borderRect = CGRectInset(assetFrame, -lineWidth / 2.0, -lineWidth / 2.0);
            UIBezierPath *border = [UIBezierPath bezierPathWithRect:borderRect];
            border.lineWidth = lineWidth;
            [[UIColor whiteColor] setStroke];
            [border stroke];
        }
        
        UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        resultHandler(retImage);
    }];
}

@end


@implementation PHCollectionList (TFThumbnail)

- (NSArray<PHAsset *> *)_tf_keyAssets {
    PHFetchResult *collections = [PHCollection fetchCollectionsInCollectionList:self options:nil];
    NSMutableArray *assets = [NSMutableArray new];
    
    [collections enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger index, BOOL *stop) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHFetchResult *keyResult = [PHAsset fetchKeyAssetsInAssetCollection:collection options:nil];
            if (keyResult.count <= 0) {
                keyResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
            }
            
            PHAsset *asset = keyResult.firstObject;
            [assets addObject:asset];
        }
        
        if (assets.count >= TFListRows * TFListRows) {
            *stop = YES;
        }
    }];
    
    return assets;
}

- (void)_tnk_requestThumbnailWithAssetsFetchOptions:(nullable PHFetchOptions *)assetFetchOptions completion:(void (^)(UIImage *__nullable result))resultHandler {
    CGFloat individualWidth = (TFPrimaryThumbnailWidth - TFListRows + 1.0) / TFListRows;
    CGSize assetSize = CGSizeMake(individualWidth, individualWidth);
    assetSize.width *= [UIScreen mainScreen].scale;
    assetSize.height *= [UIScreen mainScreen].scale;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    
    NSArray *assets = [self _tf_keyAssets];
    
    [[PHImageManager defaultManager] tf_requestImagesForAssets:assets targetSize:assetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(NSDictionary *results, NSDictionary *infos) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(TFTotalThumbnailWidth, TFTotalThumbnailWidth), NO, 0.0);
        //        CGContextRef context = UIGraphicsGetCurrentContext();
        
        NSUInteger assetIndex = 0;
        
        for (NSUInteger row = 0; row < 3; row++) {
            for (NSUInteger column = 0; column < 3; column++) {
                CGRect assetFrame;
                assetFrame.size.width = (TFPrimaryThumbnailWidth - TFListRows + 1.0) / TFListRows;
                assetFrame.size.height = assetFrame.size.width;
                assetFrame.origin.y = row * (assetFrame.size.height + 1.0) + 4.0;
                assetFrame.origin.x = column * (assetFrame.size.width + 1.0) + 4.0;
                
                UIImage *image = nil;
                if (assets.count > assetIndex) {
                    PHAsset *asset = assets[assetIndex];
                    image = results[asset.localIdentifier];
                }
                
                if (image != nil) {
                    [image tf_drawInRectWithAspectFill:assetFrame];
                } else {
                    [[UIColor colorWithRed:0.921 green:0.921 blue:0.946 alpha:1.000] setFill];
                    [[UIBezierPath bezierPathWithRect:assetFrame] fill];
                }
                
                assetIndex++;
            }
        }
        
        UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        resultHandler(retImage);
    }];
}

@end

NS_ASSUME_NONNULL_END
