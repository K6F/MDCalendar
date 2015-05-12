//
// Created by DanG on 5/11/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

#import "MDCalendarViewCell.h"
#import "NSDate+MDCalendar.h"

@implementation MDCalendarViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        self.label = label;

        UIView *highlightView = [[UIView alloc] initWithFrame:CGRectZero];
        highlightView.hidden = YES;
        self.highlightView = highlightView;

        UIView *bottomBorderView = [[UIView alloc] initWithFrame:CGRectZero];
        bottomBorderView.hidden = YES;
        self.borderView = bottomBorderView;

        UIView *indicatorView = [[UIView alloc] initWithFrame:CGRectZero];
        indicatorView.hidden = YES;
        self.indicatorView = indicatorView;

        [self.contentView addSubview:highlightView];
        [self.contentView addSubview:label];
        [self.contentView addSubview:bottomBorderView];
        [self.contentView addSubview:indicatorView];

        self.isAccessibilityElement = YES;
    }
    return self;
}

- (void)setDate:(NSDate *)date {
    _label.text = MDCalendarDayStringFromDate(date);

    self.accessibilityLabel = [NSString stringWithFormat:@"%@, %@ of %@ %@", [date weekdayString], [date dayOrdinalityString], [date monthString], @([date year])];
}

- (void)setFont:(UIFont *)font {
    _label.font = font;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    _label.textColor = textColor;
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    _highlightColor = highlightColor;
    _highlightView.backgroundColor = highlightColor;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderView.backgroundColor = borderColor;
    _borderView.hidden = NO;
}

- (void)setIndicatorColor:(UIColor *)indicatorColor {
    _indicatorView.backgroundColor = indicatorColor;
    _indicatorView.hidden = NO;
}

- (void)setSelected:(BOOL)selected {
    _label.textColor = selected ? self.backgroundColor : _textColor;
    if (selected) {
        self.backgroundColor = self.highlightColor;
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
    [super setSelected:selected];
}

-(void)setSelectedBetweenRange:(BOOL)selected{
    _label.textColor = selected ? self.backgroundColor : _textColor;
    if (selected) {
        self.backgroundColor = [_highlightColor colorWithAlphaComponent:.7];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
    [super setSelected:selected];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGSize viewSize = self.contentView.bounds.size;
    _label.frame = CGRectMake(0, _borderHeight, viewSize.width, viewSize.height - _borderHeight);

    // bounds of highlight view 10% smaller than cell
    CGFloat highlightViewInset = viewSize.height * 0.1f;
    _highlightView.frame = CGRectInset(self.contentView.frame, highlightViewInset, highlightViewInset);
    _highlightView.layer.cornerRadius = CGRectGetHeight(_highlightView.bounds) / 2;

    _borderView.frame = CGRectMake(0, 0, viewSize.width, _borderHeight);

    CGFloat dotInset = viewSize.height * 0.45f;
    CGRect indicatorFrame = CGRectInset(self.contentView.frame, dotInset, dotInset);
    indicatorFrame.origin.y = _highlightView.frame.origin.y + _highlightView.frame.size.height - indicatorFrame.size.height * 1.5;
    _indicatorView.frame = indicatorFrame;
    _indicatorView.layer.cornerRadius = CGRectGetHeight(_indicatorView.bounds) / 2;

}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.contentView.backgroundColor = nil;
    _label.text = @"";
}

#pragma mark - C Helpers

NSString * MDCalendarDayStringFromDate(NSDate *date) {
    return [NSString stringWithFormat:@"%d", (int)[date day]];
}

@end