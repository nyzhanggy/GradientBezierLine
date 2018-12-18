//
//  NextVC.m
//  GradientBezierLine
//
//  Created by zhanggy on 2018/4/24.
//  Copyright © 2018年 Ive. All rights reserved.
//

#import "NextVC.h"
#import "GradientLine.h"

@interface NextVC (){
    CGPoint _startPoint ;
    CGPoint _controlPoint1 ;
    CGPoint _middlePoint ;
    CGPoint _controlPoint2;
    CGPoint _endPoint;
    BOOL _shouldAddPointView;
}
@property (nonatomic, strong) UIImageView *imageView ;
@property (nonatomic, strong) UIImageView *imageViewNext;

@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) NSMutableArray *pointViewArray;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;
@end

@implementation NextVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    _startPoint = CGPointZero;
    _endPoint = CGPointZero;
    _controlPoint1 = CGPointZero;
    _controlPoint2 = CGPointZero;
    _middlePoint = CGPointZero;
    _shouldAddPointView = YES;
    
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.imageViewNext];
    [self.view addSubview:self.clearButton];
    [self.view addSubview:self.desLabel];
}

- (void)clearUp {
    self.imageView.image = nil;
    self.imageViewNext.image = nil;
    _startPoint = CGPointZero;
    _endPoint = CGPointZero;
    _controlPoint1 = CGPointZero;
    _controlPoint2 = CGPointZero;
    _middlePoint = CGPointZero;
    _shouldAddPointView = YES;
    
    _desLabel.text = @"选择起始点";
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self.view];
    if (_shouldAddPointView) {
        [self addPointViewWithPoint:point];
    }
    
    if (CGPointEqualToPoint(_startPoint, CGPointZero)) {
        _startPoint = point;
        _desLabel.text = @"选择中间点";
        return;
    }
    
    if (CGPointEqualToPoint(_middlePoint, CGPointZero)) {
        _middlePoint = point;
        _desLabel.text = @"选择控制点";
        return;
    }
    
    // 控制点为一对关于中间点对称的点，不然做出来的曲线会有明显的转折点。
    if (CGPointEqualToPoint(_controlPoint1, CGPointZero)) {
        _controlPoint1 = point;
        // _controlPoint2 是 _controlPoint1 关于 _middlePoint 的对称点
        _controlPoint2 = CGPointMake(2 * _middlePoint.x - _controlPoint1.x, 2 * _middlePoint.y - _controlPoint1.y);
        [self addPointViewWithPoint:_controlPoint2];
        _desLabel.text = @"选择结束点";
        return;
    }

    if (CGPointEqualToPoint(_endPoint, CGPointZero)) {
        _endPoint = point;
        GradientLine * line1 = [[GradientLine alloc] initWithStartPoint:_startPoint controlPoint:_controlPoint1 endPoint:_middlePoint];
        GradientLine * line2 = [[GradientLine alloc] initWithStartPoint:_middlePoint controlPoint:_controlPoint2 endPoint:_endPoint];
        
        UIColor *startColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
        UIColor *endColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
        
        CGFloat lineLength1 = [line1 lengthWithT:1.0] ;
        CGFloat lineLength2 = [line2 lengthWithT:1.0];
        CGFloat totalLineLength =  lineLength1 + lineLength2;
        
        UIColor *middleColor = [UIColor colorWithRed:1 - (lineLength1/totalLineLength) green:lineLength1/totalLineLength blue:0 alpha:1];
        
        self.imageView.image = [line1 gradientLineWithStartColor:startColor endColor:middleColor size:self.imageView.frame.size];
        
        self.imageViewNext.image = [line2 gradientLineWithStartColor:middleColor endColor:endColor size:self.imageView.frame.size];

        _desLabel.text = [NSString stringWithFormat:@"线段总长度为：%f",totalLineLength];
        _shouldAddPointView = NO;
        
        [_pointViewArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
}

- (void)addPointViewWithPoint:(CGPoint)point {
    UIView *pointView = [[UIView alloc] initWithFrame:CGRectMake(point.x - 5, point.y - 5, 10, 10)];
    pointView.layer.cornerRadius = 5;
    pointView.clipsToBounds = YES;
    pointView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:pointView];
    [self.pointViewArray addObject:pointView];
}
#pragma mark - setter && getter

- (UIButton *)clearButton {
    if (!_clearButton) {
        _clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _clearButton.frame = CGRectMake(20, CGRectGetHeight(self.view.bounds) - 60, CGRectGetWidth(self.view.bounds) - 40, 40);
        _clearButton.backgroundColor = [UIColor lightGrayColor];
        [_clearButton setTitle:@"clear" forState:UIControlStateNormal];
        [_clearButton addTarget:self action:@selector(clearUp) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearButton;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    }
    return _imageView;
}
- (UIImageView *)imageViewNext {
    if (!_imageViewNext) {
        _imageViewNext = [[UIImageView alloc] initWithFrame:self.view.bounds];
    }
    return _imageViewNext;
}

- (NSMutableArray *)pointViewArray {
    if (!_pointViewArray) {
        _pointViewArray = [NSMutableArray array];
    }
    return _pointViewArray;
}

@end
