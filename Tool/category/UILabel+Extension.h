//
//  UILabel+Extension.h
//  NexzDRIVER
//
//  Created by 瀚智科技 on 2025/5/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (Extension)

// 快速创建 UILabel
+ (instancetype)labelWithText:(NSString *)text
                    textColor:(UIColor *)textColor
                     fontSize:(CGFloat)fontSize;
+ (instancetype)labTxt:(NSString *)text
                    color:(UIColor *)color
                  font:(UIFont*)font;

// 设置文本并自动调整高度
- (void)setTextAndAdjustHeight:(NSString *)text;

// 设置行间距
- (void)setLineSpacing:(CGFloat)spacing;

// 设置字间距
- (void)setCharacterSpacing:(CGFloat)spacing;

// 添加点击事件
- (void)addTapGestureWithTarget:(id)target action:(SEL)action;

// 设置部分文字颜色
- (void)setColor:(UIColor *)color forSubstring:(NSString *)substring;

// 设置部分文字字体
- (void)setFont:(UIFont *)font forSubstring:(NSString *)substring;

// 自动调整字体大小以适应宽度
- (void)adjustFontSizeToFitWidthWithMinScale:(CGFloat)minScale;

// 自动调整字体大小以适应宽度（指定最小字体大小）
- (void)adjustFontSizeToFitWidthWithMinFontSize:(CGFloat)minFontSize;

@end

NS_ASSUME_NONNULL_END
