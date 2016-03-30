//
//  TFConfiguration.m
//  TFUploadAssistant
//
//  Created by Melvin on 3/23/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFConfiguration.h"

@implementation TFConfiguration

+ (void)enableLog {
    isEnable = YES;
}

+ (void)disableLog {
    isEnable = NO;
}

+ (BOOL)isLogEnable {
    return isEnable;
}

+ (void)setMaxConcurrentRequestCount:(uint32_t)count {
    maxRequestCount = count;
}

+ (uint32_t)maxConcurrentRequestCount {
    return maxRequestCount;
}

+ (void)setCompressionQuality:(float)quality {
    compressionQuality = quality;
}

+ (float)compressionQuality {
    return compressionQuality;
}

@end
