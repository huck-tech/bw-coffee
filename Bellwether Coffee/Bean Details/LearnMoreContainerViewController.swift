//
//  LearnMoreContainerViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 4/10/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class LearnMoreContainerViewController: UIViewController {
    
    weak var learnMore: BeanLearnMoreViewController?
    func set(bean: Bean) {
        learnMore?.set(bean: bean)
    }
    override func addChildViewController(_ childController: UIViewController) {
        super.addChildViewController(childController)
        
        if let child = childController as? BeanLearnMoreViewController {
            self.learnMore = child
        }
    }
}

extension LearnMoreContainerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0.0
    }
}
