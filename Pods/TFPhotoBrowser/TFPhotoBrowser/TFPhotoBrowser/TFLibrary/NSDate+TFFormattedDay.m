//
//  NSDate+TFFormattedDay.m
//  TFPhotoBrowser
//
//  Created by Melvin on 2/16/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import "NSDate+TFFormattedDay.h"
#import "TFPhotoBrowserBundle.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSDate (TFFormattedDay)
- (NSString *)tf_localizedDay {
    static NSDateFormatter *relativeFormatter = nil;
    static NSDateFormatter *comparisonFormatter = nil;
    static NSDateFormatter *weekdayFormatter = nil;
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        relativeFormatter = [NSDateFormatter new];
        relativeFormatter.dateStyle = NSDateFormatterMediumStyle;
        relativeFormatter.timeStyle = NSDateFormatterNoStyle;
        relativeFormatter.doesRelativeDateFormatting = YES;
        
        comparisonFormatter = [NSDateFormatter new];
        comparisonFormatter.dateStyle = NSDateFormatterMediumStyle;
        comparisonFormatter.timeStyle = NSDateFormatterNoStyle;
        
        weekdayFormatter = [NSDateFormatter new];
        weekdayFormatter.dateFormat = @"EEEE";
        
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:TFPhotoBrowserLocalizedStrings(@"dateFormatterOverWeek") options:0 locale:nil];
    });
    
    NSString *dateString = nil;
    NSString *relativeString = [relativeFormatter stringFromDate:self];
    NSString *absoluteString = [comparisonFormatter stringFromDate:self];
    
    if (![relativeString isEqual:absoluteString]) {
        dateString = relativeString;
    } else if (-self.timeIntervalSinceNow < 60.0 * 60.0 * 24.0 * 7.0) {
        dateString = [weekdayFormatter stringFromDate:self];
    } else {
        dateString = [dateFormatter stringFromDate:self];
    }
    
    return dateString;
}
@end

NS_ASSUME_NONNULL_END
