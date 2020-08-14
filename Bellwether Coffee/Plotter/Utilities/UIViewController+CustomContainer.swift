//
//  UIViewController+CustomContainer.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 25.02.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import UIKit
import Cartography

extension UIViewController {
    
    func bw_addViewController(_ viewController: UIViewController?, toContainerView containerView: UIView? = nil) {
        guard let viewController = viewController else {return}
        _bw_addViewController(viewController) {
            containerView?.addSubview(viewController.view)
            
            guard let containerView = containerView else {return}
            constrain(containerView, viewController.view) { containerView, controllerView in
                containerView.edges == controllerView.edges
            }
        }
    }
    
    func _bw_addViewController(_ viewController: UIViewController?,
                           withViewAddingClosure viewAddingClosure: VoidHandler? =  nil) {
        guard let viewController = viewController else {return}
        viewController.willMove(toParentViewController: self)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewAddingClosure?()
        addChildViewController(viewController)
        viewController.didMove(toParentViewController: self)
    }
    
    func bw_removeFromContainerView() {
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
        didMove(toParentViewController: nil)
    }
}
