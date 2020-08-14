//
//  LoginButton.swift
//  Bellwether Coffee
//
//  Created by Gabe The Coder on 12/11/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit

class LoginButton: ComponentView {
    
    var button: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = .zero
        button.titleLabel?.font = UIFont(name: "OpenSans-Semibold", size: 13)
        button.setTitleColor(UIColor(white: 0.3, alpha: 1.0), for: .normal)
        button.contentHorizontalAlignment = .center
        button.setTitle("", for: .normal)
        button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var iconImage: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var title: String? {
        didSet { button.setTitle(title, for: .normal) }
    }
    
    var icon: UIImage? {
        didSet { iconImage.image = icon }
    }
    
    var iconAlignment: UIControlContentHorizontalAlignment! {
        didSet {
            if iconAlignment == .left {
                iconImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 22).isActive = true
            }
            
            if iconAlignment == .right {
                iconImage.rightAnchor.constraint(equalTo: rightAnchor, constant: -22).isActive = true
            }
        }
    }
    
    var action: (() -> Void)?
    
    override func setupViews() {
        addSubview(button)
        
        button.topAnchor.constraint(equalTo: topAnchor).isActive = true
        button.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        button.addSubview(iconImage)
        
        iconImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        iconImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        iconImage.widthAnchor.constraint(equalToConstant: 24).isActive = true
    }
    
    @objc func buttonTouchDown() {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
    }
    
    @objc func buttonTouchUp() {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, animations: {
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
        
        action?()
    }
    
}

