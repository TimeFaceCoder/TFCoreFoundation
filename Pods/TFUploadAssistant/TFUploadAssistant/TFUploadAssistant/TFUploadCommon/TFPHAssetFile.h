//
//  TFPHAssetFile.h
//  TFUploadAssistant
//
//  Created by Melvin on 3/23/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFFileProtocol.h"

@class PHAsset;
@interface TFPHAssetFile : NSObject<TFFileProtocol>

- (instancetype)init:(PHAsset *)phAsset
               error:(NSError *__autoreleasing *)error;

@end
