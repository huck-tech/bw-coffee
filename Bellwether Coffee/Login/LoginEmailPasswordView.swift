//
//  LoginEmailPasswordView.swift
//  Bellwether Coffee
//
//  Created by Gabe The Coder on 12/11/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit

class LoginEmailPasswordView: ComponentView {
    
    var title: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "OpenSans-Semibold", size: 17)
        label.textColor = UIColor(white: 0.25, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Email"
        return label
    }()
    
    var subtitle: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "OpenSans-Semibold", size: 13)
        label.textColor = UIColor(white: 0.72, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Sign in with your email."
        return label
    }()
    
    var email: UITextField = {
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
    
    var password: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.font = UIFont(name: "OpenSans-Semibold", size: 15)
        textField.textColor = UIColor(white: 0.25, alpha: 1.0)
        textField.textAlignment = .left
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var login: LoginButton = {
        let button = LoginButton(frame: .zero)
        button.title = "Sign In"
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
        
        email.delegate = self
        addSubview(email)
        
        email.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 16).isActive = true
        email.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        email.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        email.heightAnchor.constraint(equalToConstant: 44).isActive = true
        email.addSeparator(textField: email)
        
        password.delegate = self
        addSubview(password)
        
        password.topAnchor.constraint(equalTo: email.bottomAnchor, constant: 8).isActive = true
        password.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        password.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        password.heightAnchor.constraint(equalToConstant: 44).isActive = true
        password.addSeparator(textField: password)
        
        email.setPlaceholder(placeholder: "email")
        password.setPlaceholder(placeholder: "password")
        
        addSubview(login)
        
        login.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -28).isActive = true
        login.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        login.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        login.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
}

extension LoginEmailPasswordView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
