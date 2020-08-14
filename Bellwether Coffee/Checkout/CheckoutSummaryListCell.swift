//
//  CheckoutSummaryListCell.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/19/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class CheckoutSummaryListCell: CollectionViewCell {
    
    var orderItem: OrderItem?
    
    var name: ComponentLabel = {
        let label = ComponentLabel(frame: .zero)
        label.formatFont = UIFont(name: "AvenirNext-Medium", size: 16)
        label.formatColor = BellwetherColor.roast
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var price: ComponentLabel = {
        let label = ComponentLabel(frame: .zero)
        label.formatFont = UIFont(name: "AvenirNext-Medium", size: 16)
        label.formatColor = BellwetherColor.roast
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func setupViews() {
        addSubview(name)
        
        name.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        name.leftAnchor.constraint(equalTo: leftAnchor, constant: 24).isActive = true
        
        addSubview(price)
        
        price.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        price.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
    }
    
    override func updateCellData() {
        guard let orderItem = cellData as? OrderItem else { return }
        
        name.formattedText = orderItem.name
        
        let orderPrice = orderItem.price ?? 0.0
        let orderQuantity = orderItem.quantity ?? 0.0
        
        let finalPrice = orderPrice * orderQuantity
        price.formattedText = finalPrice.formattedPrice()
        
        backgroundColor = cellIndex.isEven ? UIColor(red: 0.956, green: 0.96, blue: 0.976, alpha: 1.0) : .white
    }
    
}
