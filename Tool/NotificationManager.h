//
//  NotificationManager.h
//  NexzDRIVER
//
//  Created by 瀚智科技 on 2025/6/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NotificationManager : NSObject
- (instancetype)initWithObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object;
- (void)registerNotification;
- (void)unregisterNotification;
@end

NS_ASSUME_NONNULL_END
