//
//  AddBillingInfoView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/4/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit


protocol AddBillingInfoViewDelegate: class {
    func addBillingInfoShouldSaveInfo(billingInfo: BillingInfo)
}

class AddBillingInfoView: View {
    
    weak var delegate: AddBillingInfoViewDelegate?
    
    var name: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 20)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .left
        label.text = "Add Billing Info"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var firstName: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.font = UIFont(name: "AvenirNext-Medium", size: 16)
        textField.textColor = BellwetherColor.roast
        textField.keyboardType = .numberPad
        textField.setPlaceholder(placeholder: "First Name")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var lastName: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.font = UIFont(name: "AvenirNext-Medium", size: 16)
        textField.textColor = BellwetherColor.roast
        textField.keyboardType = .numberPad
        textField.setPlaceholder(placeholder: "Last Name")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var company: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.font = UIFont(name: "AvenirNext-Medium", size: 16)
        textField.textColor = BellwetherColor.roast
        textField.keyboardType = .numberPad
        textField.setPlaceholder(placeholder: "Company")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var email: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.font = UIFont(name: "AvenirNext-Medium", size: 16)
        textField.textColor = BellwetherColor.roast
        textField.keyboardType = .numberPad
        textField.setPlaceholder(placeholder: "Email")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var phone: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.font = UIFont(name: "AvenirNext-Medium", size: 16)
        textField.textColor = BellwetherColor.roast
        textField.keyboardType = .numberPad
        textField.setPlaceholder(placeholder: "Phone")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var address: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.font = UIFont(name: "AvenirNext-Medium", size: 16)
        textField.textColor = BellwetherColor.roast
        textField.keyboardType = .numberPad
        textField.setPlaceholder(placeholder: "Address")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var city: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.font = UIFont(name: "AvenirNext-Medium", size: 16)
        textField.textColor = BellwetherColor.roast
        textField.keyboardType = .numberPad
        textField.setPlaceholder(placeholder: "City")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var state: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.font = UIFont(name: "AvenirNext-Medium", size: 16)
        textField.textColor = BellwetherColor.roast
        textField.keyboardType = .numberPad
        textField.autocapitalizationType = .allCharacters
        textField.setPlaceholder(placeholder: "State")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var country: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.font = UIFont(name: "AvenirNext-Medium", size: 16)
        textField.textColor = BellwetherColor.roast
        textField.keyboardType = .numberPad
        textField.setPlaceholder(placeholder: "Country")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var postalCode: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.font = UIFont(name: "AvenirNext-Medium", size: 16)
        textField.textColor = BellwetherColor.roast
        textField.keyboardType = .numberPad
        textField.setPlaceholder(placeholder: "Postal Code")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private var saveTitle: NSAttributedString = {
        let renderer = TextRenderer()
        renderer.font = UIFont(name: "AvenirNext-Medium", size: 16)
        renderer.color = UIColor(white: 1.0, alpha: 1.0)
        renderer.appendText(string: "Save Billing Info")
        return renderer.renderedText
    }()
    
    lazy var save: BouncyButton = {
        let button = BouncyButton(type: .custom)
        button.setAttributedTitle(saveTitle, for: .normal)
        button.backgroundColor = .brandPurple
        button.tintColor = .brandPurple
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(saveInfo), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func setupViews() {
        addSubview(name)
        
        name.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        name.leftAnchor.constraint(equalTo: leftAnchor, constant: 72).isActive = true
        
        addSubview(firstName)
        
        firstName.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 40).isActive = true
        firstName.leftAnchor.constraint(equalTo: leftAnchor, constant: 48).isActive = true
        firstName.rightAnchor.constraint(equalTo: centerXAnchor, constant: -12).isActive = true
        firstName.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        addSubview(lastName)
        
        lastName.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 40).isActive = true
        lastName.leftAnchor.constraint(equalTo: centerXAnchor, constant: 4).isActive = true
        lastName.rightAnchor.constraint(equalTo: rightAnchor, constant: -48).isActive = true
        lastName.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        addSubview(company)
        
        company.topAnchor.constraint(equalTo: lastName.bottomAnchor, constant: 4).isActive = true
        company.leftAnchor.constraint(equalTo: leftAnchor, constant: 48).isActive = true
        company.rightAnchor.constraint(equalTo: rightAnchor, constant: -48).isActive = true
        company.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        addSubview(email)
        
        email.topAnchor.constraint(equalTo: company.bottomAnchor, constant: 4).isActive = true
        email.leftAnchor.constraint(equalTo: leftAnchor, constant: 48).isActive = true
        email.rightAnchor.constraint(equalTo: rightAnchor, constant: -48).isActive = true
        email.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        addSubview(phone)
        
        phone.topAnchor.constraint(equalTo: email.bottomAnchor, constant: 4).isActive = true
        phone.leftAnchor.constraint(equalTo: leftAnchor, constant: 48).isActive = true
        phone.rightAnchor.constraint(equalTo: rightAnchor, constant: -48).isActive = true
        phone.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        addSubview(address)
        
        address.topAnchor.constraint(equalTo: phone.bottomAnchor, constant: 4).isActive = true
        address.leftAnchor.constraint(equalTo: leftAnchor, constant: 48).isActive = true
        address.rightAnchor.constraint(equalTo: rightAnchor, constant: -48).isActive = true
        address.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        addSubview(postalCode)
        
        postalCode.topAnchor.constraint(equalTo: address.bottomAnchor, constant: 4).isActive = true
        postalCode.rightAnchor.constraint(equalTo: rightAnchor, constant: -48).isActive = true
        postalCode.widthAnchor.constraint(equalToConstant: 120).isActive = true
        postalCode.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        addSubview(state)
        
        state.topAnchor.constraint(equalTo: address.bottomAnchor, constant: 4).isActive = true
        state.rightAnchor.constraint(equalTo: postalCode.leftAnchor, constant: -24).isActive = true
        state.widthAnchor.constraint(equalToConstant: 80).isActive = true
        state.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        addSubview(city)
        
        city.topAnchor.constraint(equalTo: address.bottomAnchor, constant: 4).isActive = true
        city.leftAnchor.constraint(equalTo: leftAnchor, constant: 48).isActive = true
        city.rightAnchor.constraint(equalTo: state.leftAnchor, constant: -24).isActive = true
        city.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        addSubview(save)
        
        save.leftAnchor.constraint(equalTo: leftAnchor, constant: 48).isActive = true
        save.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32).isActive = true
        
        save.widthAnchor.constraint(equalToConstant: 160).isActive = true
        save.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    @objc func saveInfo() {
        let billingInfo = BillingInfo(_id: nil,
                                      firstName: firstName.text,
                                      lastName: lastName.text,
                                      company: company.text,
                                      email: email.text,
                                      phone: phone.text,
                                      address: address.text,
                                      city: city.text,
                                      state: state.text,
                                      country: country.text,
                                      postalCode: postalCode.text,
                                      isDefault: false)
        
        [
            firstName,
            lastName,
            company,
            email,
            phone,
            address,
            city,
            state,
            country,
            postalCode
        ].forEach { $0.resignFirstResponder() }
        
        delegate?.addBillingInfoShouldSaveInfo(billingInfo: billingInfo)
        
        
//        cardNumber.resignFirstResponder()
//        cvc.resignFirstResponder()
//        expirationMonth.resignFirstResponder()
//        expirationYear.resignFirstResponder()
        
        
        // country = "US"
        
//        let card = CreditCard(number: cardNumber.text ?? "",
//                              cvc: cvc.text ?? "",
//                              expirationMonth: expirationMonth.text ?? "",
//                              expirationYear: expirationYear.text ?? "",
//                              billingInfo: [:])
//        delegate?.addPaymentShouldSaveCard(creditCard: card)
    }
    
}
