//
//  FLNavigationDelegate.m
//  OC_Transition
//
//  Created by Fuzzie Liu on 16/3/21.
//  Copyright © 2016年 Fuzzie Liu. All rights reserved.
//

#import "FLNavigationDelegate.h"
#import <UIKit/UIKit.h>
#import "FLTransitionAnimator.h"
#import "ViewController.h"

@interface FLNavigationDelegate ()<UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UINavigationController *navigationController;
@property (strong, nonatomic) UIPercentDrivenInteractiveTransition *interactiveController;

@end

@implementation FLNavigationDelegate

// 拖拽的转场动画
- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    return self.interactiveController;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    [self.navigationController.view addGestureRecognizer:panGesture];
}

- (void)panned: (UIPanGestureRecognizer *)panGesture{
    // 每一个Case都要大括号分隔开(不知道为什么, 否则会编译不成功)
    switch (panGesture.state) {
        // Case 1. 手势开始, 初始化一个UIPercentDrivenInteractiveTransition实例对象, 设置为属性
        //判断导航控制器中有几层, 只有一层就代表push; 不是一层就pop当前的这层
        case UIGestureRecognizerStateBegan:{
//            NSLog(@"pan ======== began");
            self.interactiveController = [[UIPercentDrivenInteractiveTransition alloc] init];
            if (self.navigationController.viewControllers.count > 1) {
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self.navigationController.topViewController performSegueWithIdentifier:@"PushSegue" sender:nil];
            }
            break;
        }
        
        // Case 2. 手势变化----代表在拖动过程中的位置变化, 根据位移判断转场动画进行到什么程度(completionProgress)
        case UIGestureRecognizerStateChanged:{
            CGPoint translation = [panGesture translationInView:self.navigationController.view];
            // 算出绝对值, 这样左右滑都可以转场
            CGFloat completionProgress = sqrtf((translation.x * translation.x)) / self.navigationController.view.bounds.size.width;
            [self.interactiveController updateInteractiveTransition:completionProgress];
            
//            NSLog(@"%@", NSStringFromCGPoint(translation));
            
            break;
        }
        
        // Case 3. 手势结束----两种情况: 划到屏幕外(速度不为零); 手势停止(速度为零)
        case UIGestureRecognizerStateEnded:{
            CGPoint velocity = [panGesture velocityInView:self.navigationController.view];
            if (velocity.x == 0) {
                [self.interactiveController cancelInteractiveTransition];
            }else{
                [self.interactiveController finishInteractiveTransition];
            }
            break;
        }
            
        default:
            [self.interactiveController cancelInteractiveTransition];
            self.interactiveController = nil;
            break;
    }
}




// 点击按钮的转场动画
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    return [FLTransitionAnimator new];
}

@end
