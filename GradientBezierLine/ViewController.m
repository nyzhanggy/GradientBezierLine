//
//  ViewController.m
//  GradientBezierLine


#import "ViewController.h"
#import "GradientLine.h"

@interface ViewController () {
    CGPoint _startPoint ;
    CGPoint _endPoint ;
    CGPoint _controlPoint ;
}
@property (nonatomic, strong) UIImageView *imageView ;
@property (nonatomic, strong) UILabel *desLabel;
@property (nonatomic, strong) UIButton *clearButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _startPoint = CGPointZero;
    _endPoint = CGPointZero;
    _controlPoint = CGPointZero;
    
    
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.clearButton];
    [self.view addSubview:self.desLabel];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清除" style:UIBarButtonItemStylePlain target:self action:@selector(clearUp)];
    
    
}
- (void)clearUp {
    self.imageView.image = nil;
    _startPoint = CGPointZero;
    _endPoint = CGPointZero;
    _controlPoint = CGPointZero;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self.view];
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
        UIImage *image = [[[GradientLine alloc] init] gradientLineWithStartPoint:_startPoint controlPoint:_controlPoint endPoint:_endPoint startColor:[UIColor blueColor] endColor:[UIColor yellowColor] size:self.view.frame.size];
        self.imageView.image = image;
    }
}

#pragma mark - setter && getter
- (UILabel *)desLabel {
    if (!_desLabel) {
        _desLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, CGRectGetWidth(self.view.frame), 30)];
        _desLabel.textColor = [UIColor lightGrayColor];
        _desLabel.textAlignment = NSTextAlignmentCenter;
        _desLabel.font = [UIFont systemFontOfSize:12];
        _desLabel.text = @"连选三个点生成贝塞尔曲线";
    }
    return _desLabel;
}
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

@end
