//
// Created by DanG on 5/11/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kMDCalendarViewCellIdentifier = @"kMDCalendarViewCellIdentifier";

@interface MDCalendarViewCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView  *highlightView;
@property (nonatomic, strong) UIView  *borderView;
@property (nonatomic, strong) UIView  *indicatorView;

@property (nonatomic, assign) NSDate  *date;

@property (nonatomic, assign) UIFont  *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) UIColor *highlightColor;

@property (nonatomic, assign) CGFloat  borderHeight;
@property (nonatomic, assign) UIColor *borderColor;
@property (nonatomic, assign) UIColor *indicatorColor;

- (void)setSelectedBetweenRange:(BOOL)selected;
@end