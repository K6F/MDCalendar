//
// Created by DanG on 5/11/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MDCalendarWeekdaysView : UIView
@property (nonatomic, strong) NSArray *dayLabels;
@property (nonatomic, assign) UIColor *textColor;
@property (nonatomic, assign) UIFont  *font;

+ (CGFloat)preferredHeightWithFont:(UIFont *)font;
@end