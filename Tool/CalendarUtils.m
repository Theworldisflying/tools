#import "CalendarUtils.h"

// 实现CalendarUtils类
@implementation CalendarUtils

// 获取当前日期，默认格式 yyyy-MM-dd
+ (NSString *)getCurrentDate {
    // 调用自定义格式方法，传入默认格式 "yyyy-MM-dd"
    return [self getCurrentDateWithFormat:@"yyyy-MM-dd"];
}

// 获取当前日期，自定义格式
+ (NSString *)getCurrentDateWithFormat:(NSString *)format {
    // 创建日期格式化器
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置日期格式
    formatter.dateFormat = format;
    // 使用格式化器将当前日期转换为字符串并返回
    return [formatter stringFromDate:[NSDate date]];
}

// 获取当前时间戳
+ (NSTimeInterval)getCurrentTimestamp {
    // 返回当前日期的时间戳（从1970年1月1日以来的秒数）
    return [[NSDate date] timeIntervalSince1970];
}

// 字符串转日期
+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)format {
    // 创建日期格式化器
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置日期格式
    formatter.dateFormat = format;
    // 使用格式化器将字符串转换为日期对象并返回
    return [formatter dateFromString:dateString];
}

// 日期转字符串
+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format {
    // 创建日期格式化器
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置日期格式
    formatter.dateFormat = format;
    // 使用格式化器将日期对象转换为字符串并返回
    return [formatter stringFromDate:date];
}


// 时间戳转字符串，默认格式 ss
+ (NSString *)stringFromTimestamp:(NSTimeInterval)timestamp {
    // 调用自定义格式方法，传入默认格式 "ss"
    return [self stringFromTimestamp:timestamp format:@"ss"];
}

// 时间戳转字符串，自定义格式
+ (NSString *)stringFromTimestamp:(NSTimeInterval)timestamp format:(NSString *)format {
    // 创建日期格式化器
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置日期格式
    formatter.dateFormat = format;
    // 将时间戳转换为日期对象
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    // 使用格式化器将日期对象转换为字符串并返回
    return [formatter stringFromDate:date];
}

// 两个日期相减，返回天数差
+ (NSInteger)daysBetweenDate:(NSDate *)fromDate toDate:(NSDate *)toDate {
    // 获取当前日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 计算两个日期之间的天数差异
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0];
    // 返回天数差异
    return [components day];
}
// 两个时间戳相减，返回秒
+ (NSString *)timeDifferenceInSecondsStringBetweenTimestamp:(NSTimeInterval)timestamp1 andTimestamp:(NSTimeInterval)timestamp2 {
    NSTimeInterval difference = timestamp1 - timestamp2;
    int seconds = (int)difference; // 取整秒数
    return [NSString stringWithFormat:@"%02d", seconds];
}
// 获取指定日期往前指定天数的日期
+ (NSString *)dateBySubtractingDays:(NSInteger)days fromDate:(NSString *)inputDate {
    @autoreleasepool {
        // 创建一个日期格式化器
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        // 将输入字符串转换为日期对象
        NSDate *date = [dateFormatter dateFromString:inputDate];
        
        // 创建一个日历实例
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        // 创建并配置日期组件，设置为指定天数前
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.day = -days;
        
        // 使用日历计算新日期
        NSDate *previousDate = [calendar dateByAddingComponents:components toDate:date options:0];
        
        // 将计算出的日期转换回字符串
        NSString *resultDateStr = [dateFormatter stringFromDate:previousDate];
        
        return resultDateStr;
    }
}
//获取指定年月有多少天 yyyy-MM
+ (NSInteger)daysInMonthForString:(NSString *)yearMonth {
    // 1. 校验输入格式
    NSString *pattern = @"^\\d{4}-(0[1-9]|1[0-2])$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    if (![predicate evaluateWithObject:yearMonth]) {
        NSLog(@"Invalid date format: %@", yearMonth);
        return 0;
    }

    // 2. 创建日期格式化器
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM"];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]]; // 保证解析一致性

    // 3. 将字符串转换为 NSDate
    NSDate *date = [formatter dateFromString:yearMonth];
    if (!date) {
        NSLog(@"Failed to convert string to date: %@", yearMonth);
        return 0;
    }

    // 4. 获取日历实例
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];

    // 5. 获取该月的天数范围
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay
                              inUnit:NSCalendarUnitMonth
                              forDate:date];

    return range.length;
}
//获取指定 yyyy-MM-dd格式中的单独一个,如:NSString *year = [NSDateFormatter extractComponentFromDateString:dateStr component:@"yyyy"];
+ (NSString *)extractComponentFromDateString:(NSString *)dateString component:(NSString *)component {
    if (!dateString || ![dateString isKindOfClass:[NSString class]] || ![component isKindOfClass:[NSString class]]) {
        return nil;
    }

    // 检查 component 是否合法
    NSArray *validComponents = @[@"yyyy", @"MM", @"dd"];
    if (![validComponents containsObject:component]) {
        NSLog(@"Invalid component: %@", component);
        return nil;
    }

    // 创建日期格式化器并解析原始日期字符串
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:dateString];

    if (!date) {
        NSLog(@"Invalid date format. Expected format: yyyy-MM-dd");
        return nil;
    }

    // 设置目标格式
    [formatter setDateFormat:component];
    return [formatter stringFromDate:date];
}


+ (NSString *)getWeekdayNameFromDate:(NSString *)dateString {
    if (!dateString || ![dateString isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    // 创建日期格式化器并设置日期格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    // 将日期字符串转换为日期对象
    NSDate *date = [formatter dateFromString:dateString];
    if (!date) {
        NSLog(@"Invalid date format. Expected format: yyyy-MM-dd");
        return nil;
    }
    
    // 使用 NSCalendar 获取星期几
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday fromDate:date];
    NSInteger weekday = [components weekday];
    
    // 注意：返回的weekday值是基于当前日历系统的，通常是1（周日）到7（周六）
    NSArray *weekdaysName = @[Localized(@"星期日"), Localized(@"星期一"), Localized(@"星期二"), Localized(@"星期三"), Localized(@"星期四"), Localized(@"星期五"), Localized(@"星期六")];
    NSString *weekdayName = weekdaysName[weekday - 1]; // 调整索引以匹配数组
    
    return weekdayName;
}
//s转时分秒不足的省略
+ (NSString *)convertSecondsToTime:(int)totalSeconds {
    int hours = totalSeconds / 3600;
    int minutes = (totalSeconds % 3600) / 60;
    int seconds = totalSeconds % 60;
    
    NSMutableString *timeString = [NSMutableString string];
    
    if (hours > 0) {
        [timeString appendFormat:@"%d%@", hours,Localized(@"时")];
    }
    if (minutes > 0 || hours > 0) { // 如果有小时或分钟大于0，则显示分钟
        [timeString appendFormat:@"%d%@", minutes,Localized(@"分")];
    }
    [timeString appendFormat:@"%d%@", seconds,Localized(@"秒")]; // 总是显示秒
    
    return timeString;
}
+ (NSString *)convertSecondsToDateTime:(int)totalSeconds {
    int years = totalSeconds / (365 * 24 * 3600);
    int remainingSeconds = totalSeconds % (365 * 24 * 3600);
    int months = remainingSeconds / (30 * 24 * 3600); // 简单假设每个月30天
    remainingSeconds %= (30 * 24 * 3600);
    int days = remainingSeconds / (24 * 3600);
    remainingSeconds %= (24 * 3600);
    int hours = remainingSeconds / 3600;
    remainingSeconds %= 3600;
    int minutes = remainingSeconds / 60;
    int seconds = remainingSeconds % 60;
    
    NSMutableString *dateTimeString = [NSMutableString string];
    
    if (years > 0) {
        [dateTimeString appendFormat:@"%d%@", years,Localized(@"年")];
    }
    if (months > 0 || years > 0) {
        [dateTimeString appendFormat:@"%d%@", months,Localized(@"月")];
    }
    if (days > 0 || months > 0 || years > 0) {
        [dateTimeString appendFormat:@"%d%@", days,Localized(@"天")];
    }
    if (hours > 0 || days > 0 || months > 0 || years > 0) {
        [dateTimeString appendFormat:@"%d%@", hours,Localized(@"时")];
    }
    if (minutes > 0 || hours > 0 || days > 0 || months > 0 || years > 0) {
        [dateTimeString appendFormat:@"%d%@", minutes,Localized(@"分")];
    }
    [dateTimeString appendFormat:@"%d%@", seconds,Localized(@"秒")]; // 总是显示秒
    
    return dateTimeString;
}

@end
