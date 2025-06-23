//
//  DateSelectorView.h
//  NexzDRIVER
//
//  Created by 瀚智科技 on 2025/5/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DidSelectDateBlock)(NSDate *date,int type);

@interface DateSelectorView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, copy) DidSelectDateBlock didSelectDateBlock;
- (void)setSelectedDate:(NSDate *)date;

@end
NS_ASSUME_NONNULL_END
