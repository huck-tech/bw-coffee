//
//  CheckoutShippingOptionView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/25/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class CheckoutShippingOptionView: CheckoutProcessStepView {
    
    var selectedOptionIndex: Int?
    
    var title: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 19)
        label.textColor = BellwetherColor.roast
        label.text = "Delivery Option: UPS Ground"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var choices: CheckoutShippingOptionChoicesView = {
        let choiceView = CheckoutShippingOptionChoicesView(frame: .zero)
        choiceView.delegate = self
        choiceView.translatesAutoresizingMaskIntoConstraints = false
        return choiceView
    }()
    
    lazy var confirm: BouncyButton = {
        let button = BouncyButton(type: .custom)
        button.setAttributedTitle(confirmTitle, for: .normal)
        button.backgroundColor = .brandPurple
        button.tintColor = .brandPurple
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var confirmTitle: NSAttributedString = {
        let renderer = TextRenderer()
        renderer.font = UIFont(name: "AvenirNext-Medium", size: 16)
        renderer.color = UIColor(white: 1.0, alpha: 1.0)
        renderer.appendText(string: "Confirm")
        return renderer.renderedText
    }()
    
    private var confirmedTitle: NSAttributedString = {
        let renderer = TextRenderer()
        renderer.font = UIFont(name: "AvenirNext-Medium", size: 16)
        renderer.color = .brandPurple
        renderer.appendText(string: "Confirmed")
        return renderer.renderedText
    }()
    
    override func setupViews() {
        super.setupViews()
        
        stepTitle = "Delivery Option: UPS Ground"
        
        //        addSubview(title)
        //
        //        title.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        //        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        //        title.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        
        addSubview(choices)
        
        choices.topAnchor.constraint(equalTo: topAnchor, constant: 60).isActive = true
        choices.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        choices.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        
        addSubview(confirm)
        
        confirm.topAnchor.constraint(equalTo: choices.bottomAnchor, constant: 16).isActive = true
        confirm.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        confirm.widthAnchor.constraint(equalToConstant: 128).isActive = true
        confirm.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        //        bottomAnchor.constraint(equalTo: confirm.bottomAnchor, constant: 16).isActive = true
        alignBottom(toView: header, offset: 0)
    }
    
    func confirmSection() {
        confirm.backgroundColor = .clear
        confirm.setAttributedTitle(confirmedTitle, for: .normal)
    }
    
}

extension CheckoutShippingOptionView: CheckoutShippingOptionChoicesViewDelegate {
    
    func checkoutShippingOptionDidSelect(index: Int) {
        selectedOptionIndex = index
    }
    
}
