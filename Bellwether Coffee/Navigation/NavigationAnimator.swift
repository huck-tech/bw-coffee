//
//  NavigationAnimator.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/26/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class NavigationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var animationDuration = 0.5
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromController = transitionContext.viewController(forKey: .from) else { return }
        guard let toController = transitionContext.viewController(forKey: .to) else { return }
        
        transitionContext.containerView.addSubview(fromController.view)
        transitionContext.containerView.addSubview(toController.view)
        
        toController.view.alpha = 0.0
        
        UIView.animate(withDuration: 0.3, animations: {
            toController.view.alpha = 1.0
        }, completion: { finished in
            fromController.view.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
    }
    
}
