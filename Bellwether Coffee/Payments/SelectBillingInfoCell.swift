//
//  SelectBillingInfoCell.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/6/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class SelectBillingInfoCell: CollectionViewCell {
    
    var separator: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(white: 0.94, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var cardType: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 15)
        label.textColor = UIColor(white: 0.08, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var cardNumber: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 15)
        label.textColor = UIColor(white: 0.08, alpha: 1.0)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cardPadding: CGFloat = 4
    
    override func setupViews() {
        addSubview(separator)
        
        separator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        addSubview(cardType)
        
        cardType.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        cardType.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        
        addSubview(cardNumber)
        
        cardNumber.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        cardNumber.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    override func updateCellData() {
        guard let billingInfo = cellData as? BillingInfo else { return }
        
        cardType.text = billingInfo.address
        cardNumber.text = "\(billingInfo.firstName ?? "") \(billingInfo.lastName ?? "")"
        
        let color = cellSelected ?  .brandPurple : UIColor(white: 0.08, alpha: 1.0)
        
        cardType.textColor = color
        cardNumber.textColor = color
    }
    
}
