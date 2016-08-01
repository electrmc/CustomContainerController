//
//  ContainerTransitionDelegate.swift
//  CustomContainerController
//
//  Created by MiaoChao on 16/7/16.
//  Copyright © 2016年 MiaoChao. All rights reserved.
//

import UIKit

@objc protocol ContainerTransitionDelegate {
    //    typealias T: UIViewController, UIViewControllerAnimatedTransitioning
    /** Informs the delegate that the user selected view controller by tapping the corresponding icon.
     @note The method is called regardless of whether the selected view controller changed or not and only as a result of the user tapped a button. The method is not called when the view controller is changed programmatically. This is the same pattern as UITabBarController uses.
     */
    optional func containerViewController(containerViewController:ContainerViewController, didSelectViewController viewController:UIViewController)
    
    // Called on the delegate to obtain a UIViewControllerAnimatedTransitioning object which can be used to animate a non-interactive transition.
    optional func containerViewController(containerViewController:ContainerViewController,animationControllerForTransitionFromViewController fromViewController:UIViewController, toViewControlller:UIViewController) -> UIViewControllerAnimatedTransitioning?
    
    optional func containerViewController(containerController: ContainerViewController, interactionControllerForAnimation animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
}

class DefaultContainerTransitionDelegate: NSObject,ContainerTransitionDelegate {
    
    var interactiveController = PercentDrivenInteractiveTransition()
    
    func containerViewController(containerViewController:ContainerViewController, didSelectViewController viewController:UIViewController) {
    }
    
    // Called on the delegate to obtain a UIViewControllerAnimatedTransitioning object which can be used to animate a non-interactive transition.
    func containerViewController(containerViewController:ContainerViewController,animationControllerForTransitionFromViewController fromViewController:UIViewController, toViewControlller:UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Animator1()
    }
    
    func containerViewController(containerController: ContainerViewController, interactionControllerForAnimation animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveController
    }
}

extension UIViewController {
    func frameInParentController(parentController :UIViewController) ->CGRect {
        return parentController.view.bounds;
    }
}
