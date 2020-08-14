//
//  InventoryTabsView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 2/8/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

enum InventoryTab {
    case order
    case green
    case roasted
}

protocol InventoryTabsViewDelegate: class {
    func inventoryTabsDidSelect(tab: InventoryTab)
}

class InventoryTabsView: ComponentView {
    
    weak var delegate: InventoryTabsViewDelegate?
    
    lazy var order: UIButton = {
        let button = UIButton(frame: .zero)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17)
        button.setTitle("On Order", for: .normal)
        button.addTarget(self, action: #selector(selectOrder), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var green: UIButton = {
        let button = UIButton(frame: .zero)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17)
        button.setTitle("Green", for: .normal)
        button.addTarget(self, action: #selector(selectGreen), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var roasted: UIButton = {
        let button = UIButton(frame: .zero)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17)
        button.setTitle("Roasted", for: .normal)
        button.addTarget(self, action: #selector(selectRoasted), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var tabs = [UIButton]()
    
    override func setupViews() {
        tabs = [order, green, roasted]
        
        let stack = UIStackView(arrangedSubviews: tabs)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        stack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stack.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stack.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        stack.heightAnchor.constraint(equalToConstant: 57).isActive = true
        
        selectOrder()
    }
    
    @objc func selectOrder() {
        selectTab(button: order)
        delegate?.inventoryTabsDidSelect(tab: .order)
    }
    
    @objc func selectGreen() {
        selectTab(button: green)
        delegate?.inventoryTabsDidSelect(tab: .green)
    }
    
    @objc func selectRoasted() {
        selectTab(button: roasted)
        delegate?.inventoryTabsDidSelect(tab: .roasted)
    }
    
    func selectTab(button: UIButton) {
        tabs.forEach { tab in
            tab.setTitleColor(.brandPurple, for: .normal)
            tab.backgroundColor = .white
        }
        
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = BellwetherColor.roast
    }
    
}
