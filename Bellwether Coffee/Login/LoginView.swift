//
//  LoginView.swift
//  Bellwether Coffee
//
//  Created by Gabe The Coder on 12/11/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit

enum LoginMethod {
    case facebook
    case google
    case email
}

protocol LoginViewDelegate: class {
    func loginViewDidRequestSocialMethodSignUp(_ login: LoginView, method: LoginMethod)
    func loginViewDidRequestEmailSignIn(_ login: LoginView, email: String?, password: String?)
    func loginViewDidRequestEmailSignUp(_ login: LoginView, email: String?, password: String?, username: String?, name: String?)
}

class LoginView: ComponentView {
    
    weak var delegate: LoginViewDelegate?
    
    var navigation: LoginNavigationView = {
        let loginNavigation = LoginNavigationView(frame: .zero)
        loginNavigation.translatesAutoresizingMaskIntoConstraints = false
        return loginNavigation
    }()
    
    var methods: LoginMethodView = {
        let loginMethod = LoginMethodView(frame: .zero)
        loginMethod.translatesAutoresizingMaskIntoConstraints = false
        return loginMethod
    }()
    
    var email: LoginEmailPasswordView = {
        let emailPassword = LoginEmailPasswordView(frame: .zero)
        emailPassword.translatesAutoresizingMaskIntoConstraints = false
        return emailPassword
    }()
    
    var newAccount: LoginCreateAccountView = {
        let createAccount = LoginCreateAccountView(frame: .zero)
        createAccount.translatesAutoresizingMaskIntoConstraints = false
        return createAccount
    }()
    
    override func setupViews() {
        setupAppearance()
        setupLayout()
        
        setupLoginActions()
    }
    
    func setupAppearance() {
        backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        
        layer.masksToBounds = true
        layer.cornerRadius = 3
        
        layer.shadowColor = UIColor(white: 0.1, alpha: 1.0).cgColor
        layer.shadowOffset = CGSize(width: 1, height: 0)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.3
    }
    
    func setupLayout() {
        navigation.delegate = self
        addSubview(navigation)
        
        navigation.topAnchor.constraint(equalTo: topAnchor).isActive = true
        navigation.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        navigation.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        navigation.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        navigation.pageViews = [methods, email, newAccount]
    }
    
    func show() {
        animateInBottom(view: self, delay: 0.0)
    }
    
    func hide() {
        animateOutBottom(view: self, delay: 0.0)
    }
    
    func reset() {
        transform = CGAffineTransform(translationX: 0, y: bounds.height)
        navigation.navigateToRoot()
        
        email.email.text = ""
        email.password.text = ""
        newAccount.username.text = ""
        newAccount.name.text = ""
    }
    
    func setupLoginActions() {
        methods.email.action = { [unowned self] in
            self.navigation.navigateForwardst()
        }
        
        methods.facebook.action = { [unowned self] in
            self.delegate?.loginViewDidRequestSocialMethodSignUp(self, method: .facebook)
        }
        
        methods.google.action = { [unowned self] in
            self.delegate?.loginViewDidRequestSocialMethodSignUp(self, method: .google)
        }
        
        email.login.action = { [unowned self] in
            self.delegate?.loginViewDidRequestEmailSignIn(self,
                                                          email: self.email.email.text,
                                                          password: self.email.password.text)
        }
        
        newAccount.signUp.action = { [unowned self] in
            self.delegate?.loginViewDidRequestEmailSignUp(self,
                                                          email: self.email.email.text,
                                                          password: self.email.password.text,
                                                          username: self.newAccount.username.text,
                                                          name: self.newAccount.name.text)
        }
    }
    
}

extension LoginView: LoginNavigationViewDelegate {
    
    func loginNavigationDidSegue(_ navigation: LoginNavigationView, direction: LoginNavigationDirection) {
        stopEditingAllText()
    }
    
    func stopEditingAllText() {
        email.email.resignFirstResponder()
        email.password.resignFirstResponder()
        
        newAccount.name.resignFirstResponder()
        newAccount.username.resignFirstResponder()
    }
    
}

// MARK: Animations

extension LoginView {
    
    func animateInBottom(view: UIView, delay: TimeInterval) {
        view.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.3, animations: {
            view.transform = CGAffineTransform(translationX: 0, y: 0)
        })
    }
    
    func animateOutBottom(view: UIView, delay: TimeInterval) {
        view.transform = CGAffineTransform(translationX: 0, y: 0)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.3, animations: {
            view.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
        })
    }
    
}
