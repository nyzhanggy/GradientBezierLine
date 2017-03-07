iOS原生的渐变只支持线性的渐变，但有的时候我们需要沿曲线进行渐变。
先看下垂直线性渐变与沿曲线线性渐变的区别
![垂直线性渐变：颜色最亮的地方在曲线的最低点](http://upload-images.jianshu.io/upload_images/1681985-f5bea9e1d9f408f1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/500)
![沿曲线线性渐变：颜色最亮的地方在起点](http://upload-images.jianshu.io/upload_images/1681985-ba5176d179f77972.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/500)

那么先来分析一下这个问题：

1. 怎样绘制曲线？
对于贝塞尔曲线的绘制，系统提供了一系列的方法，同时我们已可以通过公式计算出一条贝塞尔曲线。

2. 如何保证颜色渐变？
找到曲线上的点，计算出每一个点的色值。

只要解决上面的问题就可以画出一条沿曲线线性渐变的贝塞尔曲线，曲线画起来还是比较简单的，但是这样计算出每一点的色值是一件比较麻烦的事情。

#### 1、贝塞尔曲线
这里先介绍一下贝塞尔曲线的一些东西，以二次贝塞尔曲线为例，先来动态感受一下绘制过程

![二次贝塞尔曲线](http://upload-images.jianshu.io/upload_images/1681985-ccdeca82b531935b.gif?imageMogr2/auto-orient/strip)

一条二次贝塞尔曲线需要三个点，A：起点  ；B：控制点；C：终点

![](http://upload-images.jianshu.io/upload_images/1681985-99b2322cd565b4c7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/520)

然后在AB上取点E，在BC上取点F 。使AD:AB = BE:BC

![第一次取点](http://upload-images.jianshu.io/upload_images/1681985-b7817ce6361f8792.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/520)

在DE上取点F，使DF:DE = AD:AB = BE:BC

![第二次取点](http://upload-images.jianshu.io/upload_images/1681985-9bbc8768a9703891.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/520)

F点就是贝塞尔曲线上的一个点，以此类推，取点一系列的点之后在ABC之间就产生了一条贝塞尔曲线

![贝塞尔曲线](http://upload-images.jianshu.io/upload_images/1681985-205360f03149489d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/520)

可以看出贝塞尔曲线上的每个点是有规律的，二次贝塞尔曲线的方程为
P0:起点；P1:控制点； P2:终点 ；t:百分比

![二次贝塞尔曲线的方程](http://upload-images.jianshu.io/upload_images/1681985-7ca7bcf2f8f69db2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
用OC表达的话就是这样的
```
CGFloat x = pow((1-t), 2) * _startPoint.x + 2 * (1-t) * t * _controlPoint.x + pow(t, 2) * _endPoint.x;
CGFloat y = pow((1-t), 2) * _startPoint.y + 2 * (1-t) * t * _controlPoint.y + pow(t, 2) * _endPoint.y;
```
#### 2、渐变色
既然已经一颗贝塞尔曲线的方程，那就可以操作曲线上的每一个点了，那怎么设置每一个点的颜色的。
###### 1、取点
对于取点还有一个问题需要注意，由于贝塞尔曲线并不是匀速变化的，所有如果均匀分割 t 来进行取点的话，取出来的点是不均匀的。不均匀的点会造成有的地方缺失点，形成空白。所以需要对 t 进行修正，取出间隔均匀的点。

![均匀间隔的 t ](http://upload-images.jianshu.io/upload_images/1681985-c44f1330c9988e71.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/520)

想要均匀的点，就需要线计算出曲线长度，接下来就使用[辛普森积分法](http://en.wikipedia.org/wiki/Simpson's_rule)来计算曲线的长度。这个求的是二次贝塞尔曲线的长度，如果需更高次的曲线，可修改一下修改。
```
//曲线长度
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
```

接下里就就开始矫正间隔了
```
//矫正间隔
- (CGFloat)uniformSpeedAtT:(CGFloat)t {
    CGFloat totalLength = [self lengthWithT:1.0];
    CGFloat len = t*totalLength; 
    CGFloat t1=t, t2;
    do {
        t2 = t1 -([self lengthWithT:t1] - len)/[self speedAtT:t1];
        if(fabs(t1-t2)<0.001) break;
        t1=t2;
    }while(true);
    return t2;
}
```
![矫正间隔的取点](http://upload-images.jianshu.io/upload_images/1681985-f7fc2ca282ca4dcf.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/520)

加上颜色，就是这样了

![均匀的渐变色点](http://upload-images.jianshu.io/upload_images/1681985-b8dd24f6ba9eb05a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/520)


接下来就是要去足够多的点来连成曲线了，这个取点的个数要根据具体情况来定，
考虑到线的边界问题，处理起来太费事了，要进行更多的色值计算

![曲线的边界](http://upload-images.jianshu.io/upload_images/1681985-aa32e0c761020036.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

我的做法是先按线段长度取点，然后再根据每个点的速度及方向进行上下左右偏移，得到一条宽度足够的线之后在进行mask裁剪。


![偏移得到足够宽的线](http://upload-images.jianshu.io/upload_images/1681985-0d116449a096c86b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/520)
![最终效果](http://upload-images.jianshu.io/upload_images/1681985-926b826a1ad02d08.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/520)


