//
//  CustomTimer.m
//  NexzDRIVER
//
//  Created by 瀚智科技 on 2025/5/9.
//

#import "CustomTimer.h"

@interface CustomTimer ()
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation CustomTimer

#pragma mark - Block API

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                        repeats:(BOOL)repeats
                                         block:(CustomTimerBlock)block {
    CustomTimer *timerTool = [[self alloc] init];
    __weak typeof(timerTool) weakSelf = timerTool;

    timerTool.timer = [NSTimer timerWithTimeInterval:interval
                                              repeats:repeats
                                                block:^(NSTimer * _Nonnull timer) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && block) {
            block();
        }
    }];

    [[NSRunLoop currentRunLoop] addTimer:timerTool.timer forMode:NSDefaultRunLoopMode];
    return timerTool;
}

#pragma mark - Selector API

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                        target:(id)target
                                      selector:(SEL)selector
                                        repeats:(BOOL)repeats {
    CustomTimer *timerTool = [[self alloc] init];

    timerTool.timer = [NSTimer timerWithTimeInterval:interval
                                                target:target
                                              selector:selector
                                              userInfo:nil
                                               repeats:repeats];

    [[NSRunLoop currentRunLoop] addTimer:timerTool.timer forMode:NSDefaultRunLoopMode];
    return timerTool;
}

#pragma mark - 控制方法

- (void)stop {
    @synchronized (self) {
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
    }
}

#pragma mark - 释放资源

- (void)dealloc {
    [self stop];
}


//// 调用封装的类方法，延迟2秒执行exampleBlock，并保持运行3秒以确保操作完成
+ (void)executeAfterDelay:(NSTimeInterval)delay withBlock:(void (^)(void))block andKeepRunningFor:(NSTimeInterval)keepRunningTime {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (block) {
            block();
        }
        
        // 如果需要保持运行一段时间，则执行此段代码
        if (keepRunningTime > 0) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:keepRunningTime]];
        }
    });
}

@end
