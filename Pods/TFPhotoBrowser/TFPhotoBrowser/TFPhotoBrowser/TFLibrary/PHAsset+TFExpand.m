//
//  PHAsset+TFExpand.m
//  TFPhotoBrowser
//
//  Created by Melvin on 2/17/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "PHAsset+TFExpand.h"


@implementation PHAsset (TFExpand)

#pragma mark Public methods

-(void)saveToAlbum:(NSString*)title completionBlock:(PHAssetBoolBlock)completionBlock{
    void (^saveAssetCollection)(PHAssetCollection *assetCollection) = ^(PHAssetCollection *assetCollection){
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *changeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
            [changeRequest addAssets:@[self]];
        } completionHandler:^(BOOL success, NSError *error) {
            if(success == NO) {
                NSLog(@"Failed to add PHAsset to album: %@ error: %@", title, error.localizedDescription);
            }
            return completionBlock(success);
        }];
    };
    
    PHAssetCollection *assetCollection = [self albumWithTitle:title];
    if(assetCollection){
        // Album exists
        saveAssetCollection(assetCollection);
    } else {
        // Need to create album before saving
        // Create new album (will create duplicates)
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
        } completionHandler:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"Error creating album: %@", error);
            } else {
                PHAssetCollection *assetCollection = [self albumWithTitle:title];
                saveAssetCollection(assetCollection);
            }
        }];
    }
}

-(void)requestMetadataWithCompletionBlock:(PHAssetMetadataBlock)completionBlock{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHContentEditingInputRequestOptions *editOptions = [[PHContentEditingInputRequestOptions alloc]init];
        editOptions.networkAccessAllowed = YES;
        [self requestContentEditingInputWithOptions:editOptions completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *info) {
            CIImage *image = [CIImage imageWithContentsOfURL:contentEditingInput.fullSizeImageURL];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(image.properties);
            });
        }];
    });
}

-(void)updateLocation:(CLLocation*)location creationDate:(NSDate*)creationDate completionBlock:(PHAssetBoolBlock)completionBlock{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest changeRequestForAsset:self];
        if(location) assetRequest.location = location;
        if(creationDate) assetRequest.creationDate = creationDate;
    } completionHandler:^(BOOL success, NSError *error) {
        if(success){
            completionBlock(YES);
        } else {
            completionBlock(NO);
        }
    }];
}


+(void)saveImageToCameraRoll:(UIImage*)image location:(CLLocation*)location completionBlock:(PHAssetAssetBoolBlock)completionBlock{
    __block PHObjectPlaceholder *placeholderAsset = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *newAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        newAssetRequest.location = location;
        newAssetRequest.creationDate = [NSDate date];
        placeholderAsset = newAssetRequest.placeholderForCreatedAsset;
    } completionHandler:^(BOOL success, NSError *error) {
        if(success){
            PHAsset *asset = [self getAssetFromlocalIdentifier:placeholderAsset.localIdentifier];
            completionBlock(asset, YES);
        } else {
            completionBlock(nil, NO);
        }
    }];
}

+(void)saveVideoAtURL:(NSURL*)url location:(CLLocation*)location completionBlock:(PHAssetAssetBoolBlock)completionBlock{
    __block PHObjectPlaceholder *placeholderAsset = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *newAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
        newAssetRequest.location = location;
        newAssetRequest.creationDate = [NSDate date];
        placeholderAsset = newAssetRequest.placeholderForCreatedAsset;
    } completionHandler:^(BOOL success, NSError *error) {
        if(success){
            PHAsset *asset = [self getAssetFromlocalIdentifier:placeholderAsset.localIdentifier];
            completionBlock(asset, YES);
        } else {
            completionBlock(nil, NO);
        }
    }];
}

#pragma mark Private helpers

-(PHAssetCollection*)albumWithTitle:(NSString*)title{
    // Check if album exists. If not, create it.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localizedTitle = %@", title];
    PHFetchOptions *options = [[PHFetchOptions alloc]init];
    options.predicate = predicate;
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:options];
    if(result.count){
        return result[0];
    }
    return nil;
    
}

+(PHAsset*)getAssetFromlocalIdentifier:(NSString*)localIdentifier{
    if(localIdentifier == nil){
        NSLog(@"Cannot get asset from localID because it is nil");
        return nil;
    }
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
    if(result.count){
        return result[0];
    }
    return nil;
}

#pragma mark -
#pragma mark Privates (Date formatter)
static PHCachingImageManager    *_cachingImageManager = nil;
static PHImageRequestOptions    *_imageRequestOptions = nil;

+ (void)_setupImageManager {
    _cachingImageManager = [[PHCachingImageManager alloc] init];
}

+ (void)_setupImageRequestOptions {
    _imageRequestOptions = [[PHImageRequestOptions alloc] init];
    _imageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    _imageRequestOptions.synchronous = YES;
    _imageRequestOptions.networkAccessAllowed = YES;
}


+ (void)initialize {
    [super initialize];
    [self _setupImageManager];
    [self _setupImageRequestOptions];
}


#pragma mark -
#pragma mark Properties (Image)
- (UIImage*)thumbnail {
    __block UIImage *image = nil;
    [_cachingImageManager requestImageForAsset:self
                                    targetSize:CGSizeMake(240, 240)
                                   contentMode:PHImageContentModeAspectFill
                                       options:_imageRequestOptions
                                 resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                     image = result;
                                 }];
    
    return image;
}

- (UIImage*)fullScreenImage {
    __block UIImage *image = nil;
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGSize fullScreenSize = CGSizeMake(CGRectGetWidth([[UIScreen mainScreen] bounds]) *scale, CGRectGetHeight([[UIScreen mainScreen] bounds]) *scale);
    [_cachingImageManager requestImageForAsset:self
                                    targetSize:fullScreenSize
                                   contentMode:PHImageContentModeAspectFill
                                       options:_imageRequestOptions
                                 resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                     image = result;
                                 }];
    
    return image;
}

- (UIImage*)fullResolutionImage {
    __block UIImage *image = nil;
    [_cachingImageManager requestImageForAsset:self
                                    targetSize:PHImageManagerMaximumSize
                                   contentMode:PHImageContentModeDefault
                                       options:_imageRequestOptions
                                 resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                     image = result;
                                 }];
    
    return image;
}

- (NSString*)fileExtension {
    NSString *fileExtension = @"jpg";
    NSString *filename = [self valueForKey:@"filename"];
    if (filename.length) {
        fileExtension = [filename pathExtension];
    }
    return [fileExtension lowercaseString];
}

- (NSString *)md5 {
    NSString *md5 = nil;
    
    return md5;
}

@end
