//
// Created by DanG on 5/11/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kMDCalendarHeaderViewIdentifier = @"kMDCalendarHeaderViewIdentifier";
static NSString * const kMDCalendarFooterViewIdentifier = @"kMDCalendarFooterViewIdentifier";

@interface MDCalendarHeaderView : UICollectionReusableView
@property (nonatomic, assign) NSDate *firstDayOfMonth;
@property (nonatomic, assign) BOOL    shouldShowYear;

@property (nonatomic, assign) UIFont  *font;
@property (nonatomic, assign) UIColor *textColor;

@property (nonatomic, assign) UIFont  *weekdayFont;
@property (nonatomic, assign) UIColor *weekdayTextColor;

+ (CGFloat)preferredHeightWithMonthLabelFont:(UIFont *)monthFont andWeekdayFont:(UIFont *)weekdayFont;
@end