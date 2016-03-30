//
//  TFAsset.m
//  TFPhotoBrowser
//
//  Created by Melvin on 12/17/15.
//  Copyright © 2015 TimeFace. All rights reserved.
//

#import "TFAsset.h"
#import <CommonCrypto/CommonDigest.h>



@interface TFAsset()

@property (nonatomic, strong) ALAsset        *alAsset;
@property (nonatomic, strong) PHAsset        *phAsset;
@property (nonatomic, assign) NSInteger      dateTimeInteger;// yyyyMMddHH < long max:2147483647
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, strong) NSString       *fileExtension;
@property (nonatomic, assign) BOOL           isPHAsset;

// Properties (ALAsset or PHAsset)
@property (nonatomic, strong) NSURL          *url;
@property (nonatomic, strong) NSString       *localIdentifier;
@property (nonatomic, assign) PHImageRequestID imageRequestID;
@property (nonatomic, strong) NSString       *md5;
@property (nonatomic, strong) CLLocation     *location;
@property (nonatomic, strong) NSDate         *date;
@property (nonatomic, assign) TFAssetType    type;
@property (nonatomic, assign) double         duration;

@property (nonatomic, assign) CGSize thumbnailSize;
@property (nonatomic, assign) CGSize fullScreenSize;
@property (nonatomic, assign) BOOL   alreadyRequest;

@property (nonatomic, assign) ALAssetsLibrary *libary;

@end
@implementation TFAsset
#pragma mark -
#pragma mark Privates (Date formatter)
static NSDateFormatter          *_dateFormatter       = nil;
static PHCachingImageManager    *_cachingImageManager = nil;
static PHImageRequestOptions    *_imageRequestOptions = nil;
+ (void)_setupDateFormatter {
    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [_dateFormatter setDateFormat:@"yyyyMMddHH"];
}
+ (void)_setupImageManager {
    _cachingImageManager = [[PHCachingImageManager alloc] init];
}

+ (void)_setupImageRequestOptions {
    _imageRequestOptions = [[PHImageRequestOptions alloc] init];
    _imageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    _imageRequestOptions.synchronous = YES;
    _imageRequestOptions.networkAccessAllowed = YES;
}

-(ALAssetsLibrary *)libary {
    if(!_libary) {
        _libary = [[ALAssetsLibrary alloc]init];
    }
    return _libary;
}

#pragma mark -
#pragma mark Basics
- (id)initWithALAsset:(ALAsset *)asset {
    self = super.init;
    if (self) {
        self.isPHAsset = NO;
        self.alAsset = asset;
        [self initProperty];
    }
    return self;
}
- (id)initWithPHAsset:(PHAsset *)asset {
    self = super.init;
    if (self) {
        self.isPHAsset = YES;
        self.phAsset = asset;
        [self initProperty];
    }
    return self;
}

- (void)initProperty {
    NSDate* date = self.date;
    self.dateTimeInteger = [_dateFormatter stringFromDate:date].integerValue;
    if (self.dateTimeInteger < 1900000000) {
        self.dateTimeInteger += 1900000000;
    }
    self.timeInterval = date.timeIntervalSince1970;
    self.type = TFAssetTypeUnInitiliazed;
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    _fullScreenSize = CGSizeMake(CGRectGetWidth([[UIScreen mainScreen] bounds]) *scale, CGRectGetHeight([[UIScreen mainScreen] bounds]) *scale);
    
    _thumbnailSize = CGSizeMake(240, 240);
    
    _alreadyRequest = NO;
}

+ (void)initialize {
    [self _setupDateFormatter];
    [self _setupImageManager];
    [self _setupImageRequestOptions];
}

- (NSComparisonResult)compare:(TFAsset *)asset {
    if (_timeInterval > asset.timeInterval) {
        return (NSComparisonResult)NSOrderedDescending;
    } if (_timeInterval < asset.timeInterval) {
        return (NSComparisonResult)NSOrderedAscending;
    } else {
        return (NSComparisonResult)NSOrderedSame;
    }
}

- (BOOL)isEqual:(TFAsset *)asset {
    if (asset == self) {
        return YES;
    }
    if (!asset || ![asset isKindOfClass:self.class]) {
        return NO;
    }
    if (self.isPHAsset) {
        return [self.localIdentifier isEqual:asset.localIdentifier];
    }
    else {
        return [self.url isEqual:asset.url];
    }
}

- (NSUInteger)hash {
    if (self.isPHAsset) {
        return [self.localIdentifier hash];
    }
    else {
        return [self.url hash];
    }
}


#pragma mark -
#pragma mark Properties (Status)
- (BOOL)deleted {
    if (self.isPHAsset) {
        return (self.phAsset.localIdentifier == nil);
    }
    else {
        return (self.alAsset.defaultRepresentation == nil);
    }
    return NO;
}

#pragma mark -
#pragma mark Properties (Image)
- (UIImage*)thumbnail {
    __block UIImage *image = nil;
    if (self.isPHAsset) {
        [_cachingImageManager requestImageForAsset:self.phAsset
                                        targetSize:self.thumbnailSize
                                       contentMode:PHImageContentModeAspectFill
                                           options:_imageRequestOptions
                                     resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                         image = result;
                                     }];
    }
    else {
        image =  [UIImage imageWithCGImage:self.alAsset.thumbnail];
    }
    return image;
}

- (UIImage*)fullScreenImage {
    __block UIImage *image = nil;
    if (self.isPHAsset) {
        [_cachingImageManager requestImageForAsset:self.phAsset
                                        targetSize:self.fullScreenSize
                                       contentMode:PHImageContentModeAspectFill
                                           options:_imageRequestOptions
                                     resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                         image = result;
                                     }];
    }
    else {
        ALAssetRepresentation* rep = self.alAsset.defaultRepresentation;
        if (rep) {
            image = [UIImage imageWithCGImage:rep.fullScreenImage
                                        scale:rep.scale
                                  orientation:0];
        }
    }
    return image;
}

- (UIImage*)fullResolutionImage {
    __block UIImage *image = nil;
    if (self.isPHAsset) {
        [_cachingImageManager requestImageForAsset:self.phAsset
                                        targetSize:PHImageManagerMaximumSize
                                       contentMode:PHImageContentModeDefault
                                           options:_imageRequestOptions
                                     resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                         image = result;
                                     }];
    }
    else {
        ALAssetRepresentation* rep = self.alAsset.defaultRepresentation;
        if (rep) {
            image = [UIImage imageWithCGImage:rep.fullResolutionImage
                                        scale:rep.scale
                                  orientation:0];
        }
    }
    return image;
}


#pragma mark -
#pragma mark Properties (ALAsset)
- (NSURL*)url {
    if (_url == nil) {
        _url = [self.alAsset valueForProperty:ALAssetPropertyAssetURL];
    }
    return _url;
}

- (NSString *)localIdentifier {
    if (_localIdentifier == nil) {
        if (self.isPHAsset) {
            _localIdentifier = self.phAsset.localIdentifier;
        }
        else {
            _localIdentifier = [self.url absoluteString];
        }
    }
    return _localIdentifier;
}

- (NSString *)md5 {
    if (_md5 == nil) {
        if (self.isPHAsset) {
            _md5 = [self getMD5StringFromNSString:self.localIdentifier];
        }
        else {
            _md5 = [self getMD5StringFromNSString:[self.url absoluteString]];
        }
    }
    return _md5;
}

- (CLLocation*)location {
    if (_location == nil) {
        if (self.isPHAsset) {
            _location =  self.phAsset.location;
        }
        else {
            _location = [self.alAsset valueForProperty:ALAssetPropertyLocation];
        }
    }
    return _location;
}

- (double)duration {
    if (_duration == 0 && _type == TFAssetTypeVideo) {
        if (self.isPHAsset) {
            _duration =  self.phAsset.duration;
        }
        else {
            NSNumber* number = [self.alAsset valueForProperty:ALAssetPropertyDuration];
            _duration = number.doubleValue;
        }
    }
    return _duration;
}

- (NSDate*)date {
    if (_date == nil) {
        if (self.isPHAsset) {
            _date =  self.phAsset.modificationDate;
        }
        else {
            _date = [self.alAsset valueForProperty:ALAssetPropertyDate];
        }
    }
    return _date;
}

- (CGSize)size {
    if (self.isPHAsset) {
        return CGSizeMake(self.phAsset.pixelWidth, self.phAsset.pixelHeight);
    }
    else {
        return self.alAsset.defaultRepresentation.dimensions;
    }
}

- (TFAssetType)type {
    if (_type == TFAssetTypeUnInitiliazed) {
        if (self.isPHAsset) {
            switch (self.phAsset.mediaType) {
                case PHAssetMediaTypeUnknown: {
                    self.type = TFAssetTypeUnknown;
                    break;
                }
                case PHAssetMediaTypeImage: {
                    self.type = TFAssetTypePhoto;
                    break;
                }
                case PHAssetMediaTypeVideo: {
                    self.type = TFAssetTypeVideo;
                    break;
                }
                case PHAssetMediaTypeAudio: {
                    self.type = TFAssetTypeAudio;
                    break;
                }
                default: {
                    self.type = TFAssetTypeUnknown;
                    break;
                }
            }
        }
        else {
            NSString* typeString = [self.alAsset valueForProperty:ALAssetPropertyType];
            if ([typeString isEqualToString:ALAssetTypePhoto]) {
                self.type = TFAssetTypePhoto;
            } else if ([typeString isEqualToString:ALAssetTypeVideo]) {
                self.type = TFAssetTypeVideo;
            } else if ([typeString isEqualToString:ALAssetTypeUnknown]) {
                self.type = TFAssetTypeUnknown;
            }
        }
    }
    return _type;
}

- (NSString*)fileExtension {
    if (_fileExtension == nil) {
        if (self.isPHAsset) {
            _fileExtension = @"jpg";
            NSString * filename = [self.phAsset valueForKey:@"filename"];
            if (filename.length) {
                _fileExtension = [filename pathExtension];
            }
        }
        else {
            _fileExtension = self.url.pathExtension.lowercaseString;
        }
    }
    return [_fileExtension lowercaseString];
}

#pragma mark -
#pragma mark Properties (Attribute)
- (BOOL)isJPEG {
    NSString* fileExtension = self.fileExtension;
    return [fileExtension isEqualToString:@"jpg"] | [fileExtension isEqualToString:@"jpeg"];
}

- (BOOL)isPNG {
    return [self.fileExtension isEqualToString:@"png"];
}

- (BOOL)isVideo {
    return self.type == TFAssetTypeVideo;
}

- (BOOL)isPhoto {
    return self.type == TFAssetTypePhoto;
}

- (BOOL)isImageResultIsInCloud {
    if (_alreadyRequest) {
        return _isImageResultIsInCloud;
    }
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = YES;
    options.networkAccessAllowed = NO;
    [_cachingImageManager requestImageDataForAsset:self.phAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        _isImageResultIsInCloud = [[info objectForKey:PHImageResultIsInCloudKey] boolValue];
        _alreadyRequest = YES;
    }];
    
    
    return _isImageResultIsInCloud;
}

- (BOOL)isScreenshot {
    if (self.isPNG) {
        CGSize size = UIScreen.mainScreen.bounds.size;
        size.width *= UIScreen.mainScreen.scale;
        size.height *= UIScreen.mainScreen.scale;
        return CGSizeEqualToSize(size, self.size);
    }
    return NO;
}

- (NSString *)getMD5StringFromNSString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
    CC_MD5([data bytes], (CC_LONG)[data length], digest);
    NSMutableString *result = [NSMutableString string];
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat: @"%02x", (int)(digest[i])];
    }
    return [result copy];
}

#pragma mark -
#pragma mark APIs
+ (TFAsset*)assetFromAL:(ALAsset*)asset {
    return [[self alloc] initWithALAsset:asset];
}

+ (TFAsset*)assetFromPH:(PHAsset*)asset {
    return [[self alloc] initWithPHAsset:asset];
}

+ (TFAsset*)assetFromLocalIdentifier:(NSString *)localIdentifier {
    NSRange range = [localIdentifier rangeOfString:@"assets-library"];
    if (range.length > 0) {
        //assets-library
        __block TFAsset *tfAsset = nil;
        
        ALAssetsLibrary *libary = [[ALAssetsLibrary alloc]init];
        
        __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            [libary assetForURL:[NSURL URLWithString:localIdentifier] resultBlock:^(ALAsset *asset){
                tfAsset = [[TFAsset alloc]initWithALAsset:asset];
                
                NSLog(@"%@", tfAsset.localIdentifier);
                
                dispatch_semaphore_signal(semaphore);
            }failureBlock:^(NSError *error){
                dispatch_semaphore_signal(semaphore);
            }];
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        return tfAsset;
    }
    else {
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
        if ([fetchResult count] > 0) {
            PHAsset *asset = [fetchResult objectAtIndex:0];
            return [[self alloc] initWithPHAsset:asset];
        }
    }
    return nil;
}

#pragma mark 从iCloud下载图片

- (void)downloadImageFromiCloud:(PHAssetImageProgressHandler)progressHandler
                        finined:(DownloadImageFinined)finined {
    _imageRequestOptions.progressHandler = progressHandler;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[PHImageManager defaultManager] requestImageForAsset:self.phAsset
                                                   targetSize:PHImageManagerMaximumSize
                                                  contentMode:PHImageContentModeDefault
                                                      options:_imageRequestOptions
                                                resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info)
         {
             
             BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
             if (downloadFinined) {
                 //图片下载完成
                 weakSelf.isImageResultIsInCloud = NO;
                 weakSelf.imageRequestID = [[info objectForKey:PHImageResultRequestIDKey] intValue];
                 finined();
             }
         }];
    });
    
}





#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    _localIdentifier = [aDecoder decodeObjectForKey:@"localIdentifier"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_localIdentifier forKey:@"localIdentifier"];
}

@end
