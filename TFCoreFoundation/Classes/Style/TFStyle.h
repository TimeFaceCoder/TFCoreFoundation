//
//  TFStyle.h
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TFStyle : NSObject

+ (TFStyle*)globalStyleSheet;

+ (void)setGlobalStyleSheet:(TFStyle*)styleSheet;

- (UIColor *)getColorByHex:(NSString *)hexColor;

- (UIColor *)getColorByHex:(NSString *)hexColor alpha:(CGFloat)alpha;

@end
