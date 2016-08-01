//
//  ContainerViewController.swift
//  CustomContainerController
//
//  Created by MiaoChao on 16/5/8.
//  Copyright © 2016年 MiaoChao. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    weak var delegate: ContainerViewControllerDelegate?
    private(set) var viewControllers :[UIViewController]
    private var _selectedUIViewController :UIViewController?
    private var contentView :UIScrollView?
    var selectedUIViewController :UIViewController? {
        get{
            return _selectedUIViewController
        }
        set(viewController){
            _selectedUIViewController = viewController
            self.transitionToChildViewController(viewController!)
        }
    }

    init(viewContrllers :[UIViewController]) {
        self.viewControllers = viewContrllers
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Don't support init from storyboar in this demo")
        //super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightGrayColor()
        self.addContentView()
        self.addButtons()
        self.selectedUIViewController = self.viewControllers[0]
    }
    
    // 设置状态栏，每个控制器都可以改变状态栏
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func addContentView() {
        self.contentView = UIScrollView(frame: self.view.bounds)
        self.contentView?.contentSize = self.contentView!.frame.size
        self.contentView?.bounces = false
        self.view.addSubview(self.contentView!)
    }
        
    func addButtons() {
        for i in 0...2 {
            let button :UIButton = UIButton(type: UIButtonType.System)
            button.frame = CGRectMake(80*CGFloat(i)+50, 30, 80, 50)
            button.tag = i
            button.setTitle("button\(i)", forState: UIControlState.Normal)
            button.addTarget(self, action:Selector("buttonTapped:"), forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addSubview(button)
        }
    }
    
    func buttonTapped(button :UIButton) {
        let viewController = self.viewControllers[button.tag]
        self.selectedUIViewController = viewController
        self.delegate?.containerViewController?(self, didSelectViewController: viewController)
    }
    
    func transitionToChildViewController(toViewController :UIViewController) {
        let fromViewController :UIViewController? = self.childViewControllers.count>0 ? self.childViewControllers[0]:nil // 当前的子视图控制器
        if fromViewController == toViewController || !self.isViewLoaded() {
            return
        }
        let toView :UIView = toViewController.view
        toView.translatesAutoresizingMaskIntoConstraints = true // 这两句不知什么作用，苹果例子中没用
        toView.autoresizingMask = [.FlexibleWidth , .FlexibleHeight] // 不知什么作用
        toView.frame = self.contentView!.bounds
//        toView.frame = CGRectMake(100, 100, 100, 100) // 这样设了frame也是有效的
        
        fromViewController?.willMoveToParentViewController(nil)
        self.addChildViewController(toViewController)
        
        //  If this is the initial presentation, add the new child with no animation.
        if (fromViewController == nil) {
            self.contentView?.addSubview(toView)
            toViewController.didMoveToParentViewController(self)
            return
        }
        
        // 创建Animator
        var animator :UIViewControllerAnimatedTransitioning?
        animator = self.delegate?.containerViewController!(self, animationControllerForTransitionFromViewController:fromViewController!, toViewControlller: toViewController)
        if animator == nil {
            animator = Animator()
        }
        
        // 创建ContextTransitioning上下文
        let fromIndex = self.viewControllers.indexOf(fromViewController!)
        let toIndex = self.viewControllers.indexOf(toViewController)
        let transitionContext = PrivateTransitionContext(fromViewController: fromViewController!, toViewController: toViewController, goingRight: toIndex>fromIndex)
        transitionContext.animated = true
        transitionContext.interactive = false
        transitionContext.completionBlock = {(didComplete:Bool) -> Void in
            fromViewController?.view.removeFromSuperview()
            fromViewController?.removeFromParentViewController()
            toViewController.didMoveToParentViewController(self)
        }
        
        // 执行动画
        animator!.animateTransition(transitionContext)
    }
}

@objc protocol ContainerViewControllerDelegate {
//    typealias T: UIViewController, UIViewControllerAnimatedTransitioning
    /** Informs the delegate that the user selected view controller by tapping the corresponding icon.
     @note The method is called regardless of whether the selected view controller changed or not and only as a result of the user tapped a button. The method is not called when the view controller is changed programmatically. This is the same pattern as UITabBarController uses.
     */
    optional func containerViewController(containerViewController:ContainerViewController, didSelectViewController viewController:UIViewController)
    
    /// Called on the delegate to obtain a UIViewControllerAnimatedTransitioning object which can be used to animate a non-interactive transition.
    optional func containerViewController(containerViewController:ContainerViewController,animationControllerForTransitionFromViewController fromViewController:UIViewController, toViewControlller:UIViewController) -> UIViewControllerAnimatedTransitioning?
}

extension UIViewController {
    func frameInParentController(parentController :UIViewController) ->CGRect {
        return parentController.view.bounds;
    }
}


