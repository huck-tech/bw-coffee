//
//  InventoryOrderCell.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 2/8/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class InventoryOrderCell: CollectionViewCell {
    
    var card: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .brandPurple
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var name: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = UIColor(white: 0.25, alpha: 1.0)
        label.textAlignment = .center
        label.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var lbs: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = UIColor(white: 0.25, alpha: 1.0)
        label.textAlignment = .center
        label.backgroundColor = .brandIce
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var order: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = UIColor(white: 0.25, alpha: 1.0)
        label.textAlignment = .center
        label.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var flag: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(named: "inventory_flag")
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var status: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Demibold", size: 16)
        label.textColor = UIColor(white: 0.25, alpha: 1.0)
        label.textAlignment = .center
        label.backgroundColor = .brandIce
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var cardWidth: NSLayoutConstraint?
    
    override func setupViews() {
        setupAppearance()
        setupLayout()
    }
    
    func setupAppearance() {
        backgroundColor = .clear
    }
    
    func setupLayout() {
        addSubview(card)
        
        card.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        card.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        
        cardWidth = card.widthAnchor.constraint(equalToConstant: 225)
        cardWidth?.isActive = true
        
        card.addSubview(name)
        
        name.topAnchor.constraint(equalTo: card.topAnchor).isActive = true
        name.leftAnchor.constraint(equalTo: card.leftAnchor).isActive = true
        name.rightAnchor.constraint(equalTo: card.rightAnchor).isActive = true
        name.heightAnchor.constraint(equalToConstant: 74).isActive = true
        
        card.addSubview(lbs)
        
        lbs.topAnchor.constraint(equalTo: name.bottomAnchor).isActive = true
        lbs.leftAnchor.constraint(equalTo: card.leftAnchor).isActive = true
        lbs.rightAnchor.constraint(equalTo: card.rightAnchor).isActive = true
        lbs.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        card.addSubview(order)
        
        order.topAnchor.constraint(equalTo: lbs.bottomAnchor).isActive = true
        order.leftAnchor.constraint(equalTo: card.leftAnchor).isActive = true
        order.rightAnchor.constraint(equalTo: card.rightAnchor).isActive = true
        order.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        card.addSubview(status)
        
        status.topAnchor.constraint(equalTo: order.bottomAnchor).isActive = true
        status.leftAnchor.constraint(equalTo: card.leftAnchor).isActive = true
        status.rightAnchor.constraint(equalTo: card.rightAnchor).isActive = true
        status.heightAnchor.constraint(equalToConstant: 64).isActive = true
    }
    
    override func updateCellData() {
        guard let inventoryItem = cellData as? OnOrderItem else { return }
        
        name.text = inventoryItem._name
        
        let lbsFormatter = NumberFormatter()
        lbsFormatter.numberStyle = .decimal
        
        guard let formattedLbs = lbsFormatter.string(for: inventoryItem.quantity) else { return }
        
        lbs.text = "\(formattedLbs) lbs."
        
        guard let orderNumber = inventoryItem.orderNumber else { return }
        
        order.text = "Order #\(orderNumber)"
        
        guard let orderStatus = inventoryItem.status else { return }
        
        if orderStatus == "ordered" {
            status.text = "In Transit"
            
            status.font = UIFont(name: "AvenirNext-Medium", size: 16)
            status.textColor = UIColor(white: 0.25, alpha: 1.0)
            
            status.backgroundColor = .brandIce
        }
        
        if orderStatus == "delivered" {
            status.text = "Delivered"
            
            status.font = UIFont(name: "AvenirNext-Demibold", size: 16)
            status.textColor = UIColor(white: 1.0, alpha: 1.0)
            
            status.backgroundColor = .brandPurple
        }
    }
    
}
