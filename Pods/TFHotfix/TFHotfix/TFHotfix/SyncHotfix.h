//
//  SyncHotfix.h
//  TFHotfix
//
//  Created by Melvin on 3/18/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <TFNetwork/TFRequest.h>
#import <Foundation/Foundation.h>

@interface SyncHotfix : TFRequest

- (instancetype)initWithAppKey:(NSString *)appKey;

@end
