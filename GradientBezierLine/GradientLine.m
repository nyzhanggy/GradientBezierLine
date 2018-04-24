//
//  GradientLine.m
//  GradientBezierLine
//

#import "GradientLine.h"

@interface GradientLine () {
    
    CGPoint _startPoint;
    CGPoint _controlPoint;
    CGPoint _endPoint;
    
    float _quadraticEquationA;
    float _quadraticEquationB;
    
    CGFloat _lineWidth;
    CGPoint _vertexPoint;
}

@end

@implementation GradientLine
- (instancetype)initWithStartPoint:(CGPoint)startPoint controlPoint:(CGPoint)controlPoint endPoint:(CGPoint)endPoint {
    if (self = [super init]) {
        _startPoint = startPoint;
        _controlPoint = controlPoint;
        _endPoint = endPoint;
    }
    return self;
}
- (UIImage*)gradientLineWithStartColor:(UIColor *)startColor endColor:(UIColor *)endColor size:(CGSize)size {

    _lineWidth = 5;
    
    CGFloat startR;
    CGFloat startG;
    CGFloat startB;
    CGFloat startA;
    [startColor getRed:&startR green:&startG blue:&startB alpha:&startA];
    
    CGFloat endR;
    CGFloat endG;
    CGFloat endB;
    CGFloat endA;
    [endColor getRed:&endR green:&endG blue:&endB alpha:&endA];
    
    
    CAShapeLayer *layer = [self lineLayerWithStartPoint:_startPoint controlPoint:_controlPoint endPoint:_endPoint size:size];
    
    float scale = [UIScreen mainScreen].scale;
    // 分配内存
    const int imageWidth = layer.bounds.size.width * scale;
    const int imageHeight = layer.bounds.size.height * scale;
    size_t    bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)calloc(imageWidth * imageHeight, sizeof(UInt32));
    
    // 创建context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(context,0,imageHeight);
    CGContextScaleCTM(context, 1, -1);
    CGContextScaleCTM(context, scale,scale);
    
    
    [layer renderInContext:context];
    
    
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    
    for (int i = 0; i < pixelNum; i++, pCurPtr++) {
        int x = i%imageWidth;
        int y = i/imageWidth;
        if (*pCurPtr !=  0xFFFFFFFF && *pCurPtr != 0x00000000) {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            float t = [self tAtPoint:CGPointMake(x/scale, y/scale)];
            if (t == -1) {
                ptr[0] = 0;
                ptr[1] = 0 ;
                ptr[2] = 0 ;
                ptr[3] = 0 ;
            } else {
                float v = (ptr[3]*1.0)/255.0;
                CGFloat r = (endR - startR) * t + startR;
                CGFloat g = (endG - startG) * t + startG;
                CGFloat b = (endB - startB) * t + startB;
                CGFloat a = (endA - startA) * t + startA;
                
                ptr[0] = a * 255 * v;
                ptr[1] = b * 255 ;
                ptr[2] = g * 255 ;
                ptr[3] = r * 255 ;
            }
        }
    }
    
    // 将内存转成image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight,ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,NULL, true, kCGRenderingIntentDefault);
    
    CGDataProviderRelease(dataProvider);
    
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    
    // 释放
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // free(rgbImageBuf) 创建dataProvider时已提供释放函数，这里不用free
    return resultUIImage;
    
}

void ProviderReleaseData (void *info, const void *data, size_t size)
{
    free((void*)data);
}

- (CAShapeLayer *)lineLayerWithStartPoint:(CGPoint)startPoint controlPoint:(CGPoint)controlPoint endPoint:(CGPoint)endPoint size:(CGSize)size{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addQuadCurveToPoint:endPoint controlPoint:controlPoint];
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.bounds = CGRectMake(0, 0, size.width, size.height);
    layer.path = path.CGPath;
    layer.lineWidth = _lineWidth;
    layer.strokeColor = [UIColor redColor].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    
    return layer;
}

#pragma mark - 计算 t 值
- (float)tAtPoint:(CGPoint)point {
    return [self quadraticEquationWithPoint:point];
}

#pragma mark - 解方程
#pragma mark ---一元二次方程
- (float)quadraticEquationWithPoint:(CGPoint)point  {
    // 两个方向上都算一下，取一下最优的
    float baseOnXT = [self baseOnXWithPoint:point];
    float baseOnYT = [self baseOnYWithPoint:point];
    float t = [self betterRWithRs:@[@(baseOnXT),@(baseOnYT)] targetPoint:point];
    if (t == -1) {
        // 如果不在线上，可以认为是顶点位置。从两个方向上的顶点位置取一个最优的。
        float xVertex = [self tForYAtVertexPoint];
        float yVertex = [self tForYAtVertexPoint];
        t = [self betterRWithRs:@[@(xVertex),@(yVertex)] targetPoint:point];
    }
    return t;
}
// 根据 x 计算 t
- (float)baseOnXWithPoint:(CGPoint)point {
    float a = _startPoint.x - 2 * _controlPoint.x + _endPoint.x;
    float b = 2 * _controlPoint.x - 2 * _startPoint.x;
    float c = _startPoint.x - point.x;
    float condition = pow(b, 2) - 4 * a * c;
    if (a != 0 ) {
        if (condition >= 0) {
            NSArray *r = [self quadraticEquationWithA:a b:b c:c];
            if (r && r.count > 0) {
                float t = [self betterRWithRs:r targetPoint:point];
                return t;
            }
        }
    } else {
        // 一元一次方程求解
        float t = (-c)/b;
        return t;
    }
    return -1;
}

// 根据 y 计算 t
- (float)baseOnYWithPoint:(CGPoint)point {
    float a = _startPoint.y - 2 * _controlPoint.y + _endPoint.y;
    float b = 2 * _controlPoint.y - 2 * _startPoint.y;
    float c = _startPoint.y - point.y;
    float condition = pow(b, 2) - 4 * a * c;
    if ( a != 0) {
        if (condition >= 0) {
            NSArray *r = [self quadraticEquationWithA:a b:b c:c];
            if (r && r.count > 0) {
                float t = [self betterRWithRs:r targetPoint:point];
                return t;
            }
        }
    } else {
        // 一元一次方程求解
        float t = (-c)/b;
        return t;
    }
    
    return -1;
}
// 筛选结果
- (float)betterRWithRs:(NSArray *)rs targetPoint:(CGPoint)point{
    CGFloat distance = NSNotFound;
    NSInteger betterIndex = -1;
    for (NSInteger i = 0; i < rs.count; i ++) {
        float t = [[rs objectAtIndex:i] floatValue];
        if (t == -1) {
            continue;
        }
        CGFloat x = [self xAtT:t];
        CGFloat y = [self yAtT:t];
        if (distance == NSNotFound) {
            distance = [self distanceWithPoint:CGPointMake(x, y) point1:point];
            betterIndex = i;
            
        } else {
            if (distance > [self distanceWithPoint:CGPointMake(x, y) point1:point]) {
                distance = [self distanceWithPoint:CGPointMake(x, y) point1:point];
                betterIndex = i;
            }
        }
        
    }
    if (betterIndex == -1) {
        return -1;
    }
    float t = [rs[betterIndex] floatValue];
    if (t >= 1) {
        if ([self isNearbyTargetPoint:_endPoint x:point.x y:point.y]) {
            return 1;
        } else {
            return -1;
        }
    }
    
    if (t <= 0) {
        if ([self isNearbyTargetPoint:_startPoint x:point.x y:point.y]) {
            return 0;
        } else {
            return -1;
        }
    }
    return [rs[betterIndex] floatValue];
}

// 一元二次方程的求根公式
- (NSArray *)quadraticEquationWithA:(float)a b:(float)b c:(float)c {
    float condition = pow(b, 2) - 4 * a * c;
    if (condition >= 0) {
        float r1 = (-sqrtf(condition) - b)/(2 * a);
        float r2 = (sqrtf(condition) - b)/(2 * a);
        return @[@(r1),@(r2)];
    }
    return nil;
    
}

// 计算两个点的距离
- (float)distanceWithPoint:(CGPoint)point point1:(CGPoint)point1 {
    return  sqrt(pow(point.x - point1.x, 2) + pow(point.y - point1.y, 2));
}

// 判断两个点是否接近,参考值为线宽
- (BOOL)isNearbyTargetPoint:(CGPoint)targetPoint x:(float)x y:(float)y{
    return fabs(x - targetPoint.x) <= ceil(_lineWidth) && fabs(y - targetPoint.y) <= ceil(_lineWidth) ;
}
#pragma mark - 贝塞尔曲线的相关计算公式
#pragma mark ---计算点的速度
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

#pragma mark ---根据T计算点的位置
- (CGFloat)xAtT:(CGFloat)t {
    CGFloat x = pow((1-t), 2) * _startPoint.x + 2 * (1-t)* t * _controlPoint.x + pow(t, 2) * _endPoint.x;
    return x;
}

- (CGFloat)yAtT:(CGFloat)t {
    CGFloat y = pow((1-t), 2) * _startPoint.y + 2 * (1-t) * t * _controlPoint.y + pow(t, 2) * _endPoint.y;
    return y;
}
#pragma mark ---计算顶点相关
- (CGPoint)yVertexPoint {
    CGFloat t = [self tForYAtVertexPoint];
    if (t >= 0 && t <= 1) {
        CGFloat x = [self xAtT:t];
        CGFloat y = [self yAtT:t];
        
        return CGPointMake(x, y);
    }
    return CGPointZero;
}

- (CGPoint)XVertexPoint {
    CGFloat t = [self tForXAtVertexPoint];
    if (t >= 0 && t <= 1) {
        CGFloat x = [self xAtT:t];
        CGFloat y = [self yAtT:t];
        return CGPointMake(x, y);
    }
    return CGPointZero;
}

- (CGFloat)tForYAtVertexPoint {
    CGFloat t = (_startPoint.y - _controlPoint.y)/(_startPoint.y + _endPoint.y - 2 * _controlPoint.y);
    return t;
}
- (CGFloat)tForXAtVertexPoint {
    CGFloat t = (_startPoint.x - _controlPoint.x)/(_startPoint.x + _endPoint.x - 2 * _controlPoint.x);
    return t;
}
#pragma mark ---曲线长度
- (CGFloat)lengthWithT:(CGFloat)t {
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

@end

