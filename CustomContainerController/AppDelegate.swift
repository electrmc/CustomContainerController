//
//  AppDelegate.swift
//  CustomContainerController
//
//  Created by MiaoChao on 16/5/8.
//  Copyright © 2016年 MiaoChao. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow.init(frame: UIScreen.mainScreen().bounds)
        self.window?.backgroundColor = UIColor.lightGrayColor()
        let childViewControllers =  self.configuredChildViewControllers()
        let containerVC: CustomTabrViewController = CustomTabrViewController(viewContrllers: childViewControllers)
        let defaultTranistionDelegate = DefaultContainerTransitionDelegate()
        containerVC.containerTransitionDelegate = defaultTranistionDelegate
        self.window?.rootViewController = containerVC
        self.window?.makeKeyAndVisible()
        return true
    }
    
    func configuredChildViewControllers() -> [UIViewController]{
        var childViewContollers = [UIViewController]()
        let configurations = [
            ["title":"First", "color":UIColor(red: 0.4, green: 0.8, blue: 1, alpha: 1)],
            ["title":"Second","color":UIColor(red: 1, green: 0.4, blue: 0.8, alpha: 1)],
            ["title":"Third", "color":UIColor(red: 1, green: 0.8, blue: 0.4, alpha: 1)]]
        for configuration in configurations {
            let childViewController = ChildViewController()
            childViewController.title = configuration["title"] as? String
            childViewController.view.backgroundColor = configuration["color"] as? UIColor
            childViewContollers.append(childViewController)
        }
        return childViewContollers
    }
}

