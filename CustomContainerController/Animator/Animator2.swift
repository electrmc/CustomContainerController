//
//  Animator2.swift
//  CustomContainerController
//
//  Created by MiaoChao on 16/6/5.
//  Copyright © 2016年 MiaoChao. All rights reserved.
//

import UIKit

private let kDamping :CGFloat = 0.75
private let kInitialSpringVelocity :CGFloat = 0.5

class Animator2: NSObject,UIViewControllerAnimatedTransitioning {
    // MARK:UIViewControllerAnimatedTransitioning
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.75;
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        
        var toView :UIView?
        var fromView :UIView?
        if transitionContext.respondsToSelector(#selector(UIViewControllerTransitionCoordinatorContext.viewForKey(_:))) {
            toView = transitionContext.viewForKey(UITransitionContextToViewKey)
            fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
        } else {
            toView = toViewController?.view
            fromView = fromViewController?.view
        }
        
        let fromViewOriginX = transitionContext.initialFrameForViewController(fromViewController!).origin.x
        let toViewOriginX = transitionContext.initialFrameForViewController(toViewController!).origin.x
        let goingRight = fromViewOriginX < toViewOriginX
        
        let traveDistance = transitionContext.containerView()!.bounds.width + kDamping
        
        let trave :CGAffineTransform = CGAffineTransformMakeTranslation(goingRight ? traveDistance : -traveDistance , 0)
        transitionContext.containerView()?.addSubview(toView!)
        
        toView?.alpha = 0.1
        toView?.transform = CGAffineTransformInvert(trave)
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: kDamping, initialSpringVelocity: kInitialSpringVelocity, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            fromView?.transform = trave
            fromView?.alpha = 0
            toView?.transform = CGAffineTransformIdentity
            toView?.alpha = 1
        }) { (finish) -> Void in
            fromView?.transform = CGAffineTransformIdentity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled());
        }
    }
}
