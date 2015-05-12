//
// Created by DanG on 5/11/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

#import "MDCalendarFooterView.h"

@interface MDCalendarFooterView ()
@property (nonatomic, strong) UIView *bottomBorder;
@end

@implementation MDCalendarFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *bottomBorderView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:bottomBorderView];
        self.bottomBorder = bottomBorderView;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _bottomBorder.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), _borderHeight);
}

- (void)setBorderColor:(UIColor *)borderColor {
    _bottomBorder.backgroundColor = borderColor;
}

@end