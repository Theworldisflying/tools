//
//  HXTabBarController.h
//  NexzDRIVER
//
//  Created by 瀚智科技 on 2025/6/20.
//
// HXTabBarController.h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HXTabBarController : UITabBarController

/// 设置TabBar背景色（支持透明度）
/// @param backgroundColor 背景色
/// @param opacity 透明度 (0.0-1.0)
- (void)setTabBarBackgroundColor:(UIColor *)backgroundColor opacity:(CGFloat)opacity;

/// 设置顶部分割线
/// @param color 分割线颜色（默认浅灰色）
/// @param height 分割线高度（默认0.5）
- (void)setTopLineColor:(nullable UIColor *)color height:(CGFloat)height;

/// 添加子控制器
/// @param controller 视图控制器
/// @param title 标题
/// @param normalImage 未选中图片
/// @param selectedImage 选中图片
/// @param normalColor 未选中颜色
/// @param selectedColor 选中颜色
- (void)addChildController:(UIViewController *)controller
                     title:(nullable NSString *)title
               normalImage:(UIImage *)normalImage
             selectedImage:(UIImage *)selectedImage
               normalColor:(nullable UIColor *)normalColor
             selectedColor:(nullable UIColor *)selectedColor;

/// 更新指定Tab项的显示内容
/// @param index 索引位置
/// @param title 新标题
/// @param normalImage 新未选中图片
/// @param selectedImage 新选中图片
/// @param normalColor 新未选中颜色
/// @param selectedColor 新选中颜色
- (void)updateTabItemAtIndex:(NSUInteger)index
                       title:(nullable NSString *)title
                 normalImage:(nullable UIImage *)normalImage
               selectedImage:(nullable UIImage *)selectedImage
                 normalColor:(nullable UIColor *)normalColor
               selectedColor:(nullable UIColor *)selectedColor;

/// 设置项选中时的缩放效果
/// @param index 索引位置
/// @param scale 缩放比例 (1.0表示不缩放，1.2表示放大20%)
/// @param duration 动画时长 (秒)
/// @param damping 弹簧阻尼系数 (0.0-1.0)
- (void)setScaleEffectForSelectedItemAtIndex:(NSUInteger)index
                                       scale:(CGFloat)scale
                                    duration:(CGFloat)duration
                                     damping:(CGFloat)damping;

@end

NS_ASSUME_NONNULL_END
