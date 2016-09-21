//
//  TFiCloudDownloadHelper.m
//  TFPhotoBrowser
//
//  Created by Melvin on 1/5/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFiCloudDownloadHelper.h"

@interface TFiCloudDownloadHelper() {
    
}

@property (nonatomic ,strong) NSMutableDictionary   *downloadOperations;
@property (nonatomic ,strong) PHImageRequestOptions *imageOptions;
@property (assign, nonatomic) BOOL loading;
@property (strong, nonatomic) PHAsset *asset;
@end

@implementation TFiCloudDownloadHelper

+ (instancetype)sharedHelper {
    static TFiCloudDownloadHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!helper) {
            helper = [[self alloc] init];
        }
    });
    return helper;
}

- (id)init {
    if ((self = [super init])) {
        //key phasset localIdentifier value {requestID progress}
        _downloadOperations = [NSMutableDictionary dictionary];
        
        _imageOptions = [[PHImageRequestOptions alloc] init];
        _imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        _imageOptions.synchronous = YES;
        _imageOptions.networkAccessAllowed = YES;
    }
    return self;
}


- (void)cancelImageRequest:(NSString *)localIdentifier {
    NSDictionary *entry = [_downloadOperations objectForKey:localIdentifier];
    if (entry) {
        PHImageRequestID requestID = [[entry objectForKey:@"requestID"] intValue];
        [[PHImageManager defaultManager] cancelImageRequest:requestID];
    }
}

- (PHAssetImageProgressHandler)imageDownloadingFromiCloud:(NSString *)localIdentifier {
    NSDictionary *entry = [_downloadOperations objectForKey:localIdentifier];
    if (entry) {
        return [entry objectForKey:@"progressHandler"];
    }
    return nil;
}

- (void)startDownLoadWithAsset:(PHAsset *)asset
               progressHandler:(PHAssetImageProgressHandler)progressHandler
                       finined:(DownloadImageFinined)finined {
    self.loading = YES;
    self.asset = asset;
    _imageOptions.progressHandler = progressHandler;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHImageRequestID requestID =  [[PHImageManager defaultManager] requestImageForAsset:asset
                                                                                 targetSize:PHImageManagerMaximumSize
                                                                                contentMode:PHImageContentModeDefault
                                                                                    options:_imageOptions
                                                                              resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info)
                                       {
                                           BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                                           if (downloadFinined) {
                                               //图片下载完成
                                               weakSelf.loading = NO;
                                               [weakSelf.downloadOperations removeObjectForKey:asset.localIdentifier];
                                               finined();
                                           }
                                       }];
        [weakSelf.downloadOperations setObject:@{@"requestID":[NSNumber numberWithInt:requestID],
                                                 @"progressHandler":progressHandler
                                                 } forKey:asset.localIdentifier];
    });
}


- (void)downloadImageFromiCloud:(PHAssetImageProgressHandler)progressHandler
                        finined:(DownloadImageFinined)finined {
    
    
}



@end
