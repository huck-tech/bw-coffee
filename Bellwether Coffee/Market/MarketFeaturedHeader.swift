//
//  MarketFeaturedHeader.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 12/27/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit

enum MarketFeaturedHeaderAction {
    case featuredCoffee
}

class MarketFeaturedHeader: ComponentView {
    
    var separator: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.08)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var name: String? {
        didSet { updateFeaturedCoffee() }
    }
    
    lazy var featured: UIButton = {
        let button = UIButton(frame: .zero)
        button.alpha = 0.0
        button.addTarget(self, action: #selector(featuredCoffee), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var actionHandler: ((MarketFeaturedHeaderAction) -> Void)?
    
    override func setupViews() {
        setupAppearance()
        setupLayout()
    }
    
    func setupAppearance() {
        backgroundColor = UIColor(white: 0.96, alpha: 1.0)
    }
    
    func setupLayout() {
        addSubview(separator)
        
        separator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        addSubview(featured)
        
        featured.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        featured.leftAnchor.constraint(equalTo: leftAnchor, constant: 12).isActive = true
        featured.rightAnchor.constraint(equalTo: rightAnchor, constant: -12).isActive = true
        featured.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
    }
    
    func updateFeaturedCoffee() {
        guard let coffeeName = name else { return }
        
        let renderer = TextRenderer()
        renderer.font = UIFont(name: "AvenirNext-Medium", size: 16)
        renderer.color = UIColor(white: 0.2, alpha: 1.0)
        
        renderer.appendText(string: "Featured Coffee: ")
        renderer.appendText(string: coffeeName, separateColor: .brandPurple)
        
        featured.setAttributedTitle(renderer.renderedText, for: .normal)
        animateFeaturedEntrance()
    }
    
    @objc func featuredCoffee() {
        actionHandler?(.featuredCoffee)
    }
    
}

// MARK: Animations

extension MarketFeaturedHeader {
    
    func animateFeaturedEntrance() {
        featured.transform = CGAffineTransform(translationX: 0, y: 40)
        featured.alpha = 0.0
        
        UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, animations: { [unowned self] in
            self.featured.transform = CGAffineTransform(translationX: 0, y: 0)
            self.featured.alpha = 1.0
        })
    }
    
}
