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
        [self initComponents];
        [self addSubviews];
        [self setConstraints];
    }
    return self;
}

-(void)initComponents{
    self.bottomBorder = [[UIView alloc] init];
    [self.bottomBorder setTranslatesAutoresizingMaskIntoConstraints:NO];
}

-(void)addSubviews{
    [self addSubview:self.bottomBorder];
}

-(void)setConstraints{
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.bottomBorder attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.bottomBorder attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.bottomBorder attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.bottomBorder attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.borderHeight];
    [self addConstraints:@[leftConstraint, rightConstraint, topConstraint, heightConstraint]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bottomBorder.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), self.borderHeight);
}

- (void)setBorderColor:(UIColor *)borderColor {
    self.bottomBorder.backgroundColor = borderColor;
}

@end