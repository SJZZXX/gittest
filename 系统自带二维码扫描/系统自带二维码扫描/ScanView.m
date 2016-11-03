//
//  ScanView.m
//  系统自带二维码扫描
//
//  Created by 周少文 on 15/9/3.
//  Copyright (c) 2015年 ZheJiangWangHang. All rights reserved.
//

#import "ScanView.h"

@implementation ScanView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        //添加闪光灯按钮
        self.flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_flashBtn setTitle:@"开启闪光灯" forState:UIControlStateNormal];
        [_flashBtn setTitle:@"关闭闪光灯" forState:UIControlStateSelected];
        _flashBtn
        .frame = CGRectMake([UIScreen mainScreen].bounds.size.width -20-120, 20, 120, 50);
        [self addSubview:_flashBtn];
        //添加从系统选择照片按钮
//        self.selectImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_selectImageBtn setTitle:@"打开系统相册" forState:UIControlStateNormal];
//        _selectImageBtn.frame = CGRectMake(_flashBtn.frame.origin.x+_flashBtn.frame.size.width+20, _flashBtn.frame.origin.y, 120, 40);
        [self addSubview:_selectImageBtn];
        [self createScanLine];
        
    }
    
    return self;
}
/**
 *  layoutSubviews在以下情况下会被调用：
 1、init初始化不会触发layoutSubviews
 2、addSubview会触发layoutSubviews
 3、设置view的Frame会触发layoutSubviews，当然前提是frame的值设置前后发生了变化
 4、滚动一个UIScrollView会触发layoutSubviews
 5、旋转Screen会触发父UIView上的layoutSubviews事件
 6、改变一个UIView大小的时候也会触发SuperView上的layoutSubviews事件

 */
- (void)layoutSubviews
{
    NSLog(@"layoutSubviews");
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(scanLineAnimation) userInfo:nil repeats:YES];
    [timer fire];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    //填充一块灰色的半透明背景
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:0.5].CGColor);
    CGContextFillRect(context, [UIScreen mainScreen].bounds);
    //画矩形方框
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 0.8);
    CGRect clearRect = CGRectMake([UIScreen mainScreen].bounds.size.width/2.0-100, [UIScreen mainScreen].bounds.size.height/2.0-100, 200, 200);
    CGContextAddRect(context, clearRect);
    CGContextStrokePath(context);
    //设置某个rect范围的背景为透明
    CGContextClearRect(context, clearRect
                       );
    
    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextSetLineWidth(context, 2);
    //CGPoint points[],将两个点放在一个{}里面.
    //画左上角
    CGPoint topLeftPointA[] = {CGPointMake(clearRect.origin.x+0.7, clearRect.origin.y),CGPointMake(clearRect.origin.x+0.7, clearRect.origin.y+15)};
    CGContextAddLines(context, topLeftPointA, 2);
    
    CGPoint topLeftPointB[] = {CGPointMake(clearRect.origin.x, clearRect.origin.y+0.7),CGPointMake(clearRect.origin.x+15, clearRect.origin.y+0.7)};
    CGContextAddLines(context, topLeftPointB, 2);
    //画右上角
    CGPoint topRightPointA[] = {CGPointMake(clearRect.origin.x+clearRect.size.width -15, clearRect.origin.y+0.7),CGPointMake(clearRect.origin.x+clearRect.size.width, clearRect.origin.y+0.7)};
    CGContextAddLines(context, topRightPointA, 2);
    CGPoint topRightPointB[] = {CGPointMake(clearRect.origin.x+clearRect.size.width-0.7, clearRect.origin.y),CGPointMake(clearRect.origin.x+clearRect.size.width-0.7, clearRect.origin.y+15)};
    CGContextAddLines(context, topRightPointB, 2);
    //画左下角
    CGPoint bottomLeftPointA[] = {CGPointMake(clearRect.origin.x, clearRect.origin.y+clearRect.size.height-0.7),CGPointMake(clearRect.origin.x+15, clearRect.origin.y+clearRect.size.height-0.7)};
    CGContextAddLines(context, bottomLeftPointA, 2);
    CGPoint bottomLeftPointB[] = {CGPointMake(clearRect.origin.x+0.7, clearRect.origin.y+clearRect.size.height),CGPointMake(clearRect.origin.x+0.7, clearRect.origin.y+clearRect.size.height-15)};
    CGContextAddLines(context, bottomLeftPointB, 2);
    //画右下角
    CGPoint bottomRightPointA[] = {CGPointMake(clearRect.origin.x+clearRect.size.width-0.7, clearRect.origin.y+clearRect.size.height-15),CGPointMake(clearRect.origin.x+clearRect.size.width-0.7, clearRect.origin.y+clearRect.size.height)};
    CGContextAddLines(context, bottomRightPointA, 2);
    CGPoint bottomRightPointB[] = {CGPointMake(clearRect.origin.x+clearRect.size.width-15, clearRect.origin.y+clearRect.size.height-0.7),CGPointMake(clearRect.origin.x+clearRect.size.width, clearRect.origin.y+clearRect.size.height-0.7)};
    CGContextAddLines(context, bottomRightPointB, 2);
    CGContextStrokePath(context);
}

- (void)createScanLine
{
    CGRect clearRect = CGRectMake([UIScreen mainScreen].bounds.size.width/2.0-100, [UIScreen mainScreen].bounds.size.height/2.0-100, 200, 200);
    
    _scanLine = [CALayer layer];
    _scanLine.frame = CGRectMake(clearRect.origin.x, clearRect.origin.y, clearRect.size.width, 2);
    _scanLine.backgroundColor = [UIColor redColor].CGColor;
    [self.layer addSublayer:_scanLine];
}

- (void)scanLineAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.translation.y";
    animation.duration = 1.5;
    animation.fromValue = @(0);
    animation.toValue = @(200);
    //设置匀速
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    //设置这个属性之后动画不会瞬间返回原位置,而是通过动画的形式原路返回
    //animation.autoreverses = YES;
    [_scanLine addAnimation:animation forKey:@"basicAnimation"];
}
//移除一个动画
// [_scanLine removeAnimationForKey:@"basicAnimation"];

@end
