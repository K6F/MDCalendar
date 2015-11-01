//
// Created by DanG on 5/11/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

#import "MDBubbleView.h"


@implementation MDBubbleView {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        [self setBackgroundColor:[UIColor blackColor]];
        [self.layer setCornerRadius:3.f];
        [self initComponents];
        [self addSubviews];
        [self setConstraints];
    }
    return self;
}

-(void)initComponents{
    _topLabel = [[UILabel alloc] init];
    [self.topLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.topLabel setTextAlignment:NSTextAlignmentCenter];
    [self.topLabel setTextColor:[UIColor whiteColor]];
    [self.topLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.f]];

    _bottomLabel = [[UILabel alloc] init];
    [self.bottomLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.bottomLabel setTextAlignment:NSTextAlignmentCenter];
    [self.bottomLabel setTextColor:[UIColor whiteColor]];
    [self.bottomLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:10.f]];
}

-(void)addSubviews{
    [self addSubview:self.topLabel];
    [self addSubview:self.bottomLabel];
}

-(void)setConstraints{
    [self setTopLabelConstraints];
    [self setBottomLabelConstraints];
}

-(void)setTopLabelConstraints{
    NSLayoutConstraint *topLabelLeftConstraint = [NSLayoutConstraint constraintWithItem:self.topLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:5];
    NSLayoutConstraint *topLabelRightConstraint = [NSLayoutConstraint constraintWithItem:self.topLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-5];
    NSLayoutConstraint *topLabelBottomConstraint = [NSLayoutConstraint constraintWithItem:self.topLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self addConstraints:@[topLabelBottomConstraint, topLabelLeftConstraint, topLabelRightConstraint]];
}

-(void)setBottomLabelConstraints{
    NSLayoutConstraint *bottomLabelLeftConstraint = [NSLayoutConstraint constraintWithItem:self.bottomLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:5];
    NSLayoutConstraint *bottomLabelRightConstraint = [NSLayoutConstraint constraintWithItem:self.bottomLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-5];
    NSLayoutConstraint *bottomLabelTopConstraint = [NSLayoutConstraint constraintWithItem:self.bottomLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self addConstraints:@[bottomLabelTopConstraint, bottomLabelLeftConstraint, bottomLabelRightConstraint]];
}
@end