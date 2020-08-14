//
//  ChildViewControllers.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 2/9/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addViewController(_ viewController: UIViewController) {
        addChildViewController(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
    }
    
    func removeViewController(_ viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
    
}
