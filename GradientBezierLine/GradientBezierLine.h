//
//  GradientBezierLine.h



#import <UIKit/UIKit.h>

@interface GradientBezierLine : UIImageView

- (void)drawGradientBezierLineWithStrtPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint controlPoint:(CGPoint)controlPoint;
@end
