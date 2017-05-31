//
//  ViewController.m
//  GradientBezierLine


#import "ViewController.h"
#import "GradientBezierLine.h"
#import "GradientLine.h"

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
	
    _controlPoint = CGPointMake(200, 280);
	
	_endPoint = CGPointMake(20, 180);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    GradientBezierLine *line = [[GradientBezierLine alloc] initWithFrame:CGRectMake(0, 20, 150, 300)];
    [line drawGradientBezierLineWithStrtPoint:_startPoint endPoint:_endPoint controlPoint:_controlPoint startColor:[UIColor redColor] endColor:[UIColor yellowColor]];
    
    [self.view addSubview:line];
	
	
	
	UIImage *image = [[[GradientLine alloc] init] gradientLineWithStartPoint:_startPoint controlPoint:_controlPoint endPoint:_endPoint startColor:[UIColor redColor] endColor:[UIColor yellowColor] size:CGSizeMake(150, 300)];
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(150, 20, image.size.width, image.size.height)];
	imageView.image = image;
	
	[self.view addSubview:imageView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
