//
//  PHAsset+TFExpand.h
//  TFPhotoBrowser
//
//  Created by Melvin on 2/17/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Photos/Photos.h>

typedef void (^PHAssetBoolBlock)(BOOL success);
typedef void (^PHAssetMetadataBlock)(NSDictionary *metadata);
typedef void (^PHAssetAssetBoolBlock)(PHAsset *asset, BOOL success);

@interface PHAsset (TFExpand)

-(void)saveToAlbum:(NSString*)title completionBlock:(PHAssetBoolBlock)completionBlock;
-(void)requestMetadataWithCompletionBlock:(PHAssetMetadataBlock)completionBlock;
-(void)updateLocation:(CLLocation*)location creationDate:(NSDate*)creationDate completionBlock:(PHAssetBoolBlock)completionBlock;
+(void)saveImageToCameraRoll:(UIImage*)image location:(CLLocation*)location completionBlock:(PHAssetAssetBoolBlock)completionBlock;
+(void)saveVideoAtURL:(NSURL*)url location:(CLLocation*)location completionBlock:(PHAssetAssetBoolBlock)completionBlock;


@property (nonatomic, weak, readonly) UIImage  *thumbnail;
@property (nonatomic, weak, readonly) UIImage  *fullScreenImage;
@property (nonatomic, weak, readonly) UIImage  *fullResolutionImage;
@property (nonatomic, weak, readonly) NSString *fileExtension;
@property (nonatomic, weak, readonly) NSString *md5;

@end
