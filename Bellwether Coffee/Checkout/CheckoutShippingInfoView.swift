//
//  CheckoutShippingInfoView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/25/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class CheckoutShippingInfoView: CheckoutProcessStepView {
    
    var title: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 19)
        label.textColor = BellwetherColor.roast
        label.text = "Shipping Info"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var customerName: StatisticLabel = {
        let label = StatisticLabel(frame: .zero)
        label.valueColor = UIColor(white: 0.6, alpha: 1.0)
        label.statisticText = "Customer Name"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var company: StatisticLabel = {
        let label = StatisticLabel(frame: .zero)
        label.valueColor = UIColor(white: 0.6, alpha: 1.0)
        label.statisticText = "Company"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var address: StatisticLabel = {
        let label = StatisticLabel(frame: .zero)
        label.valueColor = UIColor(white: 0.6, alpha: 1.0)
        label.statisticText = "Address"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var phone: StatisticLabel = {
        let label = StatisticLabel(frame: .zero)
        label.valueColor = UIColor(white: 0.6, alpha: 1.0)
        label.statisticText = "Phone"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        
        stepTitle = "Delivery Option: UPS Ground ($15.99)"
        
        //        addSubview(title)
        //
        //        title.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        //        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        //        title.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        
        addSubview(customerName)
        
        customerName.topAnchor.constraint(equalTo: topAnchor, constant: 60).isActive = true
        customerName.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        customerName.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        
        addSubview(company)
        
        company.topAnchor.constraint(equalTo: customerName.bottomAnchor, constant: 20).isActive = true
        company.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        company.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        
        addSubview(address)
        
        address.topAnchor.constraint(equalTo: company.bottomAnchor, constant: 20).isActive = true
        address.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        address.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        
        addSubview(phone)
        
        phone.topAnchor.constraint(equalTo: address.bottomAnchor, constant: 20).isActive = true
        phone.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        phone.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        
        addSubview(confirm)
        
        confirm.topAnchor.constraint(equalTo: phone.bottomAnchor, constant: 16).isActive = true
        confirm.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        confirm.widthAnchor.constraint(equalToConstant: 128).isActive = true
        confirm.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        //        bottomAnchor.constraint(equalTo: confirm.bottomAnchor, constant: 16).isActive = true
        
        alignBottom(toView: confirm, offset: 16)
    }
    
    func confirmSection() {
        confirm.backgroundColor = .clear
        confirm.setAttributedTitle(confirmedTitle, for: .normal)
    }
    
}
