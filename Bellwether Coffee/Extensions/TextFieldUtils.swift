//
//  TextFieldUtils.swift
//  Bellwether Coffee
//
//  Created by Gabe The Coder on 12/11/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit

extension UITextField {
    
    func setPlaceholder(placeholder: String) {
        let renderer = TextRenderer()
        renderer.font = UIFont(name: "OpenSans-Semibold", size: 15)
        renderer.color = UIColor(white: 0.8, alpha: 1.0)
        renderer.appendText(string: placeholder)
        attributedPlaceholder = renderer.renderedText
    }
    
    func addSeparator(textField: UITextField) {
        let separator = UIView(frame: .zero)
        separator.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)
        
        separator.leftAnchor.constraint(equalTo: textField.leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: textField.rightAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: textField.bottomAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
}
