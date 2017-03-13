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
}

@end

@implementation GradientLine
- (UIImage*)gradientLineWithStartPoint:(CGPoint)startPoint controlPoint:(CGPoint)controlPoint endPoint:(CGPoint)endPoint
							startColor:(UIColor *)startColor endColor:(UIColor *)endColor{

	_startPoint = startPoint;
	_controlPoint = controlPoint;
	_endPoint = endPoint;
	
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
	
	
	CAShapeLayer *layer = [self lineLayerWithStartPoint:startPoint controlPoint:controlPoint endPoint:endPoint];
	
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
//				NSLog(@"x: %d y:%d  %f",x,y,t);
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

- (CAShapeLayer *)lineLayerWithStartPoint:(CGPoint)startPoint controlPoint:(CGPoint)controlPoint endPoint:(CGPoint)endPoint {
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:startPoint];
	[path addQuadCurveToPoint:endPoint controlPoint:controlPoint];
	CGFloat maxX = MAX(startPoint.x, MAX(controlPoint.x, endPoint.x));
	CGFloat maxY = MAX(startPoint.y, MAX(controlPoint.y, endPoint.y));
	

	CAShapeLayer *layer = [[CAShapeLayer alloc] init];
	layer.bounds = CGRectMake(0, 0, maxX + 10, maxY + 10);
	layer.path = path.CGPath;
	layer.lineWidth = 1;
	layer.strokeColor = [UIColor redColor].CGColor;
	layer.fillColor = [UIColor clearColor].CGColor;

	return layer;
}

#pragma mark - 计算 t 值

- (float)conditionWithY:(float)y {
	
	float c = _startPoint.y - y;
	return  powf(_quadraticEquationB, 2) - 4 * _quadraticEquationA * c;
}
- (float)tAtPoint:(CGPoint)point {
	_quadraticEquationA = _startPoint.y - 2 * _controlPoint.y + _endPoint.y;
	_quadraticEquationB = 2 * _controlPoint.y - 2 * _startPoint.y;
	
	if (_quadraticEquationA != 0) {
		return [self quadraticEquationWithPoint:point];
	} else {
		return [self linearEquationWith:point.y];
	}
}

#pragma mark - 解方程
#pragma mark ---一元二次方程
- (float)quadraticEquationWithPoint:(CGPoint)point {
	float x = point.x;
	float y = point.y;
	
	float condition = [self conditionWithY:y];
	if (condition < 0) { // 没有t值
		// x 不变 y偏移
		for (int offsetY = -2; offsetY <= 2; offsetY ++) {
			y = point.y + offsetY;
			condition = [self conditionWithY:y];
			if (condition > 0) {
				break;
			}
			if (offsetY == 2) {
				return -1;
			}
		}
	}
	float t1 ;
	float t2 ;
	
	[self calTWithCondition:condition resultT1:&t1 resultT2:&t2];
	float t = [self betterTWithT1:t1 t2:t2 targetX:x];
	
	
	if (t >= 0 && t <= 1) {
		return t;
	} else { // t 值不在 [0,1]之间
		// 偏移 y
		float offsetYResultT = -1;
		int offsetY ;
		
		for (offsetY = -2; offsetY <= 2 ; offsetY ++ ) {
			int newY = y + offsetY;
			condition = [self conditionWithY:newY];
			
			if (condition > 0) {
				[self calTWithCondition:condition resultT1:&t1 resultT2:&t2];
				offsetYResultT = [self betterTWithT1:t1 t2:t2 targetX:x];
				
				if (offsetYResultT <= 0) {
					if ([self isNearbyTargetPoint:_startPoint x:x y:newY]) { // 起点附近
						return 0;
					}
				} else if (offsetYResultT >= 1) {
					if ([self isNearbyTargetPoint:_endPoint x:x y:newY]) { // 终点附近
						return 1;
					}
				} else {
					break;
				}
			}
		}
		
		// 偏移 x
		float offsetXResultT = -1;
		for (int offsetX = -2; offsetX <= 2; offsetX ++) {
			int newX = x + offsetX;
			[self calTWithCondition:condition  resultT1:&t1 resultT2:&t2];
			offsetXResultT = [self betterTWithT1:t1 t2:t2  targetX:x];
			if (t <= 0) {
				if ([self isNearbyTargetPoint:_startPoint x:newX y:y]) {
					return 0;
				}
			} else if (t >= 1) {
				if ([self isNearbyTargetPoint:_endPoint x:newX y:y]) {
					return 1;
				}
			} else {
				if (abs(offsetY) < abs(offsetY)) {
					return offsetYResultT;
				}
				return offsetXResultT;
			}
		}
	}

	return -1;
}

- (BOOL)isNearbyTargetPoint:(CGPoint)targetPoint x:(float)x y:(float)y{
	return fabs(x - targetPoint.x) < 3 && fabs(y - targetPoint.y) < 3;
}

- (void)calTWithCondition:(float)condition
				 resultT1:(float *)t1 resultT2:(float *)t2{
	*t1 = (-sqrtf(condition) - _quadraticEquationB)/(2 * _quadraticEquationA);
	*t2 = (sqrtf(condition) - _quadraticEquationB)/(2 * _quadraticEquationA);
}

- (float)betterTWithT1:(float)t1 t2:(float)t2
			   targetX:(float)x{
	float x1 = powf((1 - t1), 2) * _startPoint.x + 2 * t1 * (1 - t1) * _controlPoint.x + pow(t1, 2) * _endPoint.x;
	
	float x2 = powf((1 - t2), 2) * _startPoint.x + 2 * t2 * (1 - t2) * _controlPoint.x + pow(t2, 2) * _endPoint.x;
	//            NSLog(@"x:%f t1:%f t2:%f",x,t1,t2);
	if (fabs(x1 - x) < fabs(x2 - x)) {
		return t1;
	} else {
		return t2;
	}
}
#pragma mark ---一元一次方程
- (float)linearEquationWith:(float)y {
	float t = (-_startPoint.y - y)/_quadraticEquationB;
	if (t >= 0 && t <= 10) {
		return t;
	}
	return -1;
}
@end
