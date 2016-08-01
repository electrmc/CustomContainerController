//
//  PercentDrivenInteractiveTransition.swift
//  CustomContainerController
//
//  Created by MiaoChao on 16/7/14.
//  Copyright © 2016年 MiaoChao. All rights reserved.
//

import UIKit

class PercentDrivenInteractiveTransition: NSObject,UIViewControllerInteractiveTransitioning {
    weak var containerTransitionContext:PrivateTransitionContext?
    
    func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let context = transitionContext as? PrivateTransitionContext {
            containerTransitionContext = context
            containerTransitionContext?.animationInteractiveTransition()
        }
    }
    
    func updateInteractiveTransition(percentComplete: CGFloat) {
        containerTransitionContext?.updateInteractiveTransition(percentComplete)
    }
    
    func finishInteractiveTransition() {
        containerTransitionContext?.finishInteractiveTransition()
    }
    
    func cancelInteractiveTransition() {
        containerTransitionContext?.cancelInteractiveTransition()
    }
}
