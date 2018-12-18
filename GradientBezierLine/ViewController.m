//
//  ViewController.m
//  GradientBezierLine


#import "ViewController.h"
#import "GradientLine.h"

@interface ViewController () {
    CGPoint _startPoint ;
    CGPoint _endPoint ;
    CGPoint _controlPoint ;
    BOOL _shouldAddPointView;
}
@property (nonatomic, strong) UIImageView *imageView ;

@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) NSMutableArray *pointViewArray;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _startPoint = CGPointZero;
    _endPoint = CGPointZero;
    _controlPoint = CGPointZero;
    _shouldAddPointView = YES;
    
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.clearButton];
    [self.view addSubview:self.desLabel];
}
- (void)clearUp {
    _shouldAddPointView = YES;
    self.imageView.image = nil;
    _startPoint = CGPointZero;
    _endPoint = CGPointZero;
    _controlPoint = CGPointZero;
    [_pointViewArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _desLabel.text = @"连选三个点生成贝塞尔曲线";
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self.view];
    if (_shouldAddPointView) {
        [self addPointViewWithPoint:point];
    }
    
    if (CGPointEqualToPoint(_startPoint, CGPointZero)) {
        _startPoint = point;
        return;
    }
    
    if (CGPointEqualToPoint(_controlPoint, CGPointZero)) {
        _controlPoint = point;
        return;
    }
    
    if (CGPointEqualToPoint(_endPoint, CGPointZero)) {
        _endPoint = point;
        GradientLine * line = [[GradientLine alloc] initWithStartPoint:_startPoint controlPoint:_controlPoint endPoint:_endPoint];
        self.imageView.image = [line gradientLineWithStartColor:[UIColor redColor] endColor:[UIColor greenColor] size:self.imageView.frame.size];
        _desLabel.text = [NSString stringWithFormat:@"连选三个点生成贝塞尔曲线\n长度为：%f",[line lengthWithT:1.0]];
        _shouldAddPointView = NO;
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
- (NSMutableArray *)pointViewArray {
    if (!_pointViewArray) {
        _pointViewArray = [NSMutableArray array];
    }
    return _pointViewArray;
}
@end
