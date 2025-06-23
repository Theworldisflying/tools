//
//  CustomTimer.h
//  NexzDRIVER
//
//  Created by 瀚智科技 on 2025/5/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^CustomTimerBlock)(void);

@interface CustomTimer : NSObject

/// Block 方式创建定时器
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                        repeats:(BOOL)repeats
                                         block:(CustomTimerBlock)block;

/// Selector 方式创建定时器
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                        target:(id)target
                                      selector:(SEL)selector
                                        repeats:(BOOL)repeats;

/// 手动停止定时器
- (void)stop;

//
+ (void)executeAfterDelay:(NSTimeInterval)delay withBlock:(void (^)(void))block andKeepRunningFor:(NSTimeInterval)keepRunningTime;

@end

NS_ASSUME_NONNULL_END
