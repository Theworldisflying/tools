//
//  RootWinTool.m
//  NexzDRIVER
//
//  Created by 瀚智科技 on 2025/5/15.
//

#import "RootWinTool.h"

@implementation RootWinTool
+(UIViewController *)topMostViewController {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (!window) return nil;
    
    return [self topMostViewControllerFromViewController:window.rootViewController];
}

+(UIViewController *)topMostViewControllerFromViewController:(UIViewController *)viewController {
    if (!viewController) return nil;

    // 检查是否是容器控制器
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)viewController;
        return [self topMostViewControllerFromViewController:navController.topViewController];
    } else if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)viewController;
        return [self topMostViewControllerFromViewController:tabBarController.selectedViewController];
    } else if (viewController.presentedViewController) {
        return [self topMostViewControllerFromViewController:viewController.presentedViewController];
    }

    // 如果都不是，则返回当前控制器
    return viewController;
}

@end
