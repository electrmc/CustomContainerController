//
//  Animator.swift
//  CustomContainerController
//
//  Created by MiaoChao on 16/5/20.
//  Copyright © 2016年 MiaoChao. All rights reserved.
//

import UIKit

class Animator: NSObject,UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.35
    }
    
    // 这个方法的作用：
    // 1，拿到三个view:fromView,toView,containerView。
    //    分别对应要消失控制器的view，要显示控制器的view，以及容器控制器上发生动画的视图，一般是fromView的父视图
    // 2，fromView和toView的结束frame以及其他动画效果
    // 3，把toView添加到containerView上
    // 4，执行动画，调用完成的block

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        
        transitionContext.containerView()?.addSubview(toViewController!.view)
        toViewController!.view.alpha = 0
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: { () -> Void in
            fromViewController!.view.transform = CGAffineTransformMakeScale(0.1, 0.1)
            toViewController!.view.alpha = 1
            }) { (finished) -> Void in
                fromViewController!.view.transform = CGAffineTransformIdentity
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }

}
