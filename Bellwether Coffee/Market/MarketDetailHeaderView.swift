//
//  MarketDetailHeaderView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/2/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

enum MarketDetailHeaderAction {
    case addToCart
    case learnMore
    case favorite
}

class MarketDetailHeaderView: ComponentView {
    
    var photo: MarketPhotoView = {
        let photoView = MarketPhotoView(frame: .zero)
        photoView.translatesAutoresizingMaskIntoConstraints = false
        return photoView
    }()
    
    var name: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 21)
        label.textColor = UIColor(white: 0.25, alpha: 1.0)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        return label
    }()
    
    lazy var favorite: BouncyButton = {
        let button = BouncyButton(type: .custom)
        button.frame = .zero
        button.adjustsImageWhenHighlighted = false
        button.setImage(UIImage(named: "heart"), for: .normal)
        button.addTarget(self, action: #selector(selectFavorite), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var favorited = false {
        didSet { updateFavorited() }
    }
    
    lazy var cart: BouncyButton = {
        let button = BouncyButton(type: .custom)
        button.setAttributedTitle(cartTitle, for: .normal)
        button.backgroundColor = .brandPurple
        button.tintColor = .brandPurple
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(selectCart), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var cartTitle: NSAttributedString = {
        let renderer = TextRenderer()
        renderer.font = UIFont(name: "AvenirNext-Medium", size: 16)
        renderer.color = UIColor(white: 1.0, alpha: 1.0)
        renderer.appendText(string: "Add To Cart")
        return renderer.renderedText
    }()
    
    var actionHandler: ((MarketDetailHeaderAction) -> Void)?
    
    var cartWidth: NSLayoutConstraint?
    
    override func setupViews() {
        backgroundColor = UIColor(white: 1.0, alpha: 0.95)
        
        addSubview(photo)
        
        photo.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        photo.leftAnchor.constraint(equalTo: leftAnchor, constant: 14).isActive = true
        photo.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        photo.heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        addSubview(cart)
        
        cart.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: 20).isActive = true
        cart.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        cart.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        cartWidth = cart.widthAnchor.constraint(equalToConstant: 30)
        cartWidth?.isActive = true
        
        addSubview(favorite)
        
        favorite.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: 20).isActive = true
        favorite.rightAnchor.constraint(equalTo: cart.leftAnchor, constant: -12).isActive = true
        favorite.widthAnchor.constraint(equalToConstant: 30).isActive = true
        favorite.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        addSubview(name)
        
        name.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: 20).isActive = true
        name.leftAnchor.constraint(equalTo: leftAnchor, constant: 14).isActive = true
        name.rightAnchor.constraint(equalTo: favorite.leftAnchor, constant: -14).isActive = true
        
        // the header should always dynamically adjust to how tall the name is
        bottomAnchor.constraint(equalTo: name.bottomAnchor, constant: 20).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        calculateCartWidth()
    }
    
    func updateFavorited() {
        let heartFill = favorited ? UIImage(named: "heart_filled") : UIImage(named: "heart")
        favorite.setImage(heartFill, for: .normal)
    }
    
    @objc func selectFavorite() {
        favorited = favorited.toggled
        actionHandler?(.favorite)
    }
    
    @objc func selectCart() {
        actionHandler?(.addToCart)
    }
    
}

// MARK: Sizing Helpers

extension MarketDetailHeaderView {
    
    func calculateCartWidth() {
        let width = bounds.width
        
        if width > 384 {
            cartWidth?.constant = 136
            
            cart.setAttributedTitle(cartTitle, for: .normal)
            cart.backgroundColor = .brandPurple
            cart.setImage(nil, for: .normal)
        } else {
            cartWidth?.constant = 30
            
            cart.setAttributedTitle(nil, for: .normal)
            cart.backgroundColor = .clear
            
            let cartImage = UIImage(named: "cart")?.withRenderingMode(.alwaysTemplate)
            cart.setImage(cartImage, for: .normal)
        }
    }
    
}
