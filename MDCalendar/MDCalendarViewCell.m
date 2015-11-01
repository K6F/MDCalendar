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
        self.isAccessibilityElement = YES;
        [self initComponents];
        [self addSubviews];
    }
    return self;
}

-(void)initComponents{
    self.label = [[UILabel alloc] init];
    [self.label setTextAlignment:NSTextAlignmentCenter];
    [self.label setAdjustsFontSizeToFitWidth:YES];

    self.highlightView = [[UIView alloc] init];
    [self.highlightView setHidden:YES];

    self.borderView = [[UIView alloc] init];
    [self.borderView setHidden:YES];

    self.indicatorView = [[UIView alloc] init];
    [self.indicatorView setHidden:YES];
}

-(void)addSubviews{
    [self.contentView addSubview:self.highlightView];
    [self.contentView addSubview:self.label];
    [self.contentView addSubview:self.borderView];
    [self.contentView addSubview:self.indicatorView];
}

- (void)setDate:(NSDate *)date {
    self.label.text = [self mdCalendarDayStringFromDate:date];
    self.accessibilityLabel = [NSString stringWithFormat:@"%@, %@ of %@ %@", [date weekdayString], [date dayOrdinalityString], [date monthString], @([date year])];
}

- (void)setFont:(UIFont *)font {
    self.label.font = font;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.label.textColor = textColor;
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    _highlightColor = highlightColor;
    self.highlightView.backgroundColor = highlightColor;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderView.backgroundColor = borderColor;
    self.borderView.hidden = NO;
}

- (void)setIndicatorColor:(UIColor *)indicatorColor {
    _indicatorView.backgroundColor = indicatorColor;
    self.indicatorView.hidden = NO;
}

- (void)setSelected:(BOOL)selected {
    self.label.textColor = selected ? self.backgroundColor : self.textColor;
    if (selected) {
        self.backgroundColor = self.highlightColor;
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
    [super setSelected:selected];
}

-(void)setSelectedBetweenRange:(BOOL)selected{
    self.label.textColor = selected ? self.backgroundColor : self.textColor;
    if (selected) {
        self.backgroundColor = [self.highlightColor colorWithAlphaComponent:.7];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
    [super setSelected:selected];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGSize viewSize = self.contentView.bounds.size;
    self.label.frame = CGRectMake(0, self.borderHeight, viewSize.width, viewSize.height - self.borderHeight);

    // bounds of highlight view 10% smaller than cell
    CGFloat highlightViewInset = viewSize.height * 0.1f;
    self.highlightView.frame = CGRectInset(self.contentView.frame, highlightViewInset, highlightViewInset);
    self.highlightView.layer.cornerRadius = CGRectGetHeight(self.highlightView.bounds) / 2;
    self.borderView.frame = CGRectMake(0, 0, viewSize.width, self.borderHeight);

    CGFloat dotInset = viewSize.height * 0.45f;
    CGRect indicatorFrame = CGRectInset(self.contentView.frame, dotInset, dotInset);
    indicatorFrame.origin.y = self.highlightView.frame.origin.y + self.highlightView.frame.size.height - indicatorFrame.size.height * 1.5f;

    self.indicatorView.frame = indicatorFrame;
    self.indicatorView.layer.cornerRadius = CGRectGetHeight(self.indicatorView.bounds) / 2;

}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.contentView.backgroundColor = nil;
    self.label.text = @"";
}

-(NSString *) mdCalendarDayStringFromDate:(NSDate *)date {
    return [NSString stringWithFormat:@"%i", [date day]];
}

@end