//
//  PrivateTransitionContext.swift
//  CustomContainerController
//
//  Created by MiaoChao on 16/5/12.
//  Copyright © 2016年 MiaoChao. All rights reserved.
//

import UIKit

class PrivateTransitionContext: NSObject, UIViewControllerContextTransitioning{
    unowned private var privateContainerView :UIView
    private var viewControllers: [String : UIViewController]
    private var appearingFromRect: CGRect
    private var disappearingFromRect: CGRect
    private var appearingToRect: CGRect
    private var disappearingToRect: CGRect
    private var privatePresentationStyle: UIModalPresentationStyle //UIModalPresentationStyle
    
    var completionBlock :((Bool)->())?
    var animated :Bool?
    var interactive :Bool?
    
    init(fromViewController: UIViewController, toViewController: UIViewController, goingRight: Bool) {
        self.viewControllers = [UITransitionContextFromViewControllerKey:fromViewController,
            UITransitionContextToViewControllerKey:toViewController]
        self.privatePresentationStyle = UIModalPresentationStyle.Custom
        self.privateContainerView = fromViewController.view.superview!
        // Set the view frame properties which make sense in our specialized ContainerViewController context. Views appear from and disappear to the sides, corresponding to where the icon buttons are positioned. So tapping a button to the right of the currently selected, makes the view disappear to the left and the new view appear from the right. The animator object can choose to use this to determine whether the transition should be going left to right, or right to left, for example.
        let travelDistance = (goingRight ? -self.privateContainerView.bounds.size.width : self.privateContainerView.bounds.size.width)
        self.disappearingFromRect = self.privateContainerView.bounds
        self.appearingToRect = self.privateContainerView.bounds
        self.disappearingToRect = CGRectOffset(self.privateContainerView.bounds, travelDistance, 0)
        self.appearingFromRect = CGRectOffset(self.privateContainerView.bounds, -travelDistance, 0)
        super.init()
    }
    
    // MARK: UIViewControllerContextTransitioning
    // 该协议的最基本作用：
    // 1，决定发生动画的两个视图的初始位置和最终位置
    // 2，为动画器提供to和from的ViewController以及View
    // 3，执行完成的动画
    func initialFrameForViewController(vc: UIViewController) -> CGRect {
        if vc == self.viewControllerForKey(UITransitionContextFromViewControllerKey) {
            return self.disappearingFromRect
        } else {
            return self.appearingFromRect
        }
    }
    
    func finalFrameForViewController(vc: UIViewController) -> CGRect {
        if vc == self.viewControllerForKey(UITransitionContextFromViewControllerKey) {
            return self.disappearingToRect
        } else {
            return self.appearingToRect
        }
    }

    func viewControllerForKey(key: String) -> UIViewController? {
        return self.viewControllers[key]
    }
    
    func completeTransition(didComplete: Bool) {
        if let blockTemp = self.completionBlock {
            blockTemp(didComplete)
        }
    }
    
    func transitionWasCancelled() -> Bool {
        return false
    }
    
    func updateInteractiveTransition(percentComplete: CGFloat) {
        
    }
    
    func finishInteractiveTransition() {
        
    }
    
    func cancelInteractiveTransition() {
        
    }
    
    func targetTransform() -> CGAffineTransform {
        return CGAffineTransform()
    }
    
    func containerView() -> UIView? {
        return self.privateContainerView
    }
    
    func isAnimated() -> Bool {
        return true
    }
    
    // This indicates whether the transition is currently interactive.
    func isInteractive() -> Bool {
        return false
    }
    
    func presentationStyle() -> UIModalPresentationStyle {
        return self.privatePresentationStyle
    }

    func viewForKey(key: String) -> UIView? {
        if key == UITransitionContextToViewKey {
            return self.viewControllerForKey(UITransitionContextToViewControllerKey)?.view
        } else if key == UITransitionContextFromViewKey {
            return self.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view
        } else {
            return nil
        }
    }
}
