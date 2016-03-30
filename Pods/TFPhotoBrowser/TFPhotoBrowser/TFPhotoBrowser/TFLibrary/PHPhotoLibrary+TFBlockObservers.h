//
//  PHPhotoLibrary+TFBlockObservers.h
//  TFPhotoBrowser
//
//  Created by Melvin on 2/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFBlockObserverToken : NSObject

@end

typedef void (^TFPhotoLibraryChangeObserverBlock)(PHChange *change);


@interface PHPhotoLibrary (TFBlockObservers)

- (TFBlockObserverToken *)tf_registerChangeObserverBlock:(TFPhotoLibraryChangeObserverBlock)observer;
- (void)tf_unregisterChangeObserverBlock:(TFBlockObserverToken *)token;

@end

NS_ASSUME_NONNULL_END
