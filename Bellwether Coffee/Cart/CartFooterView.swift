//
//  CartFooterView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

protocol CartFooterViewDelegate: class {
    func cartFooterDidSelectCheckout()
}

class CartFooterView: View {
    
    weak var delegate: CartFooterViewDelegate?
    
    var checkoutEnabled: Bool = false {
        didSet { updateCheckoutEnabled() }
    }
    
    var note: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Regular", size: 16)
        label.textColor = BellwetherColor.roast
        label.numberOfLines = 3
        label.text = "Note: We cannot guarantee the quantities of coffees in your cart are available for purchase until checkout is complete. If the quantities are not available at this time, we will notify you before your final purchase."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var subtotal: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 20)
        label.textColor = BellwetherColor.roast
        label.text = "Cart Subtotal"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var price: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 20)
        label.textColor = BellwetherColor.roast
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var checkout: BouncyButton = {
        let button = BouncyButton(type: .custom)
        button.setAttributedTitle(checkoutTitle, for: .normal)
        button.backgroundColor = .brandPurple
        button.tintColor = .brandPurple
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(selectCheckout), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var checkoutTitle: NSAttributedString = {
        let renderer = TextRenderer()
        renderer.font = UIFont(name: "AvenirNext-Medium", size: 16)
        renderer.color = UIColor(white: 1.0, alpha: 1.0)
        renderer.appendText(string: "Checkout")
        return renderer.renderedText
    }()
    
    override func setupViews() {
        addSubview(price)
        
        price.topAnchor.constraint(equalTo: topAnchor, constant: 32).isActive = true
        price.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
        
        addSubview(subtotal)
        
        subtotal.topAnchor.constraint(equalTo: topAnchor, constant: 32).isActive = true
        subtotal.rightAnchor.constraint(equalTo: price.leftAnchor, constant: -16).isActive = true
        
        addSubview(note)
        
        note.topAnchor.constraint(equalTo: topAnchor, constant: 32).isActive = true
        note.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
        note.rightAnchor.constraint(equalTo: subtotal.leftAnchor, constant: -120).isActive = true
        
        addSubview(checkout)
        
        checkout.topAnchor.constraint(equalTo: subtotal.bottomAnchor, constant: 32).isActive = true
        checkout.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
        checkout.widthAnchor.constraint(equalToConstant: 140).isActive = true
        checkout.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    func updateCheckoutEnabled() {
        if checkoutEnabled {
            checkout.alpha = 1.0
            checkout.isEnabled = true
        } else {
            checkout.alpha = 0.5
            checkout.isEnabled = false
        }
    }
    
    @objc func selectCheckout() {
        delegate?.cartFooterDidSelectCheckout()
    }
    
}
