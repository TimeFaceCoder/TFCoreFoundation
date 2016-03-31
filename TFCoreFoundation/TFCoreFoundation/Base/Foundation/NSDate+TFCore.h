//
//  NSDate+TFCore.h
//  TFCoreFoundation
//
//  Created by Melvin on 3/30/16.
//  Copyright © 2016 TimeFace. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface NSDate (TFCore)

@property (nonatomic, readonly) NSInteger year; ///< Year component
@property (nonatomic, readonly) NSInteger month; ///< Month component (1~12)
@property (nonatomic, readonly) NSInteger day; ///< Day component (1~31)
@property (nonatomic, readonly) NSInteger hour; ///< Hour component (0~23)
@property (nonatomic, readonly) NSInteger minute; ///< Minute component (0~59)
@property (nonatomic, readonly) NSInteger second; ///< Second component (0~59)
@property (nonatomic, readonly) NSInteger nanosecond; ///< Nanosecond component
@property (nonatomic, readonly) NSInteger weekday; ///< Weekday component (1~7, first day is based on user setting)
@property (nonatomic, readonly) NSInteger weekdayOrdinal; ///< WeekdayOrdinal component
@property (nonatomic, readonly) NSInteger weekOfMonth; ///< WeekOfMonth component (1~5)
@property (nonatomic, readonly) NSInteger weekOfYear; ///< WeekOfYear component (1~53)
@property (nonatomic, readonly) NSInteger yearForWeekOfYear; ///< YearForWeekOfYear component
@property (nonatomic, readonly) NSInteger quarter; ///< Quarter component
@property (nonatomic, readonly) BOOL isLeapMonth; ///< whether the month is leap month
@property (nonatomic, readonly) BOOL isLeapYear; ///< whether the year is leap year
@property (nonatomic, readonly) BOOL isToday; ///< whether date is today (based on current locale)
@property (nonatomic, readonly) BOOL isYesterday; ///< whether date is yesterday (based on current locale)

- (nullable NSDate *)tf_dateByAddingYears:(NSInteger)years;
- (nullable NSDate *)tf_dateByAddingMonths:(NSInteger)months;
- (nullable NSDate *)tf_dateByAddingWeeks:(NSInteger)weeks;
- (nullable NSDate *)tf_dateByAddingDays:(NSInteger)days;
- (nullable NSDate *)tf_dateByAddingHours:(NSInteger)hours;
- (nullable NSDate *)tf_dateByAddingMinutes:(NSInteger)minutes;
- (nullable NSDate *)tf_dateByAddingSeconds:(NSInteger)seconds;


- (nullable NSString *)tf_stringWithFormat:(NSString *)format;

- (nullable NSString *)tf_stringWithFormat:(NSString *)format
                               timeZone:(nullable NSTimeZone *)timeZone
                                 locale:(nullable NSLocale *)locale;
- (nullable NSString *)tf_stringWithISOFormat;
+ (nullable NSDate *)tf_dateWithString:(NSString *)dateString format:(NSString *)format;
+ (nullable NSDate *)tf_dateWithString:(NSString *)dateString
                             format:(NSString *)format
                           timeZone:(nullable NSTimeZone *)timeZone
                             locale:(nullable NSLocale *)locale;
+ (nullable NSDate *)tf_dateWithISOFormatString:(NSString *)dateString;

@end
NS_ASSUME_NONNULL_END