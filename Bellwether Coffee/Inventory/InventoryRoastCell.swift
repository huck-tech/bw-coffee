//
//  InventoryRoastCell.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class InventoryRoastCell: CollectionViewCell {
    
    var card: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .brandPurple
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var name: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = UIColor(white: 1.0, alpha: 1.0)
        label.textAlignment = .center
        label.backgroundColor = .brandPurple
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var roast: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = UIColor(white: 0.25, alpha: 1.0)
        label.textAlignment = .center
        label.backgroundColor = .brandIce
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var lbs: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Demibold", size: 16)
        label.textColor = UIColor(white: 0.25, alpha: 1.0)
        label.textAlignment = .center
        label.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
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
        
        card.addSubview(roast)
        
        roast.topAnchor.constraint(equalTo: name.bottomAnchor).isActive = true
        roast.leftAnchor.constraint(equalTo: card.leftAnchor).isActive = true
        roast.rightAnchor.constraint(equalTo: card.rightAnchor).isActive = true
        roast.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        card.addSubview(lbs)
        
        lbs.topAnchor.constraint(equalTo: roast.bottomAnchor).isActive = true
        lbs.leftAnchor.constraint(equalTo: card.leftAnchor).isActive = true
        lbs.rightAnchor.constraint(equalTo: card.rightAnchor).isActive = true
        lbs.heightAnchor.constraint(equalToConstant: 64).isActive = true
    }
    
    override func updateCellData() {
        guard let roastItem = cellData as? RoastItem else { return }
        
        name.text = roastItem._beanName
        roast.text = roastItem.roastName
        
        let lbsFormatter = NumberFormatter()
        lbsFormatter.numberStyle = .decimal
        let formattedLbs = lbsFormatter.string(for: roastItem.stockQuantity) ?? ""
        
        lbs.text = "\(formattedLbs) lbs."
    }
    
}
