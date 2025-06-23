//
//  UIFont+CustomSize.h
//  NexzDRIVER
//
//  Created by 瀚智科技 on 2025/5/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (CustomSize)
//根据系统字体设计偏移量
+ (UIFont *)customFontOfSizeOffset:(CGFloat)offset;
+ (UIFont *)customBoldFontOfSizeOffset:(CGFloat)offset;
//根据系统字体设计偏移量 指定字体
+ (UIFont *)customFontName:(NSString*)fontName sizeOffset:(CGFloat)offset;
//斜体
+ (UIFont *)customItalicFontOfSizeOffset:(CGFloat)offset;
@end

NS_ASSUME_NONNULL_END
