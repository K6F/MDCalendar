//
//  NSDate+MDCalendar.m
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

#import "NSDate+MDCalendar.h"

@implementation NSDate (MDCalendar)

+ (NSInteger)numberOfDaysInMonth:(NSInteger)month forYear:(NSInteger)year {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [NSDateComponents new];
    [components setMonth:month];
    [components setYear:year];
    NSDate *date = [calendar dateFromComponents:components];
    
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return range.length;
}

+ (NSDate *)dateFromComponents:(NSDateComponents *)components {
    return MDCalendarDateFromComponents(components);
}

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSArray *languages = [userDefaults objectForKey:@"AppleLanguages"];
        NSString *localization = languages.firstObject;
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:localization];
    });
    
    return dateFormatter;
}

+ (NSArray *)weekdays {
    return [self dateFormatter].standaloneWeekdaySymbols;
}

+ (NSArray *)weekdayAbbreviations {
    return [self dateFormatter].shortStandaloneWeekdaySymbols;
}

+ (NSArray *)monthNames {
    return [self dateFormatter].standaloneMonthSymbols;
}

+ (NSArray *)shortMonthNames {
    return [self dateFormatter].shortStandaloneMonthSymbols;
}

- (NSDate *)firstDayOfMonth {
    NSDateComponents *components = MDCalendarDateComponentsFromDate(self);
    [components setDay:1];
    return MDCalendarDateFromComponents(components);
}

- (NSDate *)lastDayOfMonth {
    NSDateComponents *components = MDCalendarDateComponentsFromDate(self);
    
    NSInteger month = [components month];
    [components setMonth:month+1];
    [components setDay:0];
    
    return MDCalendarDateFromComponents(components);
}

- (NSInteger)day {
    NSDateComponents *components = MDCalendarDateComponentsFromDate(self);
    return [components day];
}

- (NSString *)dayOrdinalityString {
    return MDAppendOrdinalityToNumber([self day]);
}

- (NSString *)weekdayString {
    return [NSDate weekdays][self.weekday - 1];
}

- (NSInteger)weekday {
    NSDateComponents *components = MDCalendarDateComponentsFromDate(self);
    return [components weekday];
}

- (NSInteger)month {
    NSDateComponents *components = MDCalendarDateComponentsFromDate(self);
    return [components month];
}

- (NSString *)monthString {
    return [NSDate monthNames][[self month] - 1];
}

- (NSString *)shortMonthString {
    return [NSDate shortMonthNames][[self month] - 1];
}

- (NSInteger)year {
    NSDateComponents *components = MDCalendarDateComponentsFromDate(self);
    return [components year];
}

- (NSDateComponents *)components {
    return MDCalendarDateComponentsFromDate(self);
}

- (NSInteger)numberOfDaysInMonth {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *firstDayOfMonth = [self firstDayOfMonth];
    NSDate *lastDayOfMonth  = [self lastDayOfMonth];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:firstDayOfMonth toDate:lastDayOfMonth options:0];
    return [components day];
}

- (NSInteger)numberOfMonthsUntilEndDate:(NSDate *)endDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitMonth fromDate:self toDate:endDate options:0];
    
    return [components month];
}

- (NSInteger)numberOfDaysUntilEndDate:(NSDate *)endDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:self toDate:endDate options:0];
    return [components day];
}

- (NSDate *)dateByAddingDays:(NSInteger)days {
    
    NSDateComponents *components = [NSDateComponents new];
    components.day = days;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (NSDate *)dateByAddingMonths:(NSInteger)months {
    NSDateComponents *components = [NSDateComponents new];
    components.month = months;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

- (BOOL)isEqualToDateSansTime:(NSDate *)otherDate {
    if (self.day == otherDate.day &&
        self.month == otherDate.month &&
        self.year == otherDate.year) {
        return YES;
    }
    return NO;
}

- (BOOL)isBeforeDate:(NSDate *)otherDate {
    return [self compare:otherDate] == NSOrderedAscending;
}

- (BOOL)isAfterDate:(NSDate *)otherDate {
    return [self compare:otherDate] == NSOrderedDescending;
}


#pragma mark - Helpers

NSDateComponents * MDCalendarDateComponentsFromDate(NSDate *date) {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfYear|NSCalendarUnitWeekday|NSCalendarUnitDay fromDate:date];
}

NSDate * MDCalendarDateFromComponents(NSDateComponents *components) {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateFromComponents:components];
}

NSString * MDAppendOrdinalityToNumber(NSInteger number) {
    NSString *ordinalityString = @"";
    NSInteger lastDigit = number % 10;
    
    NSString * (^appendOrdinalityBlock)(NSString *ordinality) = ^NSString *(NSString *ordinality){
        return [NSString stringWithFormat:@"%d%@", (int)number, ordinality];
    };
    
    if (number > 10 && number < 20) {
        ordinalityString = appendOrdinalityBlock(@"th");
    } else if (lastDigit == 0) {
        ordinalityString = appendOrdinalityBlock(@"th");
    } else if (lastDigit == 1) {
        ordinalityString = appendOrdinalityBlock(@"st");
    } else if (lastDigit == 2) {
        ordinalityString = appendOrdinalityBlock(@"nd");
    } else if (lastDigit == 3) {
        ordinalityString = appendOrdinalityBlock(@"rd");
    } else {
        ordinalityString = appendOrdinalityBlock(@"th");
    }
    
    return ordinalityString;
}

@end
