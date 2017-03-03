//
//  ViewController.m
//  GradientBezierLine


#import "ViewController.h"
#import "GradientBezierLine.h"
@interface ViewController (){
    
    CGPoint _startPoint ;
    CGPoint _endPoint ;
    CGPoint _controlPoint ;
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _startPoint = CGPointMake(20, 20);
    _endPoint = CGPointMake(20, 180);
    _controlPoint = CGPointMake(200, 280);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    GradientBezierLine *line = [[GradientBezierLine alloc] initWithFrame:CGRectMake(20, 80, 300, 300)];
    [line drawGradientBezierLineWithStrtPoint:_startPoint endPoint:_endPoint controlPoint:_controlPoint];
    
    [self.view addSubview:line];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
