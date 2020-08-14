//
//  LoginViewController.swift
//  Bellwether Coffee
//
//  Created by Gabe The Coder on 12/11/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit
import SwiftyAttributes
protocol AuthViewControllerDelegate {
    func loginDidAuthenticateSuccessfully()
}

protocol AuthFlowViewControllerDelegate : AuthViewControllerDelegate {
    func showPinAuth()
    func showPasswordAuth()
}


class LoginViewController: UIViewController {
    
    var delegate: AuthFlowViewControllerDelegate?
    
    override var prefersStatusBarHidden: Bool {return true}
    
    var logo: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(named: "login_logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var email: UITextField = {
        let renderer = TextRenderer()
        renderer.color = UIColor(white: 1.0, alpha: 0.3)
        renderer.font = UIFont(name: "AvenirNext-Regular", size: 20)
        renderer.appendText(string: "email")
        
        let textField = UITextField(frame: .zero)
        textField.font = UIFont(name: "AvenirNext-Regular", size: 20)
        textField.textColor = UIColor(white: 1.0, alpha: 1.0)
        textField.textAlignment = .center
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.keyboardType = .emailAddress
        textField.keyboardAppearance = .dark
        textField.attributedPlaceholder = renderer.renderedText
        textField.text = ""
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    var instructions: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 18.0)
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var password: UITextField = {
        let renderer = TextRenderer()
        renderer.color = UIColor(white: 1.0, alpha: 0.3)
        renderer.font = UIFont(name: "AvenirNext-Regular", size: 20)
        renderer.appendText(string: "password")
        
        let textField = UITextField(frame: .zero)
        textField.font = UIFont(name: "AvenirNext-Regular", size: 20)
        textField.textColor = UIColor(white: 1.0, alpha: 1.0)
        textField.textAlignment = .center
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.keyboardType = .asciiCapable
        textField.keyboardAppearance = .dark
        textField.attributedPlaceholder = renderer.renderedText
        textField.text = ""
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var submit: UIButton = {
        let button = UIButton(frame: .zero)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 17)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Sign In", for: .normal)
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.backgroundColor = .brandPurple
        button.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private func setupInstructions(){
        instructions.attributedText = "Login".withTextColor(.brandPurple) + " with your PIN instead.".attributedString
        instructions.onTap(target: self, selector: #selector(showPin))

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupLayout()
        setupInstructions()
        
        fetchCredentials()
    }
    
    @objc func showPin(){
        self.delegate?.showPinAuth()
    }
    
    @objc func signIn() {
        let userEmail = email.text ?? ""
        let userPassword = password.text ?? ""
        
        BellwetherAPI.auth.signIn(email: userEmail, password: userPassword) { [weak self] error in
            guard error == .none else {
                self?.showError()
                return
            }
            
            //lock down the app to this cafe
            if let cafe = BellwetherAPI.auth.cafe {
                Defaults.shared.set(cafe: cafe)
            }
            
            self?.saveCredentials(email: userEmail, password: userPassword)
            
            //record that we have last authenticated with password
            Defaults.shared.set(usePin: false)
            
            self?.delegate?.loginDidAuthenticateSuccessfully()
        }
    }
    
    func saveCredentials(email: String, password: String) {
        let credentials = ["email": email, "password": password]
        
        UserDefaults.standard.set(credentials, forKey: "userCredentials")
        UserDefaults.standard.synchronize()
    }
    
    func fetchCredentials() {
        guard let credentials = UserDefaults.standard.object(forKey: "userCredentials") as? [String: Any] else { return }
        
        email.text = credentials["email"] as? String
        password.text = credentials["password"] as? String
    }
    
    func showError() {
        let alert = UIAlertController(title: "Could Not Sign In", message: "Check your username and password and try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default))
        present(alert, animated: true)
    }
    
}

// MARK: Layout

extension LoginViewController {
    
    func setupAppearance() {
        view.backgroundColor = UIColor.brandBackground
    }
    
    func setupLayout() {
        view.addSubview(logo)
        
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logo.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        logo.widthAnchor.constraint(equalToConstant: 100).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        view.addSubview(email)
        
        email.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        email.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 24).isActive = true
        email.widthAnchor.constraint(equalToConstant: 380).isActive = true
        email.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        view.addSubview(password)
        
        password.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        password.topAnchor.constraint(equalTo: email.bottomAnchor, constant: 8).isActive = true
        password.widthAnchor.constraint(equalToConstant: 380).isActive = true
        password.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        view.addSubview(submit)
        
        submit.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        submit.topAnchor.constraint(equalTo: password.bottomAnchor, constant: 16).isActive = true
        submit.widthAnchor.constraint(equalToConstant: 140).isActive = true
        submit.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        view.addSubview(instructions)
        
        instructions.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        instructions.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        instructions.heightAnchor.constraint(equalToConstant: 44).isActive = true
        instructions.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -52).isActive = true

    }
    
}

