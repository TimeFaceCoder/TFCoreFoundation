//
//  UIFont+TFCore.h
//  TFCoreFoundation
//
//  Created by Melvin on 4/10/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreText/CoreText.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (TFCore) <NSCoding>

@property (nonatomic, readonly) BOOL isBold NS_AVAILABLE_IOS(7_0); ///< Whether the font is bold.
@property (nonatomic, readonly) BOOL isItalic NS_AVAILABLE_IOS(7_0); ///< Whether the font is italic.
@property (nonatomic, readonly) BOOL isMonoSpace NS_AVAILABLE_IOS(7_0); ///< Whether the font is mono space.
@property (nonatomic, readonly) BOOL isColorGlyphs NS_AVAILABLE_IOS(7_0); ///< Whether the font is color glyphs (such as Emoji).
@property (nonatomic, readonly) CGFloat fontWeight NS_AVAILABLE_IOS(7_0); ///< Font weight from -1.0 to 1.0. Regular weight is 0.0.

- (nullable UIFont *)fontWithBold NS_AVAILABLE_IOS(7_0);
- (nullable UIFont *)fontWithItalic NS_AVAILABLE_IOS(7_0);
- (nullable UIFont *)fontWithBoldItalic NS_AVAILABLE_IOS(7_0);
- (nullable UIFont *)fontWithNormal NS_AVAILABLE_IOS(7_0);

+ (nullable UIFont *)fontWithCTFont:(CTFontRef)CTFont;
+ (nullable UIFont *)fontWithCGFont:(CGFontRef)CGFont size:(CGFloat)size;
- (nullable CTFontRef)CTFontRef CF_RETURNS_RETAINED;
- (nullable CGFontRef)CGFontRef CF_RETURNS_RETAINED;

+ (BOOL)loadFontFromPath:(NSString *)path;
+ (void)unloadFontFromPath:(NSString *)path;
+ (nullable UIFont *)loadFontFromData:(NSData *)data;
+ (BOOL)unloadFontFromData:(UIFont *)font;

+ (nullable NSData *)dataFromFont:(UIFont *)font;
+ (nullable NSData *)dataFromCGFont:(CGFontRef)cgFont;


@end

NS_ASSUME_NONNULL_END
