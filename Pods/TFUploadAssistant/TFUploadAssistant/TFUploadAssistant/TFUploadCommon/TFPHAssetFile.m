//
//  TFPHAssetFile.m
//  TFUploadAssistant
//
//  Created by Melvin on 3/23/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFPHAssetFile.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import "TFConfiguration.h"
enum {
    kAMASSETMETADATA_PENDINGREADS = 1,
    kAMASSETMETADATA_ALLFINISHED = 0
};

@interface TFPHAssetFile () {
    BOOL _hasGotInfo;
}

@property (nonatomic) PHAsset * phAsset;

@property (readonly) int64_t fileSize;

@property (readonly) int64_t fileModifyTime;

@property (nonatomic, strong) NSData *assetData;

@property (nonatomic, strong) NSURL *assetURL;

@property (nonatomic, strong) NSDictionary *metadata;

@end

@implementation TFPHAssetFile

- (instancetype)init:(PHAsset *)phAsset error:(NSError *__autoreleasing *)error
{
    if (self = [super init]) {
        NSDate *createTime = phAsset.creationDate;
        int64_t t = 0;
        if (createTime != nil) {
            t = [createTime timeIntervalSince1970];
        }
        _fileModifyTime = t;
        _phAsset = phAsset;
        [self getInfo];
        
    }
    return self;
}

- (NSData *)read:(long)offset size:(long)size
{
    NSRange subRange = NSMakeRange(offset, size);
    if (!self.assetData) {
        self.assetData = [self fetchDataFromAsset:self.phAsset];
    }
    NSData *subData = [self.assetData subdataWithRange:subRange];
    
    return subData;
}

- (NSData *)readAll {
    if (!self.assetData) {
        self.assetData = [self fetchDataFromAsset:self.phAsset];
    }
    return self.assetData;
    return [self read:0 size:(long)_fileSize];
}

- (void)close {
}

-(NSString *)path {
    return self.assetURL.path;
}

- (NSString *)fileExtension {
    NSString *fileExtension = @"jpg";
    NSString * filename = [self.phAsset valueForKey:@"filename"];
    if (filename.length) {
        fileExtension = [filename pathExtension];
    }
    return fileExtension;
}
- (int64_t)modifyTime {
    return _fileModifyTime;
}


- (NSString *)mimeType {
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                            (__bridge CFStringRef)self.fileExtension, NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    
    NSString *mimeType = (__bridge NSString *)MIMEType;
    CFRelease(MIMEType);
    return mimeType;
}

- (int64_t)size {
    return _fileSize;
}

- (void)getInfo
{
    if (!_hasGotInfo) {
        _hasGotInfo = YES;
        
        if (PHAssetMediaTypeImage == self.phAsset.mediaType) {
            PHImageRequestOptions *request = [PHImageRequestOptions new];
            request.version = PHImageRequestOptionsVersionCurrent;
            request.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            request.resizeMode = PHImageRequestOptionsResizeModeNone;
            request.synchronous = YES;
            
            [[PHImageManager defaultManager] requestImageDataForAsset:self.phAsset
                                                              options:request
                                                        resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                                                            _fileSize = imageData.length;
                                                            _assetURL = [NSURL URLWithString:self.phAsset.localIdentifier];
                                                        }
             ];
        }
        else if (PHAssetMediaTypeVideo == self.phAsset.mediaType) {
            PHVideoRequestOptions *request = [PHVideoRequestOptions new];
            request.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
            request.version = PHVideoRequestOptionsVersionCurrent;
            
            NSConditionLock* assetReadLock = [[NSConditionLock alloc] initWithCondition:kAMASSETMETADATA_PENDINGREADS];
            [[PHImageManager defaultManager] requestPlayerItemForVideo:self.phAsset options:request resultHandler:^(AVPlayerItem *playerItem, NSDictionary *info) {
                AVURLAsset *urlAsset = (AVURLAsset *)playerItem.asset;
                NSNumber *fileSize = nil;
                [urlAsset.URL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:nil];
                _fileSize = [fileSize unsignedLongLongValue];
                _assetURL = urlAsset.URL;
                
                [assetReadLock lock];
                [assetReadLock unlockWithCondition:kAMASSETMETADATA_ALLFINISHED];
            }];
            [assetReadLock lockWhenCondition:kAMASSETMETADATA_ALLFINISHED];
            [assetReadLock unlock];
            assetReadLock = nil;
        }
    }
    
}

- (NSData *)fetchDataFromAsset:(PHAsset *)asset
{
    __block NSData *tmpData = [NSData data];
    
    // Image
    if (asset.mediaType == PHAssetMediaTypeImage) {
        PHImageRequestOptions *request = [PHImageRequestOptions new];
        request.version = PHImageRequestOptionsVersionCurrent;
        request.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        request.resizeMode = PHImageRequestOptionsResizeModeNone;
        request.synchronous = YES;
        
        [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                          options:request
                                                    resultHandler:
         ^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
             
             if ([TFConfiguration compressionQuality] >= 1) {
                 tmpData = [NSData dataWithData:imageData];
             }
             else {
                 CIImage *ciimage = [CIImage imageWithData:imageData];
                 NSDictionary *metaData = [[NSDictionary alloc]initWithDictionary:ciimage.properties];
                 CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData,  NULL);
                 CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
                 tmpData = [self dataFromImage:imageRef metadata:metaData mimetype:self.mimeType];
                 CFRelease(imageRef);
                 CFRelease(imageSource);
             }
         }];
    }
    // Video
    else  {
        
        PHVideoRequestOptions *request = [PHVideoRequestOptions new];
        request.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        request.version = PHVideoRequestOptionsVersionCurrent;
        
        NSConditionLock *assetReadLock = [[NSConditionLock alloc] initWithCondition:kAMASSETMETADATA_PENDINGREADS];
        
        
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset
                                                        options:request
                                                  resultHandler:
         ^(AVAsset* asset, AVAudioMix* audioMix, NSDictionary* info) {
             AVURLAsset *urlAsset = (AVURLAsset *)asset;
             NSData *videoData = [NSData dataWithContentsOfURL:urlAsset.URL];
             tmpData = [NSData dataWithData:videoData];
             
             [assetReadLock lock];
             [assetReadLock unlockWithCondition:kAMASSETMETADATA_ALLFINISHED];
         }];
        
        [assetReadLock lockWhenCondition:kAMASSETMETADATA_ALLFINISHED];
        [assetReadLock unlock];
        assetReadLock = nil;
    }
    
    return tmpData;
}

- (NSData *)dataFromImage:(CGImageRef)imageRef metadata:(NSDictionary *)metadata mimetype:(NSString *)mimetype
{
    NSMutableData *imageData = [NSMutableData data];
    
    CFMutableDictionaryRef properties = CFDictionaryCreateMutable(nil, 0,
                                                                  &kCFTypeDictionaryKeyCallBacks,  &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(properties, kCGImageDestinationLossyCompressionQuality,
                         (__bridge const void *)([NSNumber numberWithFloat:[TFConfiguration compressionQuality]]));
    
    for (NSString *key in metadata) {
        CFDictionarySetValue(properties, (__bridge const void *)key,
                             (__bridge const void *)[metadata objectForKey:key]);
    }
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)mimetype, NULL);
    CGImageDestinationRef imageDestination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageData, uti, 1, NULL);
    
    if (imageDestination == NULL) {
        TFULogDebug(@"Failed to create image destination");
        imageData = nil;
    }
    else {
        CGImageDestinationAddImage(imageDestination, imageRef, properties);
        if (CGImageDestinationFinalize(imageDestination) == NO) {
            TFULogDebug(@"Failed to finalise");
            imageData = nil;
        }
        CFRelease(imageDestination);
    }
    CFRelease(uti);
    return imageData;
}

@end
