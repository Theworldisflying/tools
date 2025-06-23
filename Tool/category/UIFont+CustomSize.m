//
//  UIFont+CustomSize.m
//  NexzDRIVER
//
//  Created by 瀚智科技 on 2025/5/13.
//

#import "UIFont+CustomSize.h"

@implementation UIFont (CustomSize)
//根据系统字体设计偏移量
+ (UIFont *)customFontOfSizeOffset:(CGFloat)offset {
    return [UIFont systemFontOfSize:[UIFont systemFontSize] - offset];
}

+ (UIFont *)customBoldFontOfSizeOffset:(CGFloat)offset {
    return [UIFont boldSystemFontOfSize:[UIFont systemFontSize] - offset];
}
+ (UIFont *)customFontName:(NSString*)fontName sizeOffset:(CGFloat)offset {
    CGFloat size = [UIFont systemFontSize] - offset;
    return [UIFont fontWithName:fontName size:size];
}
//斜体
+ (UIFont *)customItalicFontOfSizeOffset:(CGFloat)offset {
    return [UIFont italicSystemFontOfSize:[UIFont systemFontSize] - offset];
}

@end
