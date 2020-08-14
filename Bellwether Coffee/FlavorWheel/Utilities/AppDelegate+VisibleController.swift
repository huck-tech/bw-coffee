//
//  AppDelegate+VisibleController.swift
//  Bellwether-iOS
//
//  Created by Marcos Polanco on 11/22/17.
//  Copyright © 2017 Bellwether. All rights reserved.
//

import Foundation
import UIKit

//retrieve the visible (topmost) view controller. sourced from https://stackoverflow.com/a/34179192

func getVisibleViewController(_ rootViewController: UIViewController?) -> UIViewController? {
    
    var rootVC = rootViewController
    if rootVC == nil {
        rootVC = UIApplication.shared.keyWindow?.rootViewController
    }
    
    if rootVC?.presentedViewController == nil {
        return rootVC
    }
    
    if let presented = rootVC?.presentedViewController {
        if presented.isKind(of: UINavigationController.self) {
            let navigationController = presented as! UINavigationController
            return navigationController.viewControllers.last
        }
        
        if presented.isKind(of: UITabBarController.self) {
            let tabBarController = presented as! UITabBarController
            return tabBarController.selectedViewController
        }
        
        return getVisibleViewController(presented)
    }
    return nil
}

extension AppDelegate {
    static var visibleViewController: UIViewController? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return nil}
        
        return appDelegate.window?.visibleViewController
    }
    
    static var navController: NavigationController? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return nil}
        
        return appDelegate.window?.rootViewController as? NavigationController
    }
}

extension UIWindow {
    public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewControllerFrom(vc: self.rootViewController)
    }
    
    public static func getVisibleViewControllerFrom(vc: UIViewController?) -> UIViewController? {
        if let nc = vc as? UINavigationController {
            return UIWindow.getVisibleViewControllerFrom(vc: nc.visibleViewController)
        } else if let tc = vc as? UITabBarController {
            return UIWindow.getVisibleViewControllerFrom(vc: tc.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(vc: pvc)
            } else {
                return vc
            }
        }
    }
}

