//
//  AddPaymentFooter.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/1/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class AddPaymentFooter: View {
    
    var addPayment: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 15)
        button.setTitleColor(UIColor(white: 0.5, alpha: 1.0), for: .normal)
        button.contentHorizontalAlignment = .left
        button.setTitle("Add Payment Method", for: .normal)
        button.addTarget(self, action: #selector(selectAddPayment), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var action: (() -> Void)?
    
    override func setupViews() {
        addSubview(addPayment)
        
        addPayment.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        addPayment.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    }
    
    @objc func selectAddPayment() {
        action?()
    }
    
}
