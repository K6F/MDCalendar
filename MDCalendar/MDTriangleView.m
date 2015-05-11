//
// Created by DanG on 5/11/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

#import "MDTriangleView.h"

@interface MDTriangleView()
@property (nonatomic) CGFloat red;
@property (nonatomic) CGFloat green;
@property (nonatomic) CGFloat blue;
@property (nonatomic) CGFloat colorAlpha;
@end
@implementation MDTriangleView {

}

-(instancetype)initWithColor:(UIColor *)color{
    self = [super initWithFrame:CGRectZero];
    if(self){
        [self setBackgroundColor:[UIColor clearColor]];
        CGFloat red;
        CGFloat green;
        CGFloat blue;
        CGFloat alpha;
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
        self.red = red;
        self.green = green;
        self.blue = blue;
        self.colorAlpha = alpha;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextBeginPath(ctx);
    CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));  // top left
    CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMaxY(rect));  // mid bottom
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));  // top right
    CGContextClosePath(ctx);

    CGContextSetRGBFillColor(ctx, self.red, self.green, self.blue, self.colorAlpha);
    CGContextFillPath(ctx);
}
@end