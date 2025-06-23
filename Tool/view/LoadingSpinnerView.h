//
//  LoadingSpinnerView.h
//  NexzDRIVER
//
//  Created by 瀚智科技 on 2025/5/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoadingSpinnerView : UIView
- (instancetype)initWithFrame:(CGRect)frame style:(UIActivityIndicatorViewStyle)style;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
- (void)startAnimating;

- (void)stopAnimating;
@end

NS_ASSUME_NONNULL_END
