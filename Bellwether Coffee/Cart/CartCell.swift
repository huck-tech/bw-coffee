//
//  CartCell.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class CartCell: SwipeableCollectionViewCell {
    
    var coffee: UILabel = {
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
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var amount: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var total: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var separator: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func setupViews() {
        contentView.addSubview(total)
        
        let topAnchor = self.contentView.topAnchor
        let rightAnchor = self.contentView.rightAnchor
        let leftAnchor = self.contentView.leftAnchor
        let bottomAnchor = self.contentView.bottomAnchor
        
        
        total.topAnchor.constraint(equalTo: topAnchor).isActive = true
        total.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        total.widthAnchor.constraint(equalToConstant: 100).isActive = true
        total.heightAnchor.constraint(equalToConstant: 74).isActive = true
        
        contentView.addSubview(amount)
        
        amount.topAnchor.constraint(equalTo: topAnchor).isActive = true
        amount.rightAnchor.constraint(equalTo: total.leftAnchor).isActive = true
        amount.widthAnchor.constraint(equalToConstant: 100).isActive = true
        amount.heightAnchor.constraint(equalToConstant: 74).isActive = true
        
        contentView.addSubview(price)
        
        price.topAnchor.constraint(equalTo: topAnchor).isActive = true
        price.rightAnchor.constraint(equalTo: amount.leftAnchor).isActive = true
        price.widthAnchor.constraint(equalToConstant: 100).isActive = true
        price.heightAnchor.constraint(equalToConstant: 74).isActive = true
        
        contentView.addSubview(coffee)
        
        coffee.topAnchor.constraint(equalTo: topAnchor).isActive = true
        coffee.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        coffee.rightAnchor.constraint(equalTo: price.leftAnchor).isActive = true
        coffee.heightAnchor.constraint(equalToConstant: 74).isActive = true
        
        contentView.addSubview(separator)
        
        separator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    override func updateCellData() {
        guard let orderItem = cellData as? OrderItem else { return }
        
        coffee.text = orderItem.name
        price.text = "\(orderItem.price ?? 0.0)"
        amount.text = "\(orderItem.quantity ?? 0.0)"
        total.text = "\(orderItem.totalPrice ?? 0.0)"
        
        let lbsFormatter = NumberFormatter()
        lbsFormatter.numberStyle = .decimal
        lbsFormatter.minimumFractionDigits = 0
        lbsFormatter.maximumFractionDigits = 0
        amount.text = lbsFormatter.string(for: orderItem.quantity) ?? ""
        
        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency
        
        price.text = priceFormatter.string(for: orderItem.price) ?? ""
        
        guard let price = orderItem.price, let quantity = orderItem.quantity else { return }
        total.text = priceFormatter.string(for: price * quantity) ?? ""
    }
    
}
