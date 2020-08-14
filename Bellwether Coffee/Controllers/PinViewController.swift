//
//  PinViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/22/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class PinViewController: UIViewController {
    
    var logo: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "login_logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var keypad: PinKeypadView = {
        let keypadView = PinKeypadView(frame: .zero)
        keypadView.translatesAutoresizingMaskIntoConstraints = false
        return keypadView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateEntrance()
    }
    
}

// MARK: Layout

extension PinViewController {
    
    func setupAppearance() {
        view.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
    }
    
    func setupLayout() {
        view.addSubview(logo)
        
        logo.topAnchor.constraint(equalTo: view.topAnchor, constant: 128).isActive = true
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logo.widthAnchor.constraint(equalToConstant: 100).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        view.addSubview(keypad)
        
        keypad.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 30).isActive = true
        keypad.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        keypad.widthAnchor.constraint(equalToConstant: 300).isActive = true
        keypad.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        logo.alpha = 0.0
        keypad.alpha = 0.0
    }
    
}

// MARK: Animations

extension PinViewController {
    
    func animateEntrance() {
        UIView.animate(withDuration: 0.5, delay: 0.0, animations: { [unowned self] in
            self.logo.alpha = 1.0
        })
        
        UIView.animate(withDuration: 0.5, delay: 0.3, animations: { [unowned self] in
            self.keypad.alpha = 1.0
        })
    }
    
}
