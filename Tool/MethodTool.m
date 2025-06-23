//
//  MethodTool.m
//  NexzDRIVER
//
//  Created by 瀚智科技 on 2025/2/20.
//

#import "MethodTool.h"

@implementation MethodTool

///验证是否是空字符串
+ (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isEqualToString:@"(null)"]) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

@end
