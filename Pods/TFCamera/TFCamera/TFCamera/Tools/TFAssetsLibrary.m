//
//  TFAssetsLibrary.m
//  TFCamera
//
//  Created by Melvin on 7/16/15.
//  Copyright © 2015 Melvin. All rights reserved.
//

#import "TFAssetsLibrary.h"


@interface TFAssetsLibrary ()

- (void)addAssetURL:(NSURL *)assetURL toAlbum:(NSString *)albumName resultBlock:(TFAssetsResultCompletion)resultBlock failureBlock:(TFAssetsFailureCompletion)failureBlock;
- (NSString *)directory;

@end

@implementation TFAssetsLibrary

#pragma mark -
#pragma mark - Public methods

+ (TFAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static TFAssetsLibrary *library = nil;
    
    dispatch_once(&pred, ^{
        library = [[self alloc] init];
    });
    
    return library;
}

- (void)deleteFile:(TFAssetImageFile *)file
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager isDeletableFileAtPath:file.path]) {
        [fileManager removeItemAtPath:file.path error:nil];
    }
}

- (NSArray *)loadImagesFromDocumentDirectory
{
    NSString *directory = [self directory];
    
    if (directory == nil) {
        return nil;
    }
    
    NSError *error;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:&error];
    
    if (error) {
        return nil;
    }
    
    NSMutableArray *items = [NSMutableArray new];
    
    for (NSString *name in contents) {
        NSString *path = [directory stringByAppendingPathComponent:name];
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        if (data == nil) {
            continue;
        }
        
        UIImage *image = [UIImage imageWithData:data];
        TFAssetImageFile *file = [[TFAssetImageFile alloc] initWithPath:path image:image];
        [items addObject:file];
    }
    
    return items;
}

- (void)loadImagesFromAlbum:(NSString *)albumName withCallback:(TFAssetsLoadImagesCompletion)callback
{
    __block NSMutableArray *items = [NSMutableArray new];
    
    [self enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    TFAssetImageFile *file = [TFAssetImageFile new];
                    ALAssetRepresentation *representation = [result defaultRepresentation];
                    file.image = [UIImage imageWithCGImage:[representation fullScreenImage]
                                                     scale:[representation scale]
                                               orientation:0];
                    file.path = [[result.defaultRepresentation url] absoluteString];
                    [items addObject:file];
                }
                
                callback(items, nil);
            }];
        }
    } failureBlock:^(NSError *error) {
        callback(items, nil);
    }];
    
}

- (void)saveImage:(UIImage *)image resultBlock:(TFAssetsResultCompletion)resultBlock failureBlock:(TFAssetsFailureCompletion)failureBlock;
{
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    [self saveImage:image withAlbumName:appName resultBlock:resultBlock failureBlock:failureBlock];
}

- (void)saveImage:(UIImage *)image withAlbumName:(NSString *)albumName resultBlock:(TFAssetsResultCompletion)resultBlock failureBlock:(TFAssetsFailureCompletion)failureBlock;
{
//    [self writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)image.imageOrientation
//                       completionBlock:^(NSURL *assetURL, NSError *error) {
//                           if (error && failureBlock) {
//                               failureBlock(error);
//                               return;
//                           }
//                           
//                           [self addAssetURL:assetURL toAlbum:albumName resultBlock:resultBlock failureBlock:failureBlock];
//                       }];
    
    __block PHObjectPlaceholder *placeholderAsset = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *newAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        placeholderAsset = newAssetRequest.placeholderForCreatedAsset;
    } completionHandler:^(BOOL success, NSError *error) {
        if(success){
//            PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:placeholderAsset.localIdentifier options:nil];
//            if ([fetchResult count] > 0) {
//                PHAsset *asset = [fetchResult objectAtIndex:0];
//                resultBlock(
//            }else {
//                completionBlock(nil, YES);
//            }
            resultBlock([NSURL URLWithString:placeholderAsset.localIdentifier]);
            
        } else {
            failureBlock(error);
        }
    }];
    
    
}

- (void)saveJPGImageAtDocumentDirectory:(UIImage *)image resultBlock:(TFAssetsResultCompletion)resultBlock failureBlock:(TFAssetsFailureCompletion)failureBlock
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH:mm:SSSSZ"];
    
    NSString *directory = [self directory];
    
    if (!directory) {
        failureBlock(nil);
        return;
    }
    
    NSString *fileName = [[dateFormatter stringFromDate:[NSDate date]] stringByAppendingPathExtension:@"jpg"];
    NSString *filePath = [directory stringByAppendingString:fileName];
    
    if (filePath == nil) {
        failureBlock(nil);
        return;
    }
    
    NSData *data = UIImageJPEGRepresentation(image, 1);
    [data writeToFile:filePath atomically:YES];
    
    NSURL *assetURL = [NSURL URLWithString:filePath];
    
    resultBlock(assetURL);
}

- (void)latestPhotoWithCompletion:(void (^)(UIImage *photo))completion
{
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [self enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        // For this example, we're only interested in the last item [group numberOfAssets]-1 = last.
        if ([group numberOfAssets] > 0) {
            [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:[group numberOfAssets]-1] options:0
                                 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                                     // The end of the enumeration is signaled by asset == nil.
                                     if (alAsset) {
                                         ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                                         // Do something interesting with the AV asset.
                                         UIImage *img = [UIImage imageWithCGImage:[representation fullScreenImage]];
                                         
                                         // completion
                                         completion(img);
                                         
                                         // we only need the first (most recent) photo -- stop the enumeration
                                         *innerStop = YES;
                                     }
                                 }];
        }
    } failureBlock: ^(NSError *error) {
        // Typically you should handle an error more gracefully than this.
    }];
}

#pragma mark -
#pragma mark - Private methods

- (void)addAssetURL:(NSURL *)assetURL toAlbum:(NSString *)albumName resultBlock:(TFAssetsResultCompletion)resultBlock failureBlock:(TFAssetsFailureCompletion)failureBlock
{
    __block BOOL albumWasFound = NO;
    
    [self enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
            albumWasFound = YES;
            
            [self assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                [group addAsset:asset];
                
                if (resultBlock) {
                    resultBlock(assetURL);
                }
            } failureBlock:failureBlock];
            
            return;
        }
        
        if (group == nil && albumWasFound == NO) {
            __weak ALAssetsLibrary *weakSelf = self;
            
            [self addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group) {
                [weakSelf assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                    [group addAsset:asset];
                    
                    if (resultBlock) {
                        resultBlock(assetURL);
                    }
                } failureBlock:failureBlock];
            } failureBlock:failureBlock];
        }
    } failureBlock:failureBlock];
}

- (NSString *)directory
{
    NSMutableString *path = [NSMutableString new];
    [path appendString:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
    [path appendString:@"/Cache/Images/"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
        
        if (error) {
            return nil;
        }
    }
    
    return path;
}

@end
