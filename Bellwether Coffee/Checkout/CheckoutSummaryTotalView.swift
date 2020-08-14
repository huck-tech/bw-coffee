//
//  CheckoutSummaryTotalView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/23/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class CheckoutSummaryTotalView: ComponentView {
    
    var cartSubtotal: TotalView = {
        let totalView = TotalView(frame: .zero)
        totalView.name.text = "Cart Subtotal"
        totalView.price.text = 0.00.formattedPrice()
        return totalView
    }()
    
    var shipping: TotalView = {
        let totalView = TotalView(frame: .zero)
        totalView.name.text = "Shipping"
        totalView.price.text = 0.00.formattedPrice()
        return totalView
    }()
    
    var discounts: TotalView = {
        let totalView = TotalView(frame: .zero)
        totalView.name.text = "Discounts Applied"
        totalView.price.text = 0.00.formattedPrice()
        return totalView
    }()
    
    var salesTax: TotalView = {
        let totalView = TotalView(frame: .zero)
        totalView.name.text = "Sales Tax"
        totalView.price.text = 0.00.formattedPrice()
        return totalView
    }()
    
    var total: TotalView = {
        let totalView = TotalView(frame: .zero)
        totalView.primary = true
        totalView.name.text = "Total"
        totalView.price.text = 0.00.formattedPrice()
        return totalView
    }()
    
    lazy var placeOrder: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .brandPurple
        button.setAttributedTitle(confirmTitle, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var notice: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 14)
        label.textColor = UIColor(white: 0.6, alpha: 1.0)
        label.textAlignment = .left
        label.text = "Availability of coffees in cart is not guaranteed until checkout is complete."
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var confirmTitle: NSAttributedString = {
        let renderer = TextRenderer()
        renderer.font = UIFont(name: "AvenirNext-Medium", size: 16)
        renderer.color = UIColor(white: 1.0, alpha: 1.0)
        renderer.appendText(string: "Place Order")
        return renderer.renderedText
    }()
    
    private var confirmedTitle: NSAttributedString = {
        let renderer = TextRenderer()
        renderer.font = UIFont(name: "AvenirNext-Medium", size: 16)
        renderer.color = .brandPurple
        renderer.appendText(string: "Placing Order")
        return renderer.renderedText
    }()
    
    var confirmed: Bool = false {
        didSet { updateConfirmed() }
    }
    
    var separator: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func setupViews() {
        backgroundColor = .white
        
        addSubview(notice)
        
        notice.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        notice.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        notice.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24).isActive = true
        
        addSubview(placeOrder)
        
        placeOrder.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        placeOrder.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        placeOrder.bottomAnchor.constraint(equalTo: notice.topAnchor, constant: -16).isActive = true
        placeOrder.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let totals = UIStackView(arrangedSubviews: [cartSubtotal, shipping, discounts, salesTax, total])
        totals.axis = .vertical
        totals.distribution = .fillEqually
        totals.translatesAutoresizingMaskIntoConstraints = false
        addSubview(totals)
        
        totals.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        totals.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        totals.bottomAnchor.constraint(equalTo: placeOrder.topAnchor, constant: -20).isActive = true
        totals.heightAnchor.constraint(equalToConstant: 140).isActive = true
        
        addSubview(separator)
        
        separator.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        topAnchor.constraint(equalTo: totals.topAnchor, constant: -24).isActive = true
    }
    
    func updateConfirmed() {
        placeOrder.backgroundColor = confirmed ? .clear : .brandPurple
        placeOrder.setAttributedTitle(confirmed ? confirmedTitle : confirmTitle, for: .normal)
    }
    
}

class TotalView: ComponentView {
    
    var primary = false {
        didSet { updatePrimary() }
    }
    
    var name: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var price: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func setupViews() {
        addSubview(name)
        
        name.topAnchor.constraint(equalTo: topAnchor).isActive = true
        name.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        name.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addSubview(price)
        
        price.topAnchor.constraint(equalTo: topAnchor).isActive = true
        price.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
        price.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        
    }
    
    func updatePrimary() {
        if primary {
            name.font = UIFont(name: "AvenirNext-Demibold", size: 16)
            price.font = UIFont(name: "AvenirNext-Demibold", size: 16)
        } else {
            name.font = UIFont(name: "AvenirNext-Medium", size: 16)
            price.font = UIFont(name: "AvenirNext-Medium", size: 16)
        }
    }
    
}
