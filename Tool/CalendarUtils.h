//
//  CalendarUtils.h
//  NexzDRIVER
//
//  Created by 瀚智科技 on 2025/5/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


// 定义CalendarUtils类接口
@interface CalendarUtils : NSObject

// 获取当前日期，默认格式 yyyy-MM-dd
+ (NSString *)getCurrentDate;

// 获取当前日期，自定义格式
+ (NSString *)getCurrentDateWithFormat:(NSString *)format;

// 获取当前时间戳
+ (NSTimeInterval)getCurrentTimestamp;

// 字符串转日期
+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)format;

// 日期转字符串
+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format;


// 时间戳转字符串，默认格式 ss
+ (NSString *)stringFromTimestamp:(NSTimeInterval)timestamp;

// 时间戳转字符串，自定义格式
+ (NSString *)stringFromTimestamp:(NSTimeInterval)timestamp format:(NSString *)format;

// 两个日期相减，返回天数差
+ (NSInteger)daysBetweenDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
// 两个时间错相减，返回秒
+ (NSString *)timeDifferenceInSecondsStringBetweenTimestamp:(NSTimeInterval)timestamp1 andTimestamp:(NSTimeInterval)timestamp2;
// 获取指定日期往前指定天数的日期
+ (NSString *)dateBySubtractingDays:(NSInteger)days fromDate:(NSString *)inputDate;
//获取指定年月有多少天 yyyy-MM
+ (NSInteger)daysInMonthForString:(NSString *)yearMonth;
//获取指定 yyyy-MM-dd格式中的单独一个,如:NSString *year = [NSDateFormatter extractComponentFromDateString:dateStr component:@"yyyy"];
+ (NSString *)extractComponentFromDateString:(NSString *)dateString component:(NSString *)component;
/**
 根据给定的日期字符串（格式：yyyy-MM-dd）返回对应的星期几名称。
 
 @param dateString 日期字符串，格式必须为 "yyyy-MM-dd"
 @return 星期几的中文名称，例如 "星期一" 或 nil 如果输入无效
 */
+ (NSString *)getWeekdayNameFromDate:(NSString *)dateString;
//s转时分秒不足的省略
+ (NSString *)convertSecondsToTime:(int)totalSeconds;
+ (NSString *)convertSecondsToDateTime:(int)totalSeconds;
@end

NS_ASSUME_NONNULL_END
