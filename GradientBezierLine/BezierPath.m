
//  BezierPath.m

/*
 三次贝塞尔曲线
 pow((1-t), 3) * p0 + 3 * p1 * t * (pow((1-t),2)) + 3 * p2 * pow(t,2) * (1 - t) + p3*pow(t,3) ;
 
 */

#import "BezierPath.h"

@implementation BezierPathPoint

@end

@interface BezierPath (){
    CGPoint _startPoint ;
    CGPoint _endPoint ;
    CGPoint _controlPoint;
    
    
}
@end

@implementation BezierPath

- (instancetype)initWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint controlPoint:(CGPoint)controlPoint {

    if (self = [super init]) {
        _startPoint = startPoint;
        _endPoint = endPoint;
        _controlPoint = controlPoint;
    }
    return self;
}

- (NSArray *)bezierPointsWithCount:(NSInteger)pointCount {
    
    NSMutableArray *pointsArray = [NSMutableArray array];
    
    CGFloat startR;
    CGFloat startG;
    CGFloat startB;
    CGFloat startA;
    [_startColor getRed:&startR green:&startG blue:&startB alpha:&startA];
    
    CGFloat endR;
    CGFloat endG;
    CGFloat endB;
    CGFloat endA;
    [_endColor getRed:&endR green:&endG blue:&endB alpha:&endA];
    
    for (NSInteger index = 0; index <= pointCount; index ++) {
        CGFloat t = index/(pointCount * 1.0) ; //[0,1]
        
        t = [self uniformSpeedAtT:t];  //修正间隔
        
        // 二次贝塞尔曲线的方程
        NSInteger x = floor([self xAtT:t]);
        NSInteger y = floor((NSInteger)[self yAtT:t]);

        
        CGFloat xSpeed = [self xSpeedAtT:t];
        CGFloat ySpeed = [self ySpeedAtT:t];

        CGFloat r = (endR - startR) * t + startR;
        CGFloat g = (endG - startG) * t + startG;
        CGFloat b = (endB - startB) * t + startB;
        CGFloat a = (endA - startA) * t + startA;
        UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
        
        if (index + 1 <= pointCount) {
            CGFloat nextT = (index + 1)/(pointCount * 1.0);
            NSInteger nextX = floor([self xAtT:[self uniformSpeedAtT:nextT]]);
            NSInteger nextY = floor([self yAtT:[self uniformSpeedAtT:nextT]]);
            
            // 根据每个点于下个点的关系进行偏移取点，
            if (nextX != x || nextY != y) {
                BOOL xOffsetDirection = nextX > x;
                BOOL yOffsetDirection = nextY > y;
                
                NSInteger maxOffsetY = fabs((nextT - t) * ySpeed);
                NSInteger maxOffserX = fabs((nextT - t) * xSpeed);
                if (fabs(ySpeed) > 0) {
                    maxOffserX = floor(MIN(fabs(xSpeed)/fabs(ySpeed), maxOffserX)) + 1;
                } else {
                    maxOffserX = 0;
                }
                if (fabs(xSpeed) > 0) {
                    maxOffsetY = floor(MIN(fabs(xSpeed)/fabs(xSpeed), maxOffsetY)) + 1;
                } else {
                    maxOffsetY = 0;
                }
                
                //x方向上偏移
                for (NSInteger xIndex = -1; xIndex <= maxOffserX; xIndex ++) {
                    if (xIndex != 0 && nextY != y) {
                        NSInteger offsetX = x + xIndex * (xOffsetDirection ? 1 : -1);
                        BezierPathPoint *subPoint = [[BezierPathPoint alloc] init];
                        subPoint.point = CGPointMake(offsetX, y);
                        subPoint.color = color;
                        subPoint.isOffset = xIndex != 0;
                        [pointsArray addObject:subPoint];
                    }
                }

                //y方向上偏移
                for (NSInteger yIndex = -1; yIndex <= maxOffsetY; yIndex ++) {
                    NSInteger offsetY = y + yIndex * (yOffsetDirection ? 1 : -1);
                    if ((yIndex != 0 && nextX != x)) {
                        BezierPathPoint *subPoint = [[BezierPathPoint alloc] init];
                        subPoint.point = CGPointMake(x, offsetY);
                        subPoint.color = color;
                        subPoint.isOffset = yIndex != 0;
                        [pointsArray addObject:subPoint];
                    }
                }
            }
        }
        
        //计算出的关键点
        BezierPathPoint *subPoint = [[BezierPathPoint alloc] init];
        subPoint.point = CGPointMake(x, y);
        subPoint.color = color;
        [pointsArray addObject:subPoint];
        
    }
    return pointsArray;
}

- (CGFloat)legnth {
    return [self lengthWithT:1.0];
}

//矫正间隔
- (CGFloat)uniformSpeedAtT:(CGFloat)t {
    CGFloat totalLength = [self lengthWithT:1.0];
    CGFloat len = t*totalLength; //如果按照匀速增长,此时对应的曲线长度
    CGFloat t1=t, t2;
    do {
        t2 = t1 -([self lengthWithT:t1] - len)/[self speedAtT:t1];
        if(fabs(t1-t2)<0.001) break;
        t1=t2;
    }while(true);
    
    return t2;
}

//贝塞尔曲线长度计算，参数为整个线段的百分比[0.0,1.0];
//这个方法适合所有的曲线球长度
- (CGFloat)lengthWithT:(CGFloat)t{
    NSInteger totalStep = 1000;
    
    NSInteger stepCounts = (NSInteger)(totalStep * t);
    
    if(stepCounts & 1) stepCounts++;
    
    if(stepCounts==0) return 0.0;
    
    NSInteger halfCounts = stepCounts/2;
    CGFloat sum1=0.0, sum2=0.0;
    CGFloat dStep = (t * 1.0)/stepCounts;
    for(NSInteger i=0; i<halfCounts; i++) {
        sum1 += [self speedAtT:(2*i+1)*dStep];
    }
    
    for(NSInteger i=1; i<halfCounts; i++) {
        sum2 += [self speedAtT:(2*i)*dStep ];
    }
    
    return ([self speedAtT:0]+[self speedAtT:1]+2*sum2+4*sum1)*dStep/3.0;
}


//二次贝塞尔曲线的速度计算
// 三次或着多次的，需要调整
- (CGFloat)speedAtT:(CGFloat)t {
    CGFloat xSpeed = [self xSpeedAtT:t];
    CGFloat ySpeed = [self ySpeedAtT:t];
    CGFloat speed = sqrt(pow(xSpeed, 2) + pow(ySpeed, 2));
    return speed;
}

- (CGFloat)xSpeedAtT:(CGFloat)t {
    return 2 * (_startPoint.x + _endPoint.x - 2 * _controlPoint.x) * t + 2 * (_controlPoint.x - _startPoint.x);;
}

- (CGFloat)ySpeedAtT:(CGFloat)t {
    return 2 * (_startPoint.y + _endPoint.y - 2 * _controlPoint.y) * t + 2 * (_controlPoint.y - _startPoint.y);
}

- (CGFloat)xAtT:(CGFloat)t {
    CGFloat x = pow((1-t), 2) * _startPoint.x + 2 * (1-t)* t * _controlPoint.x + pow(t, 2) * _endPoint.x;
    return x;
}

- (CGFloat)yAtT:(CGFloat)t {
    CGFloat y = pow((1-t), 2) * _startPoint.y + 2 * (1-t) * t * _controlPoint.y + pow(t, 2) * _endPoint.y;
    return y;
}
@end
