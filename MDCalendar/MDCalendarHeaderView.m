//
// Created by DanG on 5/11/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

#import "MDCalendarHeaderView.h"
#import "MDCalendarWeekdaysView.h"
#import "NSDate+MDCalendar.h"

@interface MDCalendarHeaderView ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) MDCalendarWeekdaysView *weekdaysView;
@end

static CGFloat const kMDCalendarHeaderViewMonthBottomMargin     = 10.f;
static CGFloat const kMDCalendarHeaderViewWeekdayBottomMargin  = 5.f;

@implementation MDCalendarHeaderView

+ (CGFloat)preferredHeightWithMonthLabelFont:(UIFont *)monthFont
                              andWeekdayFont:(UIFont *)weekdayFont{
    static CGFloat headerHeight;
    static dispatch_once_t onceTokenForHeaderViewHeight;
    dispatch_once(&onceTokenForHeaderViewHeight, ^{
        CGFloat monthLabelHeight = [self heightForMonthLabelWithFont:monthFont];
        CGFloat weekdaysViewHeight = [MDCalendarWeekdaysView preferredHeightWithFont:weekdayFont];
        CGFloat marginHeights = kMDCalendarHeaderViewMonthBottomMargin + kMDCalendarHeaderViewWeekdayBottomMargin;
        headerHeight = monthLabelHeight + weekdaysViewHeight + marginHeights;
    });
    return headerHeight;
}

+ (CGFloat)heightForMonthLabelWithFont:(UIFont *)font {
    static CGFloat monthLabelHeight;
    static dispatch_once_t onceTokenForMonthLabelHeight;

    dispatch_once(&onceTokenForMonthLabelHeight, ^{
        UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        monthLabel.textAlignment = NSTextAlignmentCenter;
        monthLabel.font = font;
        monthLabel.text = [[NSDate date] monthString];  // using current month as an example string
        monthLabelHeight = [monthLabel sizeThatFits:CGSizeZero].height;
    });

    return monthLabelHeight;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;

        MDCalendarWeekdaysView *weekdaysView = [[MDCalendarWeekdaysView alloc] initWithFrame:CGRectZero];
        [self addSubview:weekdaysView];
        self.weekdaysView = weekdaysView;

        [self addSubview:label];
        self.label = label;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGSize viewSize = self.bounds.size;
    _label.frame = CGRectMake(0, 0, viewSize.width, (viewSize.height / 3 * 2) - kMDCalendarHeaderViewMonthBottomMargin);
    _weekdaysView.frame = CGRectMake(0, CGRectGetMaxY(_label.frame) + kMDCalendarHeaderViewMonthBottomMargin, viewSize.width, viewSize.height - CGRectGetHeight(_label.bounds) - kMDCalendarHeaderViewWeekdayBottomMargin);
}

- (CGSize)sizeThatFits:(CGSize)size {
    static BOOL firstTime = YES;
    static CGSize calendarHeaderViewSize;
    if (firstTime) {
        calendarHeaderViewSize = CGSizeMake([super sizeThatFits:size].width, [MDCalendarHeaderView preferredHeightWithMonthLabelFont:self.font andWeekdayFont:self.weekdayFont]);
    }
    return calendarHeaderViewSize;
}

- (void)setFirstDayOfMonth:(NSDate *)firstDayOfMonth {
    _firstDayOfMonth = firstDayOfMonth;
    NSString *monthString = [firstDayOfMonth monthString];
    NSString *yearString = [NSString stringWithFormat:@" %d", (int)[firstDayOfMonth year]];
    _label.text = _shouldShowYear ? [monthString stringByAppendingString:yearString] : monthString;
}

- (void)setFont:(UIFont *)font {
    _label.font = font;
}

- (void)setTextColor:(UIColor *)textColor {
    _label.textColor = textColor;
}

- (void)setWeekdayFont:(UIFont *)weekdayFont {
    _weekdaysView.font = weekdayFont;
}

- (void)setWeekdayTextColor:(UIColor *)weekdayTextColor {
    _weekdaysView.textColor = weekdayTextColor;
}


@end