//
//  TFCleaner.h
//  TFHotfix
//
//  Created by Melvin on 4/18/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <JSPatch/JPEngine.h>

@interface TFCleaner : JPExtension

+ (void)cleanAll;
+ (void)cleanClass:(NSString *)className;

@end
