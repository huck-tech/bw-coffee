//
//  CheckoutPaymentMethodCollectionCell.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/31/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

enum CheckoutPaymentMethodCellAction: CollectionViewCellAction {
    case delete
}

class CheckoutPaymentMethodCollectionCell: CollectionViewCell {
    
    var name: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 18)
        label.textColor = BellwetherColor.roast
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var desc: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = BellwetherColor.roast
        label.alpha = 0.6
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var edit: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 13)
        button.setTitleColor(BellwetherColor.roast, for: .normal)
        button.contentHorizontalAlignment = .right
        button.alpha = 0.3
        button.setTitle("DELETE", for: .normal)
        button.addTarget(self, action: #selector(selectDelete), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func setupViews() {
        addSubview(name)
        
        name.addAnchors(anchors: [.top: topAnchor], constant: 16)
        name.addAnchors(anchors: [.left: leftAnchor], constant: 24)
        name.addAnchors(anchors: [.right: rightAnchor], constant: -24)
        name.addAnchors(anchors: [.height: CGFloat(24)])
        
        addSubview(desc)
        
        desc.addAnchors(anchors: [.top: name.bottomAnchor], constant: 6)
        desc.addAnchors(anchors: [.left: leftAnchor], constant: 24)
        desc.addAnchors(anchors: [.right: rightAnchor], constant: -24)
        desc.addAnchors(anchors: [.height: CGFloat(22)])
        
        addSubview(edit)
        
        edit.addAnchors(anchors: [.right: rightAnchor], constant: -24)
        edit.addAnchors(anchors: [.centerY: centerYAnchor, .width: CGFloat(72), .height: CGFloat(44)])
    }
    
    override func updateCellData() {
        guard let billingInfo = cellData as? PaymentMethod else { return }
        
        name.text = billingInfo.type
        desc.text = billingInfo.description
        
        backgroundColor = cellSelected ? UIColor(red: 0.956, green: 0.96, blue: 0.976, alpha: 1.0) : .white
    }
    
    @objc func selectDelete() {
        handle(action: CheckoutPaymentMethodCellAction.delete.rawValue)
    }
    
}
