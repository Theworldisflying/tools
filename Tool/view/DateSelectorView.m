#import "DateSelectorView.h"

@interface DateSelectorView ()

@property (nonatomic, strong) UIPickerView *datePicker;
@property (nonatomic, strong) NSArray<NSString *> *years;
@property (nonatomic, strong) NSArray<NSString *> *months;

@property (nonatomic, assign) NSUInteger selectedYearIndex;
@property (nonatomic, assign) NSUInteger selectedMonthIndex;

@end

@implementation DateSelectorView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        [self setSelectedDate:[NSDate date]]; // 默认设置为当前日期
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 10.0f;
    self.clipsToBounds = YES;
    
    // 初始化数据源
    NSMutableArray<NSString *> *yearArray = [NSMutableArray array];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *currentDateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    NSUInteger currentYear = [currentDateComponents year];
    
    for (NSUInteger i = 2001; i <= currentYear; i++) {
        [yearArray addObject:[NSString stringWithFormat:@"%lu", (unsigned long)i]];
    }
    self.years = [yearArray copy];
    
    NSMutableArray<NSString *> *monthArray = [NSMutableArray array];
    for (NSUInteger i = 1; i <= 12; i++) {
        [monthArray addObject:[NSString stringWithFormat:@"%lu", (unsigned long)i]];
    }
    self.months = [monthArray copy];
    
    NSUInteger currentMonth = [currentDateComponents month];
    
    self.selectedYearIndex = currentYear - 2001;
    self.selectedMonthIndex = currentMonth - 1;
    
    // 创建UIPickerView
    self.datePicker = [[UIPickerView alloc] init];
    self.datePicker.delegate = self;
    self.datePicker.dataSource = self;
    [self addSubview:self.datePicker];
    
    // 创建顶部分割线
    UIView *topSeparator = [[UIView alloc] init];
    topSeparator.backgroundColor = RGBA(188,193,199,1);
    [self addSubview:topSeparator];
    
    // 创建取消按钮
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelButton setTitle:Localized(@"取消") forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
    
    // 创建中间分割线
    UIView *middleSeparator = [[UIView alloc] init];
    middleSeparator.backgroundColor = RGBA(188,193,199,1);
    [self addSubview:middleSeparator];
    
    // 创建确定按钮
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [doneButton setTitle:Localized(@"确定") forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:doneButton];
    
    [middleSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.centerX.equalTo(self);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(0.6);
    }];
    //
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(self);
        make.height.equalTo(middleSeparator);
        make.right.equalTo(middleSeparator.mas_left);
        
    }];
    [doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.height.equalTo(cancelButton);
        make.right.equalTo(self);
        make.left.equalTo(middleSeparator.mas_right);
    }];
    [topSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(self);
        make.bottom.equalTo(middleSeparator.mas_top);
        make.height.mas_equalTo(0.6);
    }];
    [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(self);
        make.top.equalTo(self).offset(20);
        make.bottom.equalTo(topSeparator.mas_top).offset(-10);
    }];
    
}
- (void)setSelectedDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:date];
    NSUInteger year = [components year];
    NSUInteger month = [components month];
    
    self.selectedYearIndex = year - 2001;
    self.selectedMonthIndex = month - 1;
    
    [self.datePicker selectRow:self.selectedYearIndex inComponent:0 animated:YES];
    [self.datePicker selectRow:self.selectedMonthIndex inComponent:1 animated:YES];
}
#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2; // Year, Month
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return (NSInteger)self.years.count;
        case 1:
            return (NSInteger)self.months.count;
        default:
            return 0;
    }
}

#pragma mark - UIPickerViewDelegate Methods

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = (UILabel *)view;
    if (!label) {
        label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:17];
        label.textColor = [UIColor blackColor]; // 设置文字颜色
    }
    
    NSString *text;
    switch (component) {
        case 0:
            text = self.years[row];
            break;
        case 1:
            text = self.months[row];
            break;
        default:
            text = @"";
            break;
    }
    
    label.text = text;
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        self.selectedYearIndex = row;
    } else if (component == 1) {
        self.selectedMonthIndex = row;
    }
}

#pragma mark - Button Actions

- (void)cancelAction:(id)sender {
    [self removeFromSuperview];
    self.didSelectDateBlock([NSDate date],0);
}

- (void)doneAction:(id)sender {
    NSString *selectedYearString = self.years[self.selectedYearIndex];
    NSString *selectedMonthString = self.months[self.selectedMonthIndex];
    
    NSUInteger year = [selectedYearString integerValue];
    NSUInteger month = [selectedMonthString integerValue];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = year;
    components.month = month;
    components.day = 1; // Set to the first day of the month
    NSDate *selectedDate = [calendar dateFromComponents:components];
    if (self.didSelectDateBlock) {
        self.didSelectDateBlock(selectedDate,1);
    }
    [self removeFromSuperview];
}

@end
