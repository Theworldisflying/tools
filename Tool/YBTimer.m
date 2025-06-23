//
//  YBTimer.m
//  NexzDRIVER
//
//  Created by 瀚智科技 on 2025/6/3.
//

#import "YBTimer.h"

@implementation YBTimer {
    dispatch_source_t _timerSource;
    NSUInteger _fireCount;
    NSUInteger _maxFires;
    BOOL _isSuspended;
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)interval
                            maxfires:(NSUInteger)maxfires
                               queue:(dispatch_queue_t _Nullable)queue
                             handler:(void (^)(void))handler {
    self = [super init];
    if (self) {
        _maxFires = maxfires;
        _fireCount = 0;
        _isSuspended = NO;
        
        dispatch_queue_t targetQueue = queue ?: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        _timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, targetQueue);
        if (_timerSource) {
            dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC));
            dispatch_source_set_timer(_timerSource, start, (int64_t)(interval * NSEC_PER_SEC), 0);
            
            dispatch_source_set_event_handler(_timerSource, ^{
                if (handler) {
                    handler();
                }
                
                self->_fireCount++;
                if (self->_maxFires > 0 && self->_fireCount >= self->_maxFires) {
                    [self invalidate];
                }
            });
        }
    }
    return self;
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)interval
                              repeats:(BOOL)repeats
                               queue:(dispatch_queue_t _Nullable)queue
                             handler:(void (^)(void))handler {
    return [self initWithTimeInterval:interval maxfires:repeats ? 0 : 1 queue:queue handler:handler];
}

- (void)start {
    if (_timerSource) {
        dispatch_resume(_timerSource);
    }
}

- (void)invalidate {
    if (_timerSource) {
        dispatch_source_cancel(_timerSource);
        _timerSource = nil;
        _isSuspended = NO;
    }
}

- (void)suspend {
    if (_timerSource) {
        dispatch_suspend(_timerSource);
        _isSuspended = YES;
    }
}

- (void)resume {
    if (_timerSource) {
        dispatch_resume(_timerSource);
        _isSuspended = NO;
    }
}

- (BOOL)isRunning {
    return _timerSource != nil;
}

- (BOOL)isSuspended {
    return _isSuspended;
}

#pragma mark - Class Methods

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                       repeats:(BOOL)repeats
                                        handler:(void (^)(void))handler {
    YBTimer *timer = [[self alloc] initWithTimeInterval:interval repeats:repeats queue:dispatch_get_main_queue() handler:handler];
    [timer start];
    return timer;
}

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)interval
                              repeats:(BOOL)repeats
                               handler:(void (^)(void))handler {
    return [self timerWithTimeInterval:interval repeats:repeats queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) handler:handler];
}

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)interval
                              repeats:(BOOL)repeats
                                 queue:(dispatch_queue_t _Nullable)queue
                               handler:(void (^)(void))handler {
    return [[self alloc] initWithTimeInterval:interval repeats:repeats queue:queue handler:handler];
}

-(void)sample{
//    示例 1：重复执行的定时器（主线程）
    [YBTimer scheduledTimerWithTimeInterval:1.0
                                    repeats:YES
                                     handler:^{
                                         NSLog(@"Timer fired (repeating)");
                                     }];
//    示例 2：执行 5 次后停止
    YBTimer *time = [[YBTimer alloc] initWithTimeInterval:2.0
                                               maxfires:5
                                                  queue:dispatch_get_main_queue()
                                                handler:^{
                                                    NSLog(@"Fired 5 times");
                                                }];
    [time start];
//    示例 3：暂停与恢复
    YBTimer *timer = [[YBTimer alloc] initWithTimeInterval:1.0
                                               maxfires:10
                                                  queue:dispatch_get_main_queue()
                                                handler:^{
                                                    NSLog(@"Timer fired");
                                                }];
    [timer start];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [timer suspend];
        NSLog(@"Timer suspended");
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [timer resume];
        NSLog(@"Timer resumed");
    });
}

@end
