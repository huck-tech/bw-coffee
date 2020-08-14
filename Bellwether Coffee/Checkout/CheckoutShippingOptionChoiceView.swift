//
//  CheckoutShippingOptionChoiceView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/25/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class CheckoutShippingOptionChoiceView: View {
    
    var selected: Bool = false {
        didSet { updateSelected() }
    }
    
    var optionName: String? {
        didSet { option.text = optionName }
    }
    
    var check: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(named: "ship_option_unchecked")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var option: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = BellwetherColor.roast
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var button: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func setupViews() {
        addSubview(check)
        
        check.topAnchor.constraint(equalTo: topAnchor, constant: 6).isActive = true
        check.leftAnchor.constraint(equalTo: leftAnchor, constant: 6).isActive = true
        check.widthAnchor.constraint(equalToConstant: 26).isActive = true
        check.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        addSubview(option)
        
        option.topAnchor.constraint(equalTo: topAnchor, constant: 6).isActive = true
        option.leftAnchor.constraint(equalTo: check.rightAnchor, constant: 6).isActive = true
        option.rightAnchor.constraint(equalTo: rightAnchor, constant: -6).isActive = true
        option.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        addSubview(button)
        
        button.topAnchor.constraint(equalTo: topAnchor).isActive = true
        button.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func updateSelected() {
        check.image = selected ? UIImage(named: "ship_option_checked") : UIImage(named: "ship_option_unchecked")
    }
    
}
