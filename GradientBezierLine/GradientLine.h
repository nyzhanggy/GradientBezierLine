//
//  GradientLine.h
//  GradientBezierLine
//

#import <UIKit/UIKit.h>

@interface GradientLine : NSObject
- (instancetype)initWithStartPoint:(CGPoint)startPoint controlPoint:(CGPoint)controlPoint endPoint:(CGPoint)endPoint;
- (UIImage*)gradientLineWithStartColor:(UIColor *)startColor endColor:(UIColor *)endColor size:(CGSize)size;
- (CGFloat)lengthWithT:(CGFloat)t;
@end
