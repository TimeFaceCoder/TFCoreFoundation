//
//  TFStyle.m
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "TFStyle.h"
#import "TFCoreFoundationMacro.h"
#import "UIColor+TFCore.h"

static TFStyle* gStyleSheet = nil;

@interface TFStyle()

@end

@implementation TFStyle

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object: nil];
        
    }
    return self;
}


#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (TFStyle *)globalStyleSheet {
    if (!gStyleSheet) {
        gStyleSheet = [[TFStyle alloc] init];
    }
    return gStyleSheet;
}

+ (void)setGlobalStyleSheet:(TFStyle *)styleSheet {
    gStyleSheet = styleSheet;
}




- (void)didReceiveMemoryWarning:(void*)object {
    [self freeMemory];
}

- (UIColor *)getColorByHex:(NSString *)hexColor {
    return [UIColor colorWithHexString:hexColor];
}

- (void)freeMemory {
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
