//
//  Animator1.swift
//  CustomContainerController
//
//  Created by MiaoChao on 16/7/18.
//  Copyright © 2016年 MiaoChao. All rights reserved.
//

import UIKit

class Animator1: NSObject,UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval{
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let fromController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        
        var toView :UIView!
        var fromView :UIView!
        if transitionContext.respondsToSelector(#selector(UIViewControllerTransitionCoordinatorContext.viewForKey(_:))) {
            toView = transitionContext.viewForKey(UITransitionContextToViewKey)
            fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
        } else {
            toView = toController?.view
            fromView = fromController?.view
        }
        
        transitionContext.containerView()?.addSubview(toView)
        
        let toViewFinishFrame = transitionContext.finalFrameForViewController(toController!)
        let fromViewFinishFrame = transitionContext.finalFrameForViewController(fromController!)

        toView.frame = transitionContext.initialFrameForViewController(toController!)
        fromView.frame = transitionContext.initialFrameForViewController(fromController!)
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
            toView.frame = toViewFinishFrame
            fromView.frame = fromViewFinishFrame
        }) { (finish) in
            print("animator finish")
            
            fromView.transform = CGAffineTransformIdentity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}
