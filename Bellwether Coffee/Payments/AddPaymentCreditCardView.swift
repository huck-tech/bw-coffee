//
//  AddPaymentCreditCardView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/2/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol AddPaymentCreditCardViewDelegate: class {
    func addPaymentShouldSaveCard(creditCard: CreditCard)
}

class AddPaymentCreditCardView: View {
    
    weak var delegate: AddPaymentCreditCardViewDelegate?
    
    var name: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 20)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .left
        label.text = "Add Credit Card"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var cardNumber: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.font = UIFont(name: "AvenirNext-Medium", size: 16)
        textField.textColor = BellwetherColor.roast
        textField.keyboardType = .numberPad
        textField.setPlaceholder(placeholder: "Card Number")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var expirationMonth: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.font = UIFont(name: "AvenirNext-Medium", size: 16)
        textField.textColor = BellwetherColor.roast
        textField.keyboardType = .numberPad
        textField.setPlaceholder(placeholder: "MM")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var expirationYear: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.font = UIFont(name: "AvenirNext-Medium", size: 16)
        textField.textColor = BellwetherColor.roast
        textField.keyboardType = .numberPad
        textField.setPlaceholder(placeholder: "YY")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var cvc: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.font = UIFont(name: "AvenirNext-Medium", size: 16)
        textField.textColor = BellwetherColor.roast
        textField.textAlignment = .right
        textField.keyboardType = .numberPad
        textField.setPlaceholder(placeholder: "CVC")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private var saveTitle: NSAttributedString = {
        let renderer = TextRenderer()
        renderer.font = UIFont(name: "AvenirNext-Medium", size: 16)
        renderer.color = UIColor(white: 1.0, alpha: 1.0)
        renderer.appendText(string: "Save Card")
        return renderer.renderedText
    }()
    
    lazy var save: BouncyButton = {
        let button = BouncyButton(type: .custom)
        button.setAttributedTitle(saveTitle, for: .normal)
        button.backgroundColor =  .brandPurple
        button.tintColor =  .brandPurple
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(saveCard), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func setupViews() {
        addSubview(name)
        
        name.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        name.leftAnchor.constraint(equalTo: leftAnchor, constant: 72).isActive = true
        
        addSubview(cardNumber)
        
        cardNumber.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 40).isActive = true
        cardNumber.leftAnchor.constraint(equalTo: leftAnchor, constant: 48).isActive = true
        cardNumber.rightAnchor.constraint(equalTo: rightAnchor, constant: -48).isActive = true
        cardNumber.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        addSubview(expirationMonth)
        
        expirationMonth.topAnchor.constraint(equalTo: cardNumber.bottomAnchor, constant: 4).isActive = true
        expirationMonth.leftAnchor.constraint(equalTo: leftAnchor, constant: 48).isActive = true
        expirationMonth.widthAnchor.constraint(equalToConstant: 50).isActive = true
        expirationMonth.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        addSubview(expirationYear)
        
        expirationYear.topAnchor.constraint(equalTo: cardNumber.bottomAnchor, constant: 4).isActive = true
        expirationYear.leftAnchor.constraint(equalTo: expirationMonth.rightAnchor, constant: 2).isActive = true
        expirationYear.widthAnchor.constraint(equalToConstant: 50).isActive = true
        expirationYear.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        addSubview(cvc)
        
        cvc.topAnchor.constraint(equalTo: cardNumber.bottomAnchor, constant: 4).isActive = true
        cvc.rightAnchor.constraint(equalTo: rightAnchor, constant: -40).isActive = true
        cvc.widthAnchor.constraint(equalToConstant: 80).isActive = true
        cvc.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        addSubview(save)
        
        save.leftAnchor.constraint(equalTo: leftAnchor, constant: 48).isActive = true
        save.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32).isActive = true
        
        save.widthAnchor.constraint(equalToConstant: 136).isActive = true
        save.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    @objc func saveCard() {
        save.isUserInteractionEnabled = false
        save.alpha = 0.3
        
        cardNumber.resignFirstResponder()
        cvc.resignFirstResponder()
        expirationMonth.resignFirstResponder()
        expirationYear.resignFirstResponder()
        
        let card = CreditCard(number: cardNumber.text ?? "",
                              cvc: cvc.text ?? "",
                              expirationMonth: expirationMonth.text ?? "",
                              expirationYear: expirationYear.text ?? "",
                              billingInfo: [:])
        delegate?.addPaymentShouldSaveCard(creditCard: card)
    }
    
}
