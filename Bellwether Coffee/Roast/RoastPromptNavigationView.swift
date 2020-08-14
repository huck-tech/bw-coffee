//
//  RoastPromptNavigationView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

enum RoastPromptNavigationDirection {
    case forwardst
    case backwardst
}

protocol RoastPromptNavigationViewDelegate: class {
    func roastPromptDidSegue(direction: RoastPromptNavigationDirection)
}

class RoastPromptNavigationView: View {
    
    var delegate: RoastPromptNavigationViewDelegate?
    
    var pages: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var back: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = .zero
        button.setImage(UIImage(named: ""), for: .normal)
        button.addTarget(self, action: #selector(navigateBackwardst), for: .touchUpInside)
        button.alpha = 0.0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var currentPage = 0
    
    var pageViews: [UIView]! {
        didSet {
            pageViews.forEach {
                pages.addArrangedSubview($0)
            }
            
            let pageMultiplier = CGFloat(pages.arrangedSubviews.count)
            pages.widthAnchor.constraint(equalTo: widthAnchor, multiplier: pageMultiplier).isActive = true
        }
    }
    
    var maskLayer = CAGradientLayer()
    
    override func setupViews() {
        layer.mask = maskLayer
        
        addSubview(pages)
        
        pages.topAnchor.constraint(equalTo: topAnchor).isActive = true
        pages.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        pages.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addSubview(back)
        
        back.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        back.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        back.widthAnchor.constraint(equalToConstant: 44).isActive = true
        back.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    override func layoutSubviews() {
        maskLayer.frame = bounds
        maskLayer.shadowRadius = 10
        maskLayer.shadowPath = CGPath(roundedRect: bounds.insetBy(dx: 10, dy: 10), cornerWidth: 10, cornerHeight: 10, transform: nil)
        maskLayer.shadowOpacity = 1
        maskLayer.shadowOffset = CGSize.zero
        maskLayer.shadowColor = UIColor.white.cgColor
    }
    
    @objc func navigateToPage(index: Int) {
        currentPage = index
        animateToCurrentPage()
    }
    
    @objc func navigateForwardst() {
        currentPage += 1
        animateToCurrentPage()
        
        delegate?.roastPromptDidSegue(direction: .forwardst)
    }
    
    @objc func navigateBackwardst() {
        currentPage -= 1
        animateToCurrentPage()
        
        delegate?.roastPromptDidSegue(direction: .backwardst)
    }
    
    func navigateToRoot() {
        currentPage = 0
        back.alpha = 0.0
        
        let pageOffset = bounds.width * CGFloat(0.0)
        pages.transform = CGAffineTransform(translationX: -pageOffset, y: 0)
    }
    
    func animateToCurrentPage() {
        let backAlpha = currentPage > 0 ? CGFloat(1.0) : CGFloat(0.0)
        
        UIView.animate(withDuration: 0.5) { [unowned self] in
            self.back.alpha = backAlpha
        }
        
        let pageOffset = bounds.width * CGFloat(currentPage)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.3,
                       animations: { [unowned self] in
            self.pages.transform = CGAffineTransform(translationX: -pageOffset, y: 0)
        })
    }
    
}
