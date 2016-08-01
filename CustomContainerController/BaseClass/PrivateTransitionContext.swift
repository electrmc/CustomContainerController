//
//  PrivateTransitionContext.swift
//  CustomContainerController
//
//  Created by MiaoChao on 16/5/12.
//  Copyright © 2016年 MiaoChao. All rights reserved.
//

import UIKit

let ContainerTransitionEndNotification = "Notification.ContainerTransitionEnd"
let InteractionEndNotification = "Notification.InteractionEnd"


class PrivateTransitionContext: NSObject, UIViewControllerContextTransitioning{
    private var viewControllers: [String : UIViewController]
    private var appearingFromRect: CGRect
    private var disappearingFromRect: CGRect
    private var appearingToRect: CGRect
    private var disappearingToRect: CGRect
    private var privatePresentationStyle: UIModalPresentationStyle //UIModalPresentationStyle
    
    var completionBlock :((Bool)->())?
    var animated :Bool?
    
    //MARK: Addtive Property
    private var animationController: UIViewControllerAnimatedTransitioning?
    unowned private var privateContainerController: ContainerViewController
    unowned private var privateFromViewController: UIViewController
    unowned private var privateToViewController: UIViewController
    unowned private var privateContainerView :UIView

    //MARK: Property for Transition State
    private var interactive = false
    private var isCancelled = false
    private var fromIndex: Int = 0
    private var toIndex: Int = 0
    private var transitionDuration: CFTimeInterval = 0
    private var transitionPercent: CGFloat = 0

    init(containerViewController:ContainerViewController, containerView:UIView, fromViewController: UIViewController, toViewController: UIViewController, goingRight: Bool) {
        self.viewControllers = [UITransitionContextFromViewControllerKey:fromViewController,
            UITransitionContextToViewControllerKey:toViewController]
        self.privateContainerController = containerViewController
        self.privateFromViewController = fromViewController
        self.privateToViewController = toViewController
        self.privateContainerView = containerView
        
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
    
    func startInteractiveTransitionWith(delegate:ContainerTransitionDelegate) {
        self.animationController = delegate.containerViewController!(privateContainerController, animationControllerForTransitionFromViewController: privateFromViewController, toViewControlller: privateToViewController)
        self.transitionDuration = self.animationController!.transitionDuration(self)
        
        if self.privateContainerController.interactive == true {
            if let interactiveController = delegate.containerViewController!(privateContainerController, interactionControllerForAnimation: self.animationController!){
                interactiveController.startInteractiveTransition(self)
            } else {
                fatalError("Need for interaction controller for interactive transition.")
            }
        } else {
            fatalError("ContainerTransitionContext's Property 'interactive' must be true before starting interactive transiton")
        }
    }
    
    func startNonInteractiveTransitionWith(delegate:ContainerTransitionDelegate) {
        self.animationController = delegate.containerViewController!(privateContainerController, animationControllerForTransitionFromViewController: privateFromViewController, toViewControlller: privateToViewController)
        self.transitionDuration = self.animationController!.transitionDuration(self)
        self.animationNonInteractiveTransition()
    }
    
    //InteractionController's startInteractiveTransition: will call this method
    func animationInteractiveTransition() {
        self.interactive = true
        self.isCancelled = false
        self.privateContainerView.layer.speed = 0.0
        self.animationController?.animateTransition(self)
    }

    private func animationNonInteractiveTransition() {
        self.interactive = false
        self.isCancelled = false
        self.animationController?.animateTransition(self)
    }
    
    private func transitionEnd() {
        if self.animationController != nil &&
            self.animationController!.respondsToSelector(#selector(UIViewControllerAnimatedTransitioning.animationEnded(_:))) == true {
            self.animationController!.animationEnded!(!isCancelled)
        }
        
        //If transition is cancelled, recovery containerController data
        if self.isCancelled {
            privateContainerController.restoreSelectedIndex()
            privateFromViewController.view.frame = self.disappearingFromRect
            isCancelled = false
        }
        NSNotificationCenter.defaultCenter().postNotificationName(ContainerTransitionEndNotification, object: self)
    }
    
    @objc private func reverseCurrentAnimation(displayLink: CADisplayLink) {
        let timeoffset = privateContainerView.layer.timeOffset - (displayLink.duration * Double(displayLink.frameInterval))
        if timeoffset < 0 {
            privateContainerView.layer.timeOffset = 0.0
            privateContainerView.layer.beginTime = 0.0
            privateContainerView.layer.speed = 1.0
            self.stopDisplayLink(displayLink)
            
            //修复闪屏Bug: speed 恢复为1后，动画会立即跳转到它的最终状态，而 fromView 的最终状态是移动到了屏幕之外，因此在这里添加一个假的掩人耳目。
            //为何不等 completion block 中恢复 fromView 的状态后再恢复 containerView.layer.speed，事实上那样做无效，原因未知。
            let fakeFromView = privateFromViewController.view.snapshotViewAfterScreenUpdates(false)
            privateContainerView.addSubview(fakeFromView)
            performSelector(#selector(PrivateTransitionContext.removeFakeFromView(_:)), withObject: fakeFromView, afterDelay: 1/60)
        } else {
            privateContainerView.layer.timeOffset = timeoffset
            transitionPercent = CGFloat(timeoffset / transitionDuration)
            privateContainerController.updateControllerInteractiveTransition(transitionPercent)
        }
    }
    
    @objc private func removeFakeFromView(fakeView: UIView){
        fakeView.removeFromSuperview()
    }
    
    func stopDisplayLink(displayLink: CADisplayLink){
        displayLink.paused = true
        displayLink.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        displayLink.invalidate()
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
    
    func viewForKey(key: String) -> UIView? {
        if key == UITransitionContextToViewKey {
            return self.viewControllerForKey(UITransitionContextToViewControllerKey)?.view
        } else if key == UITransitionContextFromViewKey {
            return self.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view
        } else {
            return nil
        }
    }
    
    func containerView() -> UIView? {
        return self.privateContainerView
    }
    
    func completeTransition(didComplete: Bool) {
        if didComplete {
            print("transition complete")
            // 完成toViewController的添加
            privateToViewController.didMoveToParentViewController(privateContainerController)
            // 移除fromViewController
            privateFromViewController.willMoveToParentViewController(nil)
            privateFromViewController.view.removeFromSuperview()
            privateFromViewController.removeFromParentViewController()
        } else {
            print("transition not complete")
            // 完成toViewController的添加
            privateToViewController.didMoveToParentViewController(privateContainerController)
            // 然后移除toViewController
            privateToViewController.willMoveToParentViewController(nil)
            privateToViewController.view.removeFromSuperview()
            privateToViewController.removeFromParentViewController()
        }
        self.transitionEnd()
    }
    
    // --------------------下面的方法用于交互式切换--------------------
    func updateInteractiveTransition(percentComplete: CGFloat) {
        if animationController != nil && interactive == true {
            transitionPercent = percentComplete
            let timexx = CFTimeInterval(percentComplete)*transitionDuration
            privateContainerView.layer.timeOffset = timexx
            privateContainerController.updateControllerInteractiveTransition(transitionPercent)
        }
    }
    
    func finishInteractiveTransition() {
        print("\(#function)")
        interactive = false
        let pauseTime = privateContainerView.layer.timeOffset
        privateContainerView.layer.speed = 1.0
        privateContainerView.layer.timeOffset = 0.0
        privateContainerView.layer.beginTime = 0.0
        let timeInterval = privateContainerView.layer.convertTime(CACurrentMediaTime(), toLayer: nil)-pauseTime
        privateContainerView.layer.beginTime = timeInterval
        transitionPercent = 1.0
        privateContainerController.updateControllerInteractiveTransition(transitionPercent)
    }
    
    func cancelInteractiveTransition() {
        print("\(#function)")
        interactive = false
        isCancelled = true
        
        let displayLink = CADisplayLink(target:self,selector: #selector(PrivateTransitionContext.reverseCurrentAnimation(_:)))
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        NSNotificationCenter.defaultCenter().postNotificationName(InteractionEndNotification, object: self)
    }

    func transitionWasCancelled() -> Bool {
        return isCancelled
    }

    func isInteractive() -> Bool {
        return interactive
    }
    
    func isAnimated() -> Bool {
        if animationController != nil {
            return true
        } else {
            return false
        }
    }

    func presentationStyle() -> UIModalPresentationStyle {
        return self.privatePresentationStyle
    }
    
    func targetTransform() -> CGAffineTransform {
        return CGAffineTransform()
    }
}
