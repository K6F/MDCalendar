//
//  MDCalendarViewController.m
//  MDCalendarDemo
//
//  Created by Michael Distefano on 5/23/14.
//  Copyright (c) 2014 Michael DiStefano
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "MDCalendarViewController.h"
#import "MDCalendar.h"
#import "NSDate+MDCalendar.h"
#import "UIColor+MDCalendarDemo.h"

@interface MDCalendarViewController () <MDCalendarDelegate>
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, assign) NSDate *firstDayOfStartMonth;
@property (nonatomic, strong) MDCalendar *calendarView;
@end

@implementation MDCalendarViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        MDCalendar *calendarView = [[MDCalendar alloc] init];
        
        calendarView.backgroundColor = [UIColor whiteColor];
        
        calendarView.lineSpacing = 0.f;
        calendarView.itemSpacing = 0.0f;
//        calendarView.borderColor = [UIColor mightySlate];
        calendarView.borderHeight = 1.f;
        calendarView.showsBottomSectionBorder = YES;
        
//        calendarView.textColor = [UIColor mightySlate];
//        calendarView.headerTextColor = [UIColor mightySlate];
//        calendarView.weekdayTextColor = [UIColor grandmasPillow];
        calendarView.cellBackgroundColor = [UIColor whiteColor];
        
        calendarView.highlightColor = [UIColor pacifica];
        calendarView.indicatorColor = [UIColor colorWithWhite:0.85 alpha:1.0];
        
        NSDate *startDate = [NSDate date];
        NSDate *endDate = [startDate dateByAddingMonths:12*25];
        
        calendarView.startDate = startDate;
        calendarView.endDate = endDate;
        calendarView.delegate = self;
        calendarView.canSelectDaysBeforeStartDate = NO;
        
        [self.view addSubview:calendarView];
        self.calendarView = calendarView;

        [calendarView setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSLayoutConstraint *calendarViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.calendarView
                                                                                        attribute:NSLayoutAttributeBottom
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:self.view
                                                                                        attribute:NSLayoutAttributeBottom
                                                                                       multiplier:1
                                                                                         constant:0];

        NSLayoutConstraint *calendarViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.calendarView
                                                                                        attribute:NSLayoutAttributeLeft
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:self.view
                                                                                        attribute:NSLayoutAttributeLeft
                                                                                       multiplier:1
                                                                                         constant:0];

        NSLayoutConstraint *calendarViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.calendarView
                                                                                        attribute:NSLayoutAttributeRight
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:self.view
                                                                                        attribute:NSLayoutAttributeRight
                                                                                       multiplier:1
                                                                                         constant:0];

        NSLayoutConstraint *calendarViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.calendarView
                                                                                       attribute:NSLayoutAttributeHeight
                                                                                       relatedBy:NSLayoutRelationEqual
                                                                                          toItem:nil
                                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                                      multiplier:1
                                                                                        constant:320];

        [self.view addConstraints:@[calendarViewBottomConstraint, calendarViewLeftConstraint, calendarViewRightConstraint, calendarViewHeightConstraint]];
        [self.view layoutIfNeeded];
    }
    return self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.view layoutIfNeeded];
}

#pragma mark - MDCalendarViewDelegate

- (void)calendarView:(MDCalendar *)calendar didSelectStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSLog(@"Selected Start Date: %@", [startDate descriptionWithLocale:[NSLocale currentLocale]]);
    NSLog(@"Selected End Date: %@", [endDate descriptionWithLocale:[NSLocale currentLocale]]);
}

- (void)calendarView:(MDCalendar *)calendarView didSelectDate:(NSDate *)date {
    NSLog(@"Selected Date: %@", [date descriptionWithLocale:[NSLocale currentLocale]]);
}

- (BOOL) calendarView:(MDCalendar *)calendarView shouldShowIndicatorForDate:(NSDate *)date
{
    // show indicator for every 4th day
    return [date day] % 4 == 1;
}

@end
