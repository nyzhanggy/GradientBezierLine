//
//  GradientBezierLine.m

#import "GradientBezierLine.h"
#import "BezierPath.h"


#define Mask8(x) ( (x) & 0xFF)
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )
#define A(x) ( Mask8(x >> 24) )
#define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )

@interface GradientBezierLine () {
    
    CGFloat _lineWidth;
    UIColor *_startColor;
    UIColor *_endColor;
    NSMutableArray *_subPathArray;
}

@end

@implementation GradientBezierLine

- (void)drawGradientBezierLineWithStrtPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint controlPoint:(CGPoint)controlPoint
								 startColor:(UIColor *)startColor endColor:(UIColor *)endColor{
    BezierPath *creatPath = [[BezierPath alloc] initWithStartPoint:startPoint endPoint:endPoint controlPoint:controlPoint];
    creatPath.startColor =  startColor;
    creatPath.endColor = endColor;
    
    NSArray *pointsArray = [[creatPath bezierPointsWithCount:(NSInteger)creatPath.legnth] mutableCopy];
    
    
    self.image = [self pixelsImageWithPoints:pointsArray startColor:_startColor endColor:_endColor];


    
    CAShapeLayer * shapelayer = [CAShapeLayer layer];
    shapelayer.frame = self.bounds;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addQuadCurveToPoint:endPoint controlPoint:controlPoint];
    shapelayer.path = path.CGPath;
    
    _lineWidth = 1;
    
    shapelayer.lineWidth = _lineWidth;
    shapelayer.fillColor = [UIColor clearColor].CGColor;
    shapelayer.strokeColor = [UIColor whiteColor].CGColor;
    
    // 这里做蒙层
    [self.layer setMask:shapelayer];

}


- (UIImage *)pixelsImageWithPoints:(NSArray *)pointsArray startColor:(UIColor *)startColor endColor:(UIColor *)enColor{
    
    UInt32 *inputPixels;
    
    size_t w = CGRectGetWidth(self.frame);
    size_t h = CGRectGetHeight(self.frame);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSInteger bytesPerPixel = 4;
    NSInteger bitsPerComponent = 8;
    NSInteger bitmapBytesPerRow = w * bytesPerPixel;
    inputPixels = (UInt32 *)calloc(w * h , sizeof(UInt32));
    
    CGContextRef context = CGBitmapContextCreate(inputPixels, w, h, bitsPerComponent, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    for (NSInteger index = 0; index < pointsArray.count; index ++) {
        BezierPathPoint *pointValue = pointsArray[index];
        NSInteger offset =  pointValue.point.x + pointValue.point.y * w ;
        UInt32 *currentPixel = inputPixels + offset;
        
        CGFloat R;
        CGFloat G;
        CGFloat B;
        CGFloat A;
        [pointValue.color getRed:&R green:&G blue:&B alpha:&A];
        *currentPixel = RGBAMake((UInt32)(R * 255), (UInt32)(G * 255), (UInt32)(B * 255), (UInt32)(A * 255));
    }
    
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(inputPixels);
    
    return newImage;
}



@end
