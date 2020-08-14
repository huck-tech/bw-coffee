//
//  LoginCreateAccountView.swift
//  Bellwether Coffee
//
//  Created by Gabe The Coder on 12/11/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit

class LoginCreateAccountView: ComponentView {
    
    var title: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "OpenSans-Semibold", size: 17)
        label.textColor = UIColor(white: 0.25, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Sign Up"
        return label
    }()
    
    var subtitle: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "OpenSans-Semibold", size: 13)
        label.textColor = UIColor(white: 0.72, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Still haven't signed up?"
        return label
    }()
    
    var name: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.font = UIFont(name: "OpenSans-Semibold", size: 15)
        textField.textColor = UIColor(white: 0.25, alpha: 1.0)
        textField.textAlignment = .left
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var username: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.font = UIFont(name: "OpenSans-Semibold", size: 15)
        textField.textColor = UIColor(white: 0.25, alpha: 1.0)
        textField.textAlignment = .left
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var signUp: LoginButton = {
        let button = LoginButton(frame: .zero)
        button.title = "Create My Account"
        button.icon = UIImage(named: "login_forwardst")
        button.iconAlignment = .right
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func setupViews() {
        addSubview(title)
        
        title.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 14).isActive = true
        title.rightAnchor.constraint(equalTo: rightAnchor, constant: -14).isActive = true
        title.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        addSubview(subtitle)
        
        subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8).isActive = true
        subtitle.leftAnchor.constraint(equalTo: leftAnchor, constant: 14).isActive = true
        subtitle.rightAnchor.constraint(equalTo: rightAnchor, constant: -14).isActive = true
        subtitle.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        name.delegate = self
        addSubview(name)
        
        name.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 16).isActive = true
        name.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        name.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        name.heightAnchor.constraint(equalToConstant: 44).isActive = true
        name.addSeparator(textField: name)
        
        username.delegate = self
        addSubview(username)
        
        username.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 8).isActive = true
        username.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        username.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        username.heightAnchor.constraint(equalToConstant: 44).isActive = true
        username.addSeparator(textField: username)
        
        name.setPlaceholder(placeholder: "name")
        username.setPlaceholder(placeholder: "username")
        
        addSubview(signUp)
        
        signUp.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24).isActive = true
        signUp.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        signUp.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        signUp.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
}

extension LoginCreateAccountView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

