//
//  UINavigationController+StatusBar.m
//  NexzDRIVER
//
//  Created by 瀚智科技 on 2025/6/3.
//

#import "UINavigationController+StatusBar.h"

@implementation UINavigationController (StatusBar)
- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.topViewController preferredStatusBarStyle]; // 传递当前顶部控制器样式
}
@end
