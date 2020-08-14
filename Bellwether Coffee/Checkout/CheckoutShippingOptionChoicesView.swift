//
//  CheckoutShippingOptionChoicesView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/25/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol CheckoutShippingOptionChoicesViewDelegate: class {
    func checkoutShippingOptionDidSelect(index: Int)
}

class CheckoutShippingOptionChoicesView: View {
    
    weak var delegate: CheckoutShippingOptionChoicesViewDelegate?
    
    var choices: [ShippingOption]? {
        didSet { updateChoices() }
    }
    
    var choiceViews = [CheckoutShippingOptionChoiceView]()
    
    func updateChoices() {
        var constraintY: NSLayoutYAxisAnchor = topAnchor
        
        choices?.enumerated().forEach { index, shippingOption in
            let optionView = CheckoutShippingOptionChoiceView(frame: .zero)
            optionView.optionName = shippingOption.rawValue
            optionView.button.tag = index
            optionView.button.addTarget(self, action: #selector(selectOption(sender:)), for: .touchUpInside)
            optionView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(optionView)
            
            choiceViews.append(optionView)
            
            optionView.topAnchor.constraint(equalTo: constraintY).isActive = true
            optionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            optionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            optionView.heightAnchor.constraint(equalToConstant: 38).isActive = true
            
            constraintY = optionView.bottomAnchor
        }
        
        bottomAnchor.constraint(equalTo: constraintY).isActive = true
    }
    
    @objc func selectOption(sender: UIButton) {
        choiceViews.enumerated().forEach { index, choiceView in
            choiceView.selected = index == sender.tag
        }
        
        delegate?.checkoutShippingOptionDidSelect(index: sender.tag)
    }
    
}
