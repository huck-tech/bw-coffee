//
//  RoastHudNavigationView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/8/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class RoastHudNavigationView: View {
    
    var roastHudViews = [UIView]() {
        didSet { updateRoastHudViews() }
    }
    
    var currentPage = 0
    
    @objc func navigateToPage(index: Int) {
        currentPage = index
        animateToCurrentPage()
    }
    
    @objc func navigateForwardst() {
        currentPage += 1
        animateToCurrentPage()
    }
    
    @objc func navigateBackwardst() {
        currentPage -= 1
        animateToCurrentPage()
    }
    
    func animateToCurrentPage() {
        roastHudViews.enumerated().forEach { index, pageView in
            let alpha: CGFloat = index == currentPage ? 1.0 : 0.0
            
            UIView.animate(withDuration: 0.5, animations: {
                pageView.alpha = alpha
            })
        }
    }
    
}

// MARK: Layout

extension RoastHudNavigationView {
    
    func updateRoastHudViews() {
        roastHudViews.forEach { roastHudView in
            addSubview(roastHudView)
            
            roastHudView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            roastHudView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            roastHudView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            roastHudView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }
    
}
