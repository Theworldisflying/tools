//
//  NotificationManager.m
//  NexzDRIVER
//
//  Created by 瀚智科技 on 2025/6/2.
//

#import "NotificationManager.h"

@implementation NotificationManager {
    id _observer;
    SEL _selector;
    NSString *_name;
    id _object;
}

- (instancetype)initWithObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object {
    self = [super init];
    if (self) {
        _observer = observer;
        _selector = selector;
        _name = name;
        _object = object;
    }
    return self;
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:_observer selector:_selector name:_name object:_object];
    NSLog(@"Notification %@ registered.", _name);
}

- (void)unregisterNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:_observer name:_name object:_object];
    NSLog(@"Notification %@ unregistered.", _name);
}

@end
