//
//  YBTimer.h
//  NexzDRIVER
//
//  Created by 瀚智科技 on 2025/6/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YBTimer : NSObject

@property (nonatomic, assign, readonly, getter=isRunning) BOOL running;
@property (nonatomic, assign, readonly, getter=isSuspended) BOOL suspended;
// 
- (instancetype)init NS_UNAVAILABLE;
/// 创建并立即启动一个定时器（默认在主线程执行）
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                       repeats:(BOOL)repeats
                                        handler:(void (^)(void))handler;

/// 创建一个定时器，需手动调用 -start 方法启动（默认在全局并发队列执行）
+ (instancetype)timerWithTimeInterval:(NSTimeInterval)interval
                              repeats:(BOOL)repeats
                               handler:(void (^)(void))handler;

/// 创建一个定时器，指定执行队列
+ (instancetype)timerWithTimeInterval:(NSTimeInterval)interval
                              repeats:(BOOL)repeats
                                 queue:(dispatch_queue_t _Nullable)queue
                               handler:(void (^)(void))handler;

/// 初始化方法（指定重复次数）
- (instancetype)initWithTimeInterval:(NSTimeInterval)interval
                            maxfires:(NSUInteger)maxfires
                               queue:(dispatch_queue_t _Nullable)queue
                             handler:(void (^)(void))handler NS_DESIGNATED_INITIALIZER;

/// 初始化方法（是否重复）
// 辅助初始化器
- (instancetype)initWithTimeInterval:(NSTimeInterval)interval
                              repeats:(BOOL)repeats
                               queue:(dispatch_queue_t _Nullable)queue
                             handler:(void (^)(void))handler;

/// 启动定时器
- (void)start;

/// 停止并释放定时器
- (void)invalidate;

/// 暂停定时器
- (void)suspend;

/// 恢复定时器
- (void)resume;

@end

NS_ASSUME_NONNULL_END
