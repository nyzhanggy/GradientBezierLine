//
//  GradientLine.h
//  GradientBezierLine
//

#import <UIKit/UIKit.h>

@interface GradientLine : NSObject
- (UIImage*)gradientLineWithStartPoint:(CGPoint)startPoint controlPoint:(CGPoint)controlPoint endPoint:(CGPoint)endPoint
							startColor:(UIColor *)startColor endColor:(UIColor *)endColor;
@end
