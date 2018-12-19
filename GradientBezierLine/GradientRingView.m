

#import "GradientRingView.h"

@implementation GradientRingView
- (void)drawRect:(CGRect)rect {
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    CGFloat diameter = MIN(width, height);

    // 裁剪圆环
    UIBezierPath *bPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, diameter,diameter)];
    bPath.usesEvenOddFillRule = YES;
    CGFloat lineWidth = MAX(2, _lineWidth);
    UIBezierPath *bsPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(lineWidth, lineWidth, diameter - lineWidth * 2, diameter - lineWidth * 2)];
    [bPath appendPath:bsPath];
    [bPath addClip];
    
    CGFloat arcStep = (M_PI *2) / 360;
    BOOL clocklwise = NO;
    CGFloat x = CGRectGetWidth(rect) / 2;
    CGFloat y = CGRectGetHeight(rect) / 2;
    CGFloat radius = MIN(x, y) / 2;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(ctx, radius*2);
    for (CGFloat i = 0; i < 360; i+=1) {
        UIColor* c = [UIColor colorWithHue:i/360 saturation:1. brightness:1. alpha:1];
        CGContextSetStrokeColorWithColor(ctx, c.CGColor);
        CGFloat startAngle = i * arcStep;
        CGFloat endAngle = startAngle + arcStep + 0.02;
        CGContextAddArc(ctx, x, y, radius, startAngle, endAngle, clocklwise);
        CGContextStrokePath(ctx);
    }
}
@end
