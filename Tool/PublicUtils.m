//
//  PublicUtils.m
//  NexzDRIVER
//
//  Created by 瀚智科技 on 2025/5/9.
//

#import "PublicUtils.h"
#import <sys/utsname.h>

@implementation PublicUtils
// 速度km/h 转 m/s
+ (double)speedInMetersPerSecondFromKilometersPerHour:(double)kmh {
    return kmh / 3.6;
}
+(NSInteger)style{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSInteger index = [userDefault integerForKey:SETTING_SYSTEM_STYLE];
    return index;
}
+(UIColor *)colorText{
    UIColor * color = [UIColor whiteColor];
    if ([self style] == 0)
    {
        color = [UIColor whiteColor];
//        NSLog(@"当前为黑色风格");
    }else{
        color = [UIColor blackColor];
//        NSLog(@"当前为白色风格");
    }
    return color;
}
+(UIColor *)colorTextw{
    UIColor * color = [UIColor whiteColor];
    if ([self style] == 0)
    {
        color = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    }else{
        color = [UIColor blackColor];
    }
    return color;
}
+(UIColor *)colorTextGw{
    UIColor * color = SPLITLINECOLORHARF;
    if ([self style] == 0)
    { //黑色风格-
        color =  [[UIColor whiteColor] colorWithAlphaComponent:0.7];;
    }else{//石墨黑
        color = GRAPHITEASCOLOR;
//        NSLog(@"当前为白色风格");
    }
    return color;
}
+ (UIColor *)colorBg{
    UIColor * color = [UIColor whiteColor];
    if ([self style] == 0)
    {
        color = [UIColor blackColor];
//        color =BACKGROUPCOLOR;
//        NSLog(@"当前为黑色风格");
    }else{
        color = [UIColor whiteColor];
//        NSLog(@"当前为白色风格");
    }
    return color;
}
+ (UIColor *)colorLine{
    UIColor * color = [UIColor whiteColor];
    if ([self style] == 0)
    {
//        color = [UIColor blackColor];
        color = [UIColor whiteColor];
//        NSLog(@"当前为黑色风格");
    }else{
        color = RGBA(237,237,237, 1);
//        NSLog(@"当前为白色风格");
    }
    return color;
}

+ (UIColor *)colorBgGrayOrBlack{
    UIColor * color = [UIColor whiteColor];
    if ([self style] == 0)
    {
//        color = [UIColor blackColor];
        color =BACKGROUPCOLOR;
//        NSLog(@"当前为黑色风格");
    }else{
        color = RGBA(232, 232, 232, 1);
//        NSLog(@"当前为白色风格");
    }
    return color;
}
+ (UIColor *)colorBgGrayOrDark{
    UIColor * color = [UIColor whiteColor];
    if ([self style] == 0)
    {
        color =RGBA(18,18,18, 1);;
    }else{
        color = RGBA(237,237,237, 1);
//        NSLog(@"当前为白色风格");
    }
    return color;
}



+(NSString *)deviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+(BOOL)isIPad {
    NSString *model = [self deviceModel];
    return [model hasPrefix:@"iPad"];
}

//// 使用示例
//if ([self isIPad]) {
//    NSLog(@"这是 iPad 设备");
//} else {
//    NSLog(@"这是 iPhone 设备");
//}
@end
