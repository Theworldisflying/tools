//
//  PublicUtils.h
//  NexzDRIVER
//
//  Created by 瀚智科技 on 2025/5/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PublicUtils : NSObject
// 速度km/h 转 m/s
+ (double)speedInMetersPerSecondFromKilometersPerHour:(double)kmh;
//设备型号
+(NSString *)deviceModel;
+(BOOL)isIPad; // 是否为 ipad
//系统风格
+(NSInteger)style;
+(UIColor*)colorText;
+(UIColor*)colorBg;
+(UIColor*)colorBgGrayOrBlack; // 黑灰背景色
+(UIColor *)colorTextGw;
+ (UIColor *)colorBgGrayOrDark;
+ (UIColor *)colorLine;


@end

NS_ASSUME_NONNULL_END
