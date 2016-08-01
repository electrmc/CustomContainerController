//
//  ContainerViewController.swift
//  CustomContainerController
//
//  Created by MiaoChao on 16/5/8.
//  Copyright © 2016年 MiaoChao. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    var containerTransitionDelegate: ContainerTransitionDelegate?
    private(set) var viewControllers :[UIViewController]?
    var contentView :UIScrollView?
    
    var interactive = false
    private var shouldReserve = false
    private var priorSelectedIndex: Int = NSNotFound
    private var _selectedIndex: Int = 0
    var selectedIndex: Int {
        get {
            return _selectedIndex
        }
        set {
            if shouldReserve{
                shouldReserve = false
            }
            if newValue >= viewControllers!.count {
                print("超出范围了！")
                return
            } else if newValue < 0 {
                print("小于零！")
                return
            }
            priorSelectedIndex = selectedIndex
            _selectedIndex = newValue

            self.transitionViewControllerToIndex(newValue)
        }
    }
    
    var selectedViewController :UIViewController? {
        get{
            if self.viewControllers == nil || selectedIndex < 0 || selectedIndex >= viewControllers!.count{
                return nil
            }
            return self.viewControllers![selectedIndex]
        }
        set{
            if viewControllers == nil{
                return
            }
            if let index = viewControllers?.indexOf(selectedViewController!){
                selectedIndex = index
            }else{
                print("The view controller is not in the viewControllers")
            }
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
        self.selectedViewController = self.viewControllers![0]
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
    
    func transitionViewControllerToIndex(toIndex:Int) {
        let viewController = self.viewControllers![toIndex]
        self.transitionToChildViewController(viewController)
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
        
        self.addChildViewController(toViewController)
        
        //  If this is the initial presentation, add the new child with no animation.
        if (fromViewController == nil) {
            self.contentView?.addSubview(toView)
            toViewController.didMoveToParentViewController(self)
            return
        }
        
        // 创建Animator
        let animator = self.containerTransitionDelegate?.containerViewController!(self, animationControllerForTransitionFromViewController:fromViewController!, toViewControlller: toViewController)
        
        if animator != nil {
            // 创建ContextTransitioning上下文
            let fromIndex = self.viewControllers!.indexOf(fromViewController!)
            let toIndex = self.viewControllers!.indexOf(toViewController)
            let transitionContext = PrivateTransitionContext(containerViewController: self,containerView: self.contentView!,fromViewController: fromViewController!, toViewController: toViewController, goingRight: toIndex>fromIndex)
            transitionContext.animated = true
            let interactive = self.containerTransitionDelegate?.containerViewController!(self, interactionControllerForAnimation: animator!)
            if interactive != nil && self.interactive {
                transitionContext.startInteractiveTransitionWith(self.containerTransitionDelegate!)
            } else {
                transitionContext.startNonInteractiveTransitionWith(self.containerTransitionDelegate!)
            }
        } else {
            self.contentView?.addSubview(toView)
            toViewController.didMoveToParentViewController(self)
            
            fromViewController?.willMoveToParentViewController(nil)
            fromViewController?.view.removeFromSuperview()
            fromViewController?.removeFromParentViewController()
        }
    }
    
    //MARK: Restore data and change button appear
    func restoreSelectedIndex(){
        shouldReserve = true
        _selectedIndex = priorSelectedIndex
    }
    
    func changeTabButtonAppearAtIndex(index: Int) {
        
    }
    
    func updateControllerInteractiveTransition(percentComplete: CGFloat) {
//        print("update controller process : \(percentComplete)")
    }
    
    // ---------------------------------------------------
    
    func addButtons() {
        for i in 0...2 {
            let button :UIButton = UIButton(type: UIButtonType.System)
            button.frame = CGRectMake(80*CGFloat(i)+50, 30, 80, 50)
            button.tag = i + 1000
            button.setTitle("button\(i)", forState: UIControlState.Normal)
            button.addTarget(self, action:#selector(ContainerViewController.buttonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addSubview(button)
        }
    }
    
    func buttonTapped(button :UIButton) {
        if button.tag-1000 < viewControllers?.count {
            interactive = false
            selectedIndex = button.tag - 1000
        }
    }
}
