//
//  CartListInfoView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class CartListInfoView: ComponentView {
    
    var coffee: ComponentLabel = {
        let label = ComponentLabel(frame: .zero)
        label.formatFont = UIFont(name: "AvenirNext-Medium", size: 13)!
        label.formatColor = UIColor(white: 1.0, alpha: 1.0)
        label.formatSpacing = 2
        label.formatCase = .uppercase
        label.textAlignment = .left
        label.formattedText = "Coffee"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var lbs: ComponentLabel = {
        let label = ComponentLabel(frame: .zero)
        label.formatFont = UIFont(name: "AvenirNext-Medium", size: 13)!
        label.formatColor = UIColor(white: 1.0, alpha: 1.0)
        label.formatSpacing = 2
        label.formatCase = .uppercase
        label.textAlignment = .center
        label.formattedText = "Amount"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var price: ComponentLabel = {
        let label = ComponentLabel(frame: .zero)
        label.formatFont = UIFont(name: "AvenirNext-Medium", size: 13)!
        label.formatColor = UIColor(white: 1.0, alpha: 1.0)
        label.formatSpacing = 2
        label.formatCase = .uppercase
        label.textAlignment = .center
        label.formattedText = "Price / lb"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var total: ComponentLabel = {
        let label = ComponentLabel(frame: .zero)
        label.formatFont = UIFont(name: "AvenirNext-Medium", size: 13)!
        label.formatColor = UIColor(white: 1.0, alpha: 1.0)
        label.formatSpacing = 2
        label.formatCase = .uppercase
        label.textAlignment = .center
        label.formattedText = "total"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func setupViews() {
        setupAppearance()
        setupLayout()
    }
    
    func setupAppearance() {
        backgroundColor = UIColor(white: 0.2, alpha: 1.0)
    }
    
    func setupLayout() {
        addSubview(total)
        
        total.topAnchor.constraint(equalTo: topAnchor).isActive = true
        total.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        total.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        total.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        addSubview(lbs)
        
        lbs.topAnchor.constraint(equalTo: topAnchor).isActive = true
        lbs.rightAnchor.constraint(equalTo: total.leftAnchor).isActive = true
        lbs.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        lbs.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        addSubview(price)
        
        price.topAnchor.constraint(equalTo: topAnchor).isActive = true
        price.rightAnchor.constraint(equalTo: lbs.leftAnchor).isActive = true
        price.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        price.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        addSubview(coffee)
        
        coffee.topAnchor.constraint(equalTo: topAnchor).isActive = true
        coffee.leftAnchor.constraint(equalTo: leftAnchor, constant: 14).isActive = true
        coffee.rightAnchor.constraint(equalTo: price.leftAnchor).isActive = true
        coffee.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
}
