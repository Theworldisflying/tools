//
//  LoadingSpinnerView.m
//  NexzDRIVER
//
//  Created by 瀚智科技 on 2025/5/16.
//

#import "LoadingSpinnerView.h"

@implementation LoadingSpinnerView


- (instancetype)initWithFrame:(CGRect)frame style:(UIActivityIndicatorViewStyle)style {
    self = [super initWithFrame:frame];
    if (self) {
        // 创建并配置活动指示器
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        self.activityIndicator.hidesWhenStopped = YES;
        
        // 将活动指示器添加到视图中
        [self addSubview:self.activityIndicator];
        
        // 使用Masonry进行布局
        [self.activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.size.equalTo(self);
        }];
    }
    return self;
}

- (void)startAnimating {
    [self.activityIndicator startAnimating];
}

- (void)stopAnimating {
    [self.activityIndicator stopAnimating];
}

@end
