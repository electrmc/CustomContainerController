//
//  CustomTabrViewController.swift
//  CustomContainerController
//
//  Created by MiaoChao on 16/7/17.
//  Copyright © 2016年 MiaoChao. All rights reserved.
//

import UIKit

class CustomTabrViewController: ContainerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureLeft: UIScreenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer()
        gestureLeft.edges = UIRectEdge.Left
        gestureLeft.addTarget(self, action: #selector(CustomTabrViewController.gestureRecognizeDidUpdate(_:)))
        view.addGestureRecognizer(gestureLeft)
        
        let gestureRight: UIScreenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer()
        gestureRight.edges = UIRectEdge.Right
        gestureRight.addTarget(self, action: #selector(CustomTabrViewController.gestureRecognizeDidUpdate(_:)))
        view.addGestureRecognizer(gestureRight)
    }
    
    func gestureRecognizeDidUpdate(gesture:UIScreenEdgePanGestureRecognizer) {
        if !(gesture.edges ==  UIRectEdge.Left ||  gesture.edges ==  UIRectEdge.Right) {
            return
        }
        if viewControllers!.count < 2 || containerTransitionDelegate == nil || !(containerTransitionDelegate is DefaultContainerTransitionDelegate) {
            return
        }
        
        let delegate = containerTransitionDelegate as! DefaultContainerTransitionDelegate
        
        let width = self.contentView!.bounds.size.width
        let locationInView = gesture.locationInView(contentView)
        var progress:CGFloat = 0.0
        if gesture.edges == UIRectEdge.Left {
            progress = locationInView.x / width
        } else if gesture.edges == UIRectEdge.Right {
            progress = (width - locationInView.x) / width
        }

        switch gesture.state {
        case .Began:
            interactive = true
            var temp = 0;
            if gesture.edges == UIRectEdge.Left {
                temp = selectedIndex - 1
            } else if gesture.edges == UIRectEdge.Right {
                temp = selectedIndex + 1
            }
            selectedIndex = temp
        case .Changed:
            delegate.interactiveController.updateInteractiveTransition(progress)
            
        case .Ended,.Cancelled :
            if progress > 0.6 {
                delegate.interactiveController.finishInteractiveTransition()
            } else {
                delegate.interactiveController.cancelInteractiveTransition()
            }
        default:
            break
        }
    }
}
