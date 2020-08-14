//
//  LoginMethodView.swift
//  Bellwether Coffee
//
//  Created by Gabe The Coder on 12/11/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit

class LoginMethodView: ComponentView {
    
    var title: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "OpenSans-Semibold", size: 17)
        label.textColor = UIColor(white: 0.25, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Sign In"
        return label
    }()
    
    var subtitle: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "OpenSans-Semibold", size: 13)
        label.textColor = UIColor(white: 0.72, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "You should sign in first."
        return label
    }()
    
    var facebook: LoginButton = {
        let button = LoginButton(frame: .zero)
        button.title = "Sign in with Facebook"
        button.icon = UIImage(named: "login_facebook")
        button.iconAlignment = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var google: LoginButton = {
        let button = LoginButton(frame: .zero)
        button.title = "Sign in with Google"
        button.icon = UIImage(named: "login_google")
        button.iconAlignment = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var email: LoginButton = {
        let button = LoginButton(frame: .zero)
        button.title = "Sign in with email"
        button.icon = UIImage(named: "login_email")
        button.iconAlignment = .left
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
        
        addSubview(facebook)
        
        facebook.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 20).isActive = true
        facebook.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        facebook.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        facebook.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        addSubview(google)
        
        google.topAnchor.constraint(equalTo: facebook.bottomAnchor, constant: 16).isActive = true
        google.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        google.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        google.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        addSubview(email)
        
        email.topAnchor.constraint(equalTo: google.bottomAnchor, constant: 16).isActive = true
        email.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        email.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        email.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
}
