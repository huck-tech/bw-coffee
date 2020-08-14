//
//  ContactViewController.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/24/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController {
    
    weak var delegate: InventoryAddToGreenViewControllerDelegate?
    
    lazy var dismiss: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(dismissContact), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var card: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .brandIce
        view.alpha = 0.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var name: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 20)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var info: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Regular", size: 16)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .left
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var done: BouncyButton = {
        let button = BouncyButton(type: .custom)
        button.setAttributedTitle(doneTitle, for: .normal)
        button.backgroundColor = .brandPurple
        button.tintColor = .brandPurple
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(dismissContact), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var doneTitle: NSAttributedString = {
        let renderer = TextRenderer()
        renderer.font = UIFont(name: "AvenirNext-Medium", size: 16)
        renderer.color = UIColor(white: 1.0, alpha: 1.0)
        renderer.appendText(string: "Done")
        return renderer.renderedText
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupLayout()
        
        setupInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        animateEntrance()
    }
    
    func setupInfo() {
        name.text = "We're here to help."
        info.text = "If you have any questions or concerns, please call 510-985-1996 or email support@bellwethercoffee.com."
    }
    
    @objc func dismissContact() {
        dismiss(animated: true)
    }
    
}

// MARK: Layout

extension ContactViewController {
    
    func setupAppearance() {
        view.isOpaque = false
        view.backgroundColor = BellwetherColor.roastOverlay
    }
    
    func setupLayout() {
        view.addSubview(dismiss)
        
        dismiss.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        dismiss.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        dismiss.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        dismiss.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(card)
        
        card.widthAnchor.constraint(equalToConstant: 730).isActive = true
        card.heightAnchor.constraint(equalToConstant: 240).isActive = true
        card.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        card.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        card.addSubview(name)
        
        name.topAnchor.constraint(equalTo: card.topAnchor, constant: 50).isActive = true
        name.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 48).isActive = true
        
        card.addSubview(info)
        
        info.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 12).isActive = true
        info.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 48).isActive = true
        info.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -48).isActive = true
        
        card.addSubview(done)
        
        done.topAnchor.constraint(equalTo: info.bottomAnchor, constant: 26).isActive = true
        done.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 48).isActive = true
        done.widthAnchor.constraint(equalToConstant: 140).isActive = true
        done.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
}

// MARK: Animations

extension ContactViewController {
    
    func animateEntrance() {
        card.alpha = 0.0
        card.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.0,
                       options: [.allowUserInteraction],
                       animations: { [unowned self] in
                        self.card.alpha = 1.0
                        self.card.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
}
