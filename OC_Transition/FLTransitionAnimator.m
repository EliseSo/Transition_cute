//
//  FLTransitionAnimator.m
//  OC_Transition
//
//  Created by Fuzzie Liu on 16/3/21.
//  Copyright © 2016年 Fuzzie Liu. All rights reserved.
//

#import "FLTransitionAnimator.h"
#import <UIKit/UIKit.h>
#import "ViewController.h"


@interface FLTransitionAnimator()

@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

@end

@implementation FLTransitionAnimator

// 必须实现的两个协议方法
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

// 参数 : TransitionContext, 对象类型为id, 但遵守UIViewControllerContextTransitioning协议, 所以与转场有关方法查询该协议方法
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    // 获取到转场上下文, 以及需要用到的VC和View
    self.transitionContext = transitionContext;
    
    UIView *containerView = [transitionContext containerView];
    ViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    ViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIButton *button = fromVC.popBtn;
    
    // 转场效果的实现
    // 1. 先把结束控制器的视图加到containerView上
    [containerView addSubview:toVC.view];
    
    // 2. 创建CALayer的mask
    // mask的初始形状 -- 按button的frame画出的曲线
    UIBezierPath *circleMaskPathInitial = [UIBezierPath bezierPathWithOvalInRect:button.frame];
    // 确定extreme Point ---- 距离原点(button的center)最远的那个点,
    CGPoint extremePoint = CGPointMake(button.center.x, button.center.y - CGRectGetHeight(toVC.view.bounds));
    // 根据最远的那个点确定半径
    float radius = sqrtf((extremePoint.x * extremePoint.x) + (extremePoint.y * extremePoint.y));
    // 确定mask最终的形状
    UIBezierPath *circleMaskPathFinal = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(button.frame, -radius, -radius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = circleMaskPathFinal.CGPath; // 不太明白
    toVC.view.layer.mask = maskLayer;
    
    CABasicAnimation *maskLayerAnimation = [CABasicAnimation animation];
    // 当用一个C语言变量指针指向对象指针时, 需要用(__bridge id _Nullable)修饰做转换
    maskLayerAnimation.toValue = (__bridge id _Nullable)(circleMaskPathFinal.CGPath);
    maskLayerAnimation.fromValue = (__bridge id _Nullable)(circleMaskPathInitial.CGPath);
    maskLayerAnimation.duration = [self transitionDuration:transitionContext];
    maskLayerAnimation.delegate = self;
    [maskLayer addAnimation:maskLayerAnimation forKey:@"path"];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    // 当转场没有被取消, 则代表转场完成; 转场被取消, 则代表转场没有完成
    [self.transitionContext completeTransition:![self.transitionContext transitionWasCancelled]];
    [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.mask = nil;
}

@end
