//
//  UILabel+Extension.m
//  NexzDRIVER
//
//  Created by 瀚智科技 on 2025/5/22.
//

#import "UILabel+Extension.h"
#import <objc/runtime.h>

@implementation UILabel (Extension)

#pragma mark - 快速创建方法
+ (instancetype)labelWithText:(NSString *)text
                    textColor:(UIColor *)textColor
                     fontSize:(CGFloat)fontSize {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = textColor;
    label.font = [UIFont systemFontOfSize:fontSize];
    label.numberOfLines = 0;
    return label;
}
+ (instancetype)labTxt:(NSString *)text
                    color:(UIColor *)color
                     font:(UIFont*)font {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = color;
    label.font = font;
    label.numberOfLines = 0;
    label.adjustsFontSizeToFitWidth = YES;
    return label;
}

#pragma mark - 自适应高度
- (void)setTextAndAdjustHeight:(NSString *)text {
    self.text = text;
    self.numberOfLines = 0;
    [self sizeToFit];
}

#pragma mark - 设置行间距
- (void)setLineSpacing:(CGFloat)spacing {
    if (!self.text) return;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = spacing;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:paragraphStyle
                             range:NSMakeRange(0, [self.text length])];
    
    self.attributedText = attributedString;
}

#pragma mark - 设置字间距
- (void)setCharacterSpacing:(CGFloat)spacing {
    if (!self.text) return;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    [attributedString addAttribute:NSKernAttributeName
                             value:@(spacing)
                             range:NSMakeRange(0, [self.text length])];
    
    self.attributedText = attributedString;
}

#pragma mark - 添加点击手势
static char kAssociatedObjectKey;

- (void)addTapGestureWithTarget:(id)target action:(SEL)action {
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [self addGestureRecognizer:tap];
    
    // 使用关联对象存储手势，防止重复添加
    objc_setAssociatedObject(self, &kAssociatedObjectKey, tap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 设置部分文字颜色
- (void)setColor:(UIColor *)color forSubstring:(NSString *)substring {
    if (!self.text) return;
    
    NSRange range = [self.text rangeOfString:substring];
    if (range.location == NSNotFound) return;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:color
                             range:range];
    
    self.attributedText = attributedString;
}

#pragma mark - 设置部分文字字体
- (void)setFont:(UIFont *)font forSubstring:(NSString *)substring {
    if (!self.text) return;
    
    NSRange range = [self.text rangeOfString:substring];
    if (range.location == NSNotFound) return;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    [attributedString addAttribute:NSFontAttributeName
                             value:font
                             range:range];
    
    self.attributedText = attributedString;
}
#pragma mark - 自动调整字体大小以适应宽度
- (void)adjustFontSizeToFitWidthWithMinScale:(CGFloat)minScale {
    self.adjustsFontSizeToFitWidth = YES;
    self.minimumScaleFactor = minScale;
    self.lineBreakMode = NSLineBreakByTruncatingTail;
}

#pragma mark - 自动调整字体大小以适应宽度（指定最小字体大小）
- (void)adjustFontSizeToFitWidthWithMinFontSize:(CGFloat)minFontSize {
    if (self.font.pointSize <= 0) return;
    
    self.adjustsFontSizeToFitWidth = YES;
    self.minimumScaleFactor = minFontSize / self.font.pointSize;
    self.lineBreakMode = NSLineBreakByTruncatingTail;
}

@end
