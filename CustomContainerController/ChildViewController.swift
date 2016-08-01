//
//  ChildViewController.swift
//  CustomContainerController
//
//  Created by MiaoChao on 16/5/8.
//  Copyright © 2016年 MiaoChao. All rights reserved.
//

import UIKit

class ChildViewController: UIViewController {
    
    var top:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidAppear")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        print("willMoveToParentViewController")
    }
    
    override func frameInParentController(parentController: UIViewController) -> CGRect {
        var frame = parentController.view.bounds
        frame.size.height = frame.size.height / 2
        if !self.top {
            frame.origin.y = frame.origin.y + frame.size.height
            frame.size.height += 400
        }
        return frame
    }
}
