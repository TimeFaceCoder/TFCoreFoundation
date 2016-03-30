//
//  ALAssetRepresentation+TFMD5.h
//  TFPhotoBrowser
//
//  Created by Melvin on 1/4/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetRepresentation (TFMD5)
- (NSString *)hashString;
- (NSString *)getMD5String;
@end
