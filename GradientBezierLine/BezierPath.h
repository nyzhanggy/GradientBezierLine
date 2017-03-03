//
//  BezierPath.h



#import <UIKit/UIKit.h>



@interface BezierPathPoint : NSObject
@property (nonatomic,assign) CGPoint point;
@property (nonatomic,strong) UIColor *color;
@property (nonatomic,assign) CGFloat t;
@property (nonatomic,assign) BOOL isOffset;
@end


@interface BezierPath : NSObject
@property (nonatomic,strong) UIColor *startColor;
@property (nonatomic,strong) UIColor *endColor;
- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint controlPoint:(CGPoint)controlPoint;
- (NSArray *)bezierPointsWithCount:(NSInteger)pointCount;
- (CGFloat)legnth;
- (double)uniformSpeedAtT:(CGFloat)t;
- (CGFloat)xSpeedAtT:(CGFloat)t;
- (CGFloat)ySpeedAtT:(CGFloat)t;
@end
