//
//  PHImageManager+TFRequestImages.m
//  TFPhotoBrowser
//
//  Created by Melvin on 2/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "PHImageManager+TFRequestImages.h"

NS_ASSUME_NONNULL_BEGIN

@implementation PHImageManager (TFRequestImages)

- (NSDictionary<NSString *, NSNumber *> *)tf_requestImagesForAssets:(NSArray<PHAsset *> *)assets
                                                         targetSize:(CGSize)targetSize
                                                        contentMode:(PHImageContentMode)contentMode
                                                            options:(nullable PHImageRequestOptions *)options
                                                      resultHandler:(void (^)(NSDictionary<NSString *, UIImage *> *__nullable results,
                                                                              NSDictionary<NSString *, NSDictionary *> *__nullable infos))resultHandler {
    if (options.deliveryMode == PHImageRequestOptionsDeliveryModeOpportunistic) {
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    }
    
    NSMutableDictionary *results = [NSMutableDictionary new];
    NSMutableDictionary *infos = [NSMutableDictionary new];
    NSMutableDictionary *requestIDs = [NSMutableDictionary new];
    dispatch_group_t group = dispatch_group_create();
    
    for (PHAsset *asset in assets) {
        dispatch_group_enter(group);
        PHImageRequestID requestID = [self requestImageForAsset:asset targetSize:targetSize contentMode:contentMode options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            if (result != nil && info != nil) {
                results[asset.localIdentifier] = result;
                infos[asset.localIdentifier] = info;
            }
            
            dispatch_group_leave(group);
        }];
        
        requestIDs[asset.localIdentifier] = @(requestID);
    }
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        resultHandler(results, infos);
    });
    
    return requestIDs;
}

@end

NS_ASSUME_NONNULL_END