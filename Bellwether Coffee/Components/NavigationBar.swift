//
//  NavigationBar.swift
//  Bellwether Coffee
//
//  Created by Gabe The Coder on 12/11/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit

class NavigationBar: ComponentView {
    
    var titleText: String! {
        didSet { updateTitleText() }
    }
    
    var title: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var separator: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.08)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var menu: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = .zero
        button.setImage(UIImage(named: "nav_menu"), for: .normal)
        button.addTarget(self, action: #selector(selectMenu), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var rightBadge: UILabel = {
        let label = UILabel(frame: .zero)
        label.layer.cornerRadius = 11
        label.layer.masksToBounds = true
        label.font = UIFont(name: "AvenirNext-Demibold", size: 12)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor =  .brandPurple
        label.alpha = 0.0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var rightButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = .zero
        button.addTarget(self, action: #selector(selectRightButton), for: .touchUpInside)
        button.alpha = 0.75
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var contactButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = .zero
        button.addTarget(self, action: #selector(selectContact), for: .touchUpInside)
        button.alpha = 1.0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var menuAction: (() -> Void)?
    var contactAction: (() -> Void)?
    
    var rightNavButton: NavigationButton? {
        didSet { updateRightNavButton() }
    }
    
    var contactNavButton: NavigationButton? {
        didSet { updateContactNavButton() }
    }
    
    var rightBadgeNumber: Int = 0 {
        didSet { updateRightBadgeNumber() }
    }
    
    override func setupViews() {
        backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        
//        layer.shadowColor = UIColor(white: 0.1, alpha: 1.0).cgColor
//        layer.shadowOffset = CGSize(width: 1, height: 0)
//        layer.shadowRadius = 10
//        layer.shadowOpacity = 0.1
        
        addSubview(title)
        
        title.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        title.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        title.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        title.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        addSubview(separator)
        
        separator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        addSubview(menu)
        
        menu.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 4).isActive = true
        menu.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        menu.widthAnchor.constraint(equalToConstant: 44).isActive = true
        menu.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        addSubview(rightButton)
        
        rightButton.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -4).isActive = true
        rightButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        rightButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        rightButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        addSubview(rightBadge)
        
        rightBadge.topAnchor.constraint(equalTo: rightButton.topAnchor, constant: -2).isActive = true
        rightBadge.rightAnchor.constraint(equalTo: rightButton.rightAnchor, constant: 0).isActive = true
        rightBadge.widthAnchor.constraint(equalToConstant: 22).isActive = true
        rightBadge.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        addSubview(contactButton)
        
        contactButton.rightAnchor.constraint(equalTo: rightButton.leftAnchor, constant: -8).isActive = true
        contactButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contactButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        contactButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    @objc func selectMenu() {
        menuAction?()
    }
    
    func updateRightNavButton() {
        rightButton.setImage(rightNavButton?.image, for: .normal)
    }
    
    func updateContactNavButton() {
        contactButton.setImage(contactNavButton?.image, for: .normal)
    }
    
    func updateRightBadgeNumber() {
        rightBadge.text = "\(rightBadgeNumber)"
        
        if rightBadgeNumber > 0 {
            guard rightBadge.alpha == 0.0 else { return }
            
            rightBadge.alpha = 0.0
            rightBadge.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            
            UIView.animate(withDuration: 0.5,
                           delay: 0.0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.0,
                           options: [.allowUserInteraction],
                           animations: { [unowned self] in
                self.rightBadge.alpha = 1.0
                self.rightBadge.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
        } else {
            guard rightBadge.alpha == 1.0 else { return }
            
            rightBadge.alpha = 1.0
            rightBadge.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            
            UIView.animate(withDuration: 0.5,
                           delay: 0.0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.0,
                           options: [.allowUserInteraction],
                           animations: { [unowned self] in
                self.rightBadge.alpha = 0.0
                self.rightBadge.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            })
        }
    }
    
    func updateTitleText() {
        let renderer = TextRenderer()
        renderer.font = UIFont(name: "Nuckle-BoldTrial", size: 17)
        renderer.color = UIColor(white: 0.2, alpha: 1.0)
        renderer.spacing = 3
        renderer.appendText(string: titleText.uppercased())
        title.attributedText = renderer.renderedText
    }
    
    @objc func selectRightButton() {
        rightNavButton?.action?()
    }
    
    @objc func selectContact() {
        contactNavButton?.action?()
    }
    
}
