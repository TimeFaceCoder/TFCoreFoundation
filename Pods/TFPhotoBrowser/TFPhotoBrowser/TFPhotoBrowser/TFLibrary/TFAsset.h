//
//  TFAsset.h
//  TFPhotoBrowser
//
//  Created by Melvin on 12/17/15.
//  Copyright © 2015 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, TFAssetType) {
    TFAssetTypeUnInitiliazed = -1,
    TFAssetTypeUnknown       =  0,
    TFAssetTypePhoto         =  1,
    TFAssetTypeVideo         =  2,
    TFAssetTypeAudio         =  3
};

typedef void (^DownloadImageFinined)();

@interface TFAsset : NSObject <NSCoding>

// Properties (Image)
@property (nonatomic, weak, readonly  ) UIImage        *thumbnail;
@property (nonatomic, weak, readonly  ) UIImage        *fullScreenImage;
@property (nonatomic, weak, readonly  ) UIImage        *fullResolutionImage;
@property (nonatomic, weak, readonly  ) NSData         *imageData;


// Properties (Date number)
@property (nonatomic, assign, readonly) NSTimeInterval timeInterval;// timeIntervalSince1970
@property (nonatomic, assign, readonly) NSInteger      dateTimeInteger;// yyyyMMddHH

// Properties (ALAsset or PHAsset property)
@property (nonatomic, strong, readonly) NSURL          *url;
@property (nonatomic, strong, readonly) NSString       *localIdentifier;
@property (nonatomic, assign, readonly) PHImageRequestID imageRequestID;
@property (nonatomic, strong, readonly) NSString       *md5;
@property (nonatomic, strong, readonly) CLLocation     *location;
@property (nonatomic, strong, readonly) NSDate         *date;
@property (nonatomic, strong, readonly) NSString       *fileExtension;// upper string JPG, PNG, ...
@property (nonatomic, assign, readonly) CGSize         size;
@property (nonatomic, assign, readonly) double         duration;// 0 if photo
@property (nonatomic, assign, readonly) TFAssetType    type;
@property (nonatomic, assign, readwrite) NSString      *objectKeyPath;

// Properties (Filter)
@property (nonatomic, assign, readonly) BOOL           isJPEG;
@property (nonatomic, assign, readonly) BOOL           isPHAsset;
@property (nonatomic, assign, readonly) BOOL           isPNG;
@property (nonatomic, assign, readonly) BOOL           isScreenshot;
@property (nonatomic, assign, readonly) BOOL           isPhoto;
@property (nonatomic, assign, readonly) BOOL           isVideo;
@property (nonatomic, assign) BOOL           isImageResultIsInCloud;




// APIs (Factories)
+ (TFAsset*)assetFromAL:(ALAsset*)asset;
+ (TFAsset*)assetFromPH:(PHAsset*)asset;


+ (TFAsset*)assetFromLocalIdentifier:(NSString *)localIdentifier;

// Exports
@property (nonatomic, strong, readonly) ALAsset* alAsset;
@property (nonatomic, strong, readonly) PHAsset* phAsset;


// Etc
- (NSComparisonResult)compare:(TFAsset*)asset;

- (void)downloadImageFromiCloud:(PHAssetImageProgressHandler)progressHandler
                        finined:(DownloadImageFinined)finined;

@end
