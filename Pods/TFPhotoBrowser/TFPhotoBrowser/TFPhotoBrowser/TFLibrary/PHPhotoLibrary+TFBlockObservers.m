//
//  PHPhotoLibrary+TFBlockObservers.m
//  TFPhotoBrowser
//
//  Created by Melvin on 2/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "PHPhotoLibrary+TFBlockObservers.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFBlockObserverToken () <PHPhotoLibraryChangeObserver>

@property (nonatomic, copy) TFPhotoLibraryChangeObserverBlock changeObserverBlock;
@property (nonatomic, strong, nullable) TFBlockObserverToken *strongSelf;

@end

@implementation TFBlockObserverToken

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    _changeObserverBlock(changeInstance);
}

@end

@implementation PHPhotoLibrary (TFBlockObservers)

- (TFBlockObserverToken *)tf_registerChangeObserverBlock:(TFPhotoLibraryChangeObserverBlock)observer {
    TFBlockObserverToken *token = [[TFBlockObserverToken alloc] init];
    token.changeObserverBlock = observer;
    token.strongSelf = token;
    
    [self registerChangeObserver:token];
    
    return token;
}

- (void)tf_unregisterChangeObserverBlock:(TFBlockObserverToken *)token {
    [self unregisterChangeObserver:token];
    token.strongSelf = nil;
}

@end

NS_ASSUME_NONNULL_END