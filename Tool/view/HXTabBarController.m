//
//  HXTabBarController.m
//  NexzDRIVER
//
//  Created by 瀚智科技 on 2025/6/20.
//
// HXTabBarController.m
#import "HXTabBarController.h"
#import <objc/runtime.h>

// 自定义UITabBar类别，用于背景效果优化
@interface UITabBar (HXCustomBackground)
@property (nonatomic, strong) UIView *hx_customBackgroundView;
@property (nonatomic, strong) UIView *hx_topLineView; // 顶部分割线视图
@end

@implementation UITabBar (HXCustomBackground)

- (UIView *)hx_customBackgroundView {
    return objc_getAssociatedObject(self, @selector(hx_customBackgroundView));
}

- (void)setHx_customBackgroundView:(UIView *)hx_customBackgroundView {
    objc_setAssociatedObject(self, @selector(hx_customBackgroundView), hx_customBackgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)hx_topLineView {
    UIView *line = objc_getAssociatedObject(self, @selector(hx_topLineView));
    if (!line) {
        // 创建默认分割线 (0.5pt, 浅灰色)
        line = [[UIView alloc] initWithFrame:CGRectZero];
        line.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
        line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:line];
        
        // 设置默认高度
        CGRect frame = self.frame;
        line.frame = CGRectMake(0, 0, CGRectGetWidth(frame), 0.5);
        
        objc_setAssociatedObject(self, @selector(hx_topLineView), line, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return line;
}

- (void)setHx_topLineView:(UIView *)hx_topLineView {
    objc_setAssociatedObject(self, @selector(hx_topLineView), hx_topLineView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface HXTabBarController () <UITabBarControllerDelegate>
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *tabItemConfigurations;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSDictionary *> *scaleEffectConfigs; // 缩放效果配置
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIView *> *tabButtonViews; // 存储所有tab按钮视图
@property (nonatomic, assign) NSUInteger lastSelectedIndex; // 记录上次选中的索引
@property (nonatomic, assign) BOOL initialAppearanceCompleted; // 标记初始外观是否已完成
@end

@implementation HXTabBarController

- (instancetype)init {
    self = [super init];
    if (self) {
        _tabItemConfigurations = [NSMutableArray array];
        _scaleEffectConfigs = [NSMutableDictionary dictionary];
        _tabButtonViews = [NSMutableDictionary dictionary];
        _lastSelectedIndex = NSNotFound;
        _initialAppearanceCompleted = NO;
        self.delegate = self;
        [self configureDefaultAppearance];
    }
    return self;
}

// 配置默认外观
- (void)configureDefaultAppearance {
    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
        [appearance configureWithDefaultBackground];
        self.tabBar.standardAppearance = appearance;
    }
    
    // 确保分割线视图被创建
    [self.tabBar hx_topLineView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 标记初始外观已完成
    self.initialAppearanceCompleted = YES;
    
    // 确保默认选中项应用缩放效果
    [self applyInitialScaleEffectIfNeeded];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // 更新分割线位置
    UIView *topLine = [self.tabBar hx_topLineView];
    CGRect frame = topLine.frame;
    frame.size.width = CGRectGetWidth(self.tabBar.frame);
    topLine.frame = frame;
    
    // 缓存所有tab按钮视图
    [self cacheTabBarButtons];
    
    // 确保初始缩放效果已应用
    if (self.initialAppearanceCompleted) {
        [self applyInitialScaleEffectIfNeeded];
    }
}

- (void)setTopLineColor:(nullable UIColor *)color height:(CGFloat)height {
    UIView *topLine = [self.tabBar hx_topLineView];
    
    // 设置分割线颜色（默认为浅灰色）
    topLine.backgroundColor = color ?: [UIColor colorWithWhite:0.85 alpha:1.0];
    
    // 设置分割线高度（默认0.5）
    CGFloat lineHeight = height > 0 ? height : 0.5;
    CGRect frame = topLine.frame;
    frame.size.height = lineHeight;
    topLine.frame = frame;
    
    // 确保分割线在顶部并可见
    topLine.hidden = NO;
    [self.tabBar bringSubviewToFront:topLine];
}

- (void)setTabBarBackgroundColor:(UIColor *)backgroundColor opacity:(CGFloat)opacity {
    // 确保透明度在有效范围内
    CGFloat validOpacity = MAX(0.0, MIN(1.0, opacity));
    
    // 处理不同iOS版本
    if (@available(iOS 15.0, *)) {
        // iOS 15+ 使用系统推荐方式
        UITabBarAppearance *appearance = [self.tabBar.standardAppearance copy];
        
        // 创建系统原生模糊效果
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
        
        // 创建带有背景色的视图
        UIView *backgroundView = [[UIView alloc] initWithFrame:self.tabBar.bounds];
        backgroundView.backgroundColor = [backgroundColor colorWithAlphaComponent:validOpacity];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // 清除旧背景
        if (self.tabBar.hx_customBackgroundView) {
            [self.tabBar.hx_customBackgroundView removeFromSuperview];
        }
        
        // 设置背景效果
        appearance.backgroundEffect = blurEffect;
        
        // 添加新背景
        [self.tabBar insertSubview:backgroundView atIndex:0];
        self.tabBar.hx_customBackgroundView = backgroundView;
        
        // 应用外观设置
        self.tabBar.standardAppearance = appearance;
        self.tabBar.scrollEdgeAppearance = appearance;
    }
    else if (@available(iOS 13.0, *)) {
        // iOS 13-极速 处理方式
        UITabBarAppearance *appearance = [self.tabBar.standardAppearance copy];
        [appearance configureWithTransparentBackground];
        
        // 设置背景色
        appearance.backgroundColor = [backgroundColor colorWithAlphaComponent:validOpacity];
        
        // 应用外观设置
        self.tabBar.standardAppearance = appearance;
    }
    else {
        // iOS 12及以下处理
        UIView *background极速iew = [[UIView alloc] initWithFrame:self.tabBar.bounds];
        background极速iew.backgroundColor = [backgroundColor colorWithAlphaComponent:validOpacity];
        background极速iew.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // 清除旧背景
        [self.tabBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:NSClassFromString(@"_UITabBarBackgroundView")]) {
                [obj removeFromSuperview];
                *stop = YES;
            }
        }];
        
        [self.tabBar insertSubview:background极速iew atIndex:0];
    }
    
    // 确保分割线在背景上方
    [[self.tabBar hx_topLineView] removeFromSuperview];
    [self.tabBar addSubview:[self.tabBar hx_topLineView]];
    
    // 重新缓存按钮视图
    [self cacheTabBarButtons];
    
    // 应用缩放效果
    [self applyInitialScaleEffectIfNeeded];
}

- (void)addChildController:(UIViewController *)controller
                     title:(nullable NSString *)title
               normalImage:(UIImage *)normalImage
             selectedImage:(UIImage *)selectedImage
               normalColor:(nullable UIColor *)normalColor
             selectedColor:(nullable UIColor *)selectedColor {
    
    // 确保所有必要参数不为nil
    NSParameterAssert(normalImage != nil);
    NSParameterAssert(selectedImage != nil);
    
    // 配置TabBarItem
    UITabBarItem *tabItem = [[UITabBarItem alloc] init];
    tabItem.title = title;
    tabItem.image = [normalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabItem.selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 配置文字颜色
    UIColor *defaultNormalColor = normalColor ?: [UIColor grayColor];
    UIColor *defaultSelectedColor = selectedColor ?: [UIColor blueColor];
    
    // 直接设置TabBarItem的标题属性，确保在iOS 13+也能生效
    [tabItem setTitleTextAttributes:@{NSForegroundColorAttributeName: defaultNormalColor}
                           forState:UIControlStateNormal];
    [tabItem setTitleTextAttributes:@{NSForegroundColorAttributeName: defaultSelectedColor}
                           forState:UIControlStateSelected];
    
    // 对于iOS 13+ 还需要设置appearance中的样式
    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *appearance = [self.tabBar.standardAppearance copy];
        
        // 创建堆叠布局外观
        UITabBarItemAppearance *stackedAppearance = [[UITabBarItemAppearance alloc] init];
        
        // 设置正常状态样式
        stackedAppearance.normal.titleTextAttributes = @{NSForegroundColorAttributeName: defaultNormalColor};
        stackedAppearance.normal.iconColor = defaultNormalColor;
        
        // 设置选中状态样式
        stackedAppearance.selected.titleTextAttributes = @{NSForegroundColorAttributeName: defaultSelectedColor};
        stackedAppearance.selected.iconColor = defaultSelectedColor;
        
        // 应用堆叠布局外观
        appearance.stackedLayoutAppearance = stackedAppearance;
        
        // 应用水平紧凑布局外观
        appearance.compactInlineLayoutAppearance = stackedAppearance;
        
        // 应用横屏布局外观
        appearance.inlineLayoutAppearance = stackedAppearance;
        
        // 应用外观设置
        self.tabBar.standardAppearance = appearance;
        
        // iOS 15+设置滚动边缘外观
        if (@available(iOS 15.0, *)) {
            self.tabBar.scrollEdgeAppearance = appearance;
        }
    }
    
    controller.tabBarItem = tabItem;
    
    // 安全地保存配置信息（包括颜色）
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    if (title) config[@"title"] = title;
    config[@"normalImage"] = normalImage;
    config[@"selectedImage"] = selectedImage;
    if (normalColor) config[@"normalColor"] = normalColor;
    if (selectedColor) config[@"selectedColor"] = selectedColor;
    
    [self.tabItemConfigurations addObject:[config copy]];
    
    // 嵌入导航控制器
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self addChildViewController:navController];
    
    // 重新缓存按钮视图
    [self cacheTabBarButtons];
    
    // 确保默认选中项应用缩放效果
    [self applyInitialScaleEffectIfNeeded];
}

- (void)updateTabItemAtIndex:(NSUInteger)index
                       title:(nullable NSString *)title
                 normalImage:(nullable UIImage *)normalImage
               selectedImage:(nullable UIImage *)selectedImage
                 normalColor:(nullable UIColor *)normalColor
               selectedColor:(nullable UIColor *)selectedColor {
    
    if (index >= self.viewControllers.count) return;
    
    UINavigationController *navController = self.viewControllers[index];
    if (!navController) return;
    
    UIViewController *controller = navController.viewControllers.firstObject;
    UITabBarItem *tabItem = controller.tabBarItem;
    
    // 安全地更新数据源
    if (index < self.tabItemConfigurations.count) {
        NSMutableDictionary *config = [self.tabItemConfigurations[index] mutableCopy];
        if (title) config[@"title"] = title;
        if (normalImage) config[@"normalImage"] = normalImage;
        if (selectedImage) config[@"selectedImage"] = selectedImage;
        if (normalColor) config[@"normalColor"] = normalColor;
        if (selectedColor) config[@"selectedColor"]= selectedColor;
        self.tabItemConfigurations[index] = [config copy];
    }
    
    // 更新UI
    if (title) tabItem.title = title;
    if (normalImage) tabItem.image = [normalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    if (selectedImage) tabItem.selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 更新颜色
    if (normalColor || selectedColor) {
        UIColor *newNormalColor = normalColor ?: [self getColorForIndex:index state:UIControlStateNormal];
        UIColor *newSelectedColor = selectedColor ?: [self getColorForIndex:index state:UIControlStateSelected];
        
        [tabItem setTitleTextAttributes:@{NSForegroundColorAttributeName: newNormalColor}
                               forState:UIControlStateNormal];
        [tabItem setTitleTextAttributes:@{NSForegroundColorAttributeName: newSelectedColor}
                               forState:UIControlStateSelected];
        
        // iOS 13+需要额外更新appearance
        if (@available(iOS 13.0, *)) {
            [self updateAppearanceForIndex:index
                               normalColor:newNormalColor
                             selectedColor:newSelectedColor];
        }
    }
    
    // 确保缩放效果应用
    if (index == self.selectedIndex) {
        [self updateScaleEffectForSelectedItem];
    }
}

// 设置项选中时的缩放效果
- (void)setScaleEffectForSelectedItemAtIndex:(NSUInteger)index
                                       scale:(CGFloat)scale
                                    duration:(CGFloat)duration
                                     damping:(CGFloat)damping {
    
    // 验证参数有效性
    scale = MAX(1.0, scale); // 确保最小值为1.0
    duration = MAX(0.1, MIN(1.0, duration)); // 限制在0.1-1.0秒之间
    damping = MAX(0.1, MIN(1.0, damping)); // 限制在0.1-1.0之间
    
    // 创建配置字典
    NSDictionary *config = @{
        @"scale": @(scale),
        @"duration": @(duration),
        @"damping": @(damping)
    };
    
    // 保存配置
    self.scaleEffectConfigs[@(index)] = config;
    
    // 如果当前选中项有缩放效果，立即应用
    if (self.selectedIndex == index) {
        [self cacheTabBarButtons];
        [self updateScaleEffectForSelectedItem];
    }
}

// 辅助方法：获取指定索引的颜色
- (UIColor *)getColorForIndex:(NSUInteger)index state:(UIControlState)state {
    if (index < self.tabItemConfigurations.count) {
        NSDictionary *config = self.tabItemConfigurations[index];
        if (state == UIControlStateNormal) {
            return config[@"normalColor"] ?: [UIColor grayColor];
        } else {
            return config[@"selectedColor"] ?: [UIColor blueColor];
        }
    }
    return state == UIControlStateNormal ? [UIColor grayColor] : [UIColor blueColor];
}

// 辅助方法：更新指定索引的appearance
- (void)updateAppearanceForIndex:(NSUInteger)index
                     normalColor:(UIColor *)normalColor
                   selectedColor:(UIColor *)selectedColor {
    
    if (@available(iOS 13.0, *)) {
        // 创建新的appearance
        UITabBarAppearance *appearance = [self.tabBar.standardAppearance copy];
        
        // 创建新的Item外观
        UITabBarItemAppearance *stackedAppearance = [[UITabBarItemAppearance alloc] init];
        
        // 配置正常状态
        stackedAppearance.normal.titleTextAttributes = @{NSForegroundColorAttributeName: normalColor};
        stackedAppearance.normal.iconColor = normalColor;
        
        // 配置选中状态
        stackedAppearance.selected.titleTextAttributes = @{NSForegroundColorAttributeName: selectedColor};
        stackedAppearance.selected.iconColor = selectedColor;
        
        // 应用新的外观配置
        appearance.stackedLayoutAppearance = stackedAppearance;
        appearance.compactInlineLayoutAppearance = stackedAppearance;
        appearance.inlineLayoutAppearance = stackedAppearance;
        
        // 更新tabBar的外观
        self.tabBar.standardAppearance = appearance;
        
        // iOS 15+更新滚动边缘外观
        if (@available(iOS 15.0, *)) {
            self.tabBar.scrollEdgeAppearance = appearance;
        }
    }
}

#pragma mark - 初始缩放效果处理

// 确保初始选中项应用缩放效果
- (void)applyInitialScaleEffectIfNeeded {
    if (self.initialAppearanceCompleted && self.selectedIndex != NSNotFound) {
        self.lastSelectedIndex = NSNotFound; // 重置记录
        [self updateScaleEffectForSelectedItem];
    }
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    // 应用缩放效果
    [self updateScaleEffectForSelectedItem];
}

#pragma mark - 缩放效果实现

// 缓存所有tab按钮视图
- (void)cacheTabBarButtons {
    // 清空缓存
    [self.tabButtonViews removeAllObjects];
    
    // 获取所有UITabBarButton视图
    NSArray *tabBarButtons = [self.tabBar.subviews filteredArrayUsingPredicate:
                             [NSPredicate predicateWithBlock:^BOOL(UIView *subview, NSDictionary *bindings) {
        return [subview isKindOfClass:NSClassFromString(@"UITabBarButton")];
    }]];
    
    // 按x坐标排序
    tabBarButtons = [tabBarButtons sortedArrayUsingComparator:^NSComparisonResult(UIView *a, UIView *b) {
        return [@(a.frame.origin.x) compare:@(b.frame.origin.x)];
    }];
    
    // 缓存视图
    for (NSUInteger i = 0; i < tabBarButtons.count; i++) {
        if (i < self.tabBar.items.count) {
            UIView *tabBarButton = tabBarButtons[i];
            self.tabButtonViews[@(i)] = tabBarButton;
            
            // 确保初始状态没有缩放
            tabBarButton.transform = CGAffineTransformIdentity;
        }
    }
}

// 更新当前选中项的缩放效果
- (void)updateScaleEffectForSelectedItem {
    NSInteger selectedIndex = self.selectedIndex;
    
    // 检查索引是否有效
    if (selectedIndex < 0 || selectedIndex >= self.tabButtonViews.count) {
        return;
    }
    
    // 移除上一个选中项的缩放效果
    if (self.lastSelectedIndex != NSNotFound && self.lastSelectedIndex != selectedIndex) {
        UIView *prevTabButton = self.tabButtonViews[@(self.lastSelectedIndex)];
        [self removeScaleEffectOnView:prevTabButton];
        
        // 如果有上一个选中项的配置，应用恢复动画
        if (self.scaleEffectConfigs[@(self.lastSelectedIndex)]) {
            [UIView animateWithDuration:0.3
                                  delay:0
                 usingSpringWithDamping:0.6
                  initialSpringVelocity:0
                                options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                prevTabButton.transform = CGAffineTransformIdentity;
            } completion:nil];
        }
    }
    
    // 应用新选中项的缩放效果
    UIView *tabBarButton = self.tabButtonViews[@(selectedIndex)];
    if (tabBarButton) {
        [self applyScaleEffectForItemAtIndex:selectedIndex toView:tabBarButton];
    }
    
    // 更新记录的上一个选中索引
    self.lastSelectedIndex = selectedIndex;
}

// 应用缩放效果到指定项
- (void)applyScaleEffectForItemAtIndex:(NSUInteger)index toView:(UIView *)tabBarButton {
    // 检查是否有此索引的配置
    NSDictionary *config = self.scaleEffectConfigs[@(index)];
    if (!config) return;
    
    // 获取配置值
    CGFloat scale = [config[@"scale"] floatValue];
    CGFloat duration = [config[@"duration"] floatValue];
    CGFloat damping = [config[@"damping"] floatValue];
    
    // 应用弹簧动画缩放效果
    [UIView animateWithDuration:duration
                          delay:0
         usingSpringWithDamping:damping
          initialSpringVelocity:0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        tabBarButton.transform = CGAffineTransformMakeScale(scale, scale);
    } completion:nil];
}

// 移除视图上的缩放效果
- (void)removeScaleEffectOnView:(UIView *)view {
    if (!view) return;
    
    // 立即应用单位变换
    view.transform = CGAffineTransformIdentity;
}

@end
