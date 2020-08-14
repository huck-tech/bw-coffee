//
//  CheckoutBillingInfoCollectionCell.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/31/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

enum CheckoutBillingInfoCellAction: CollectionViewCellAction {
    case edit
}

class CheckoutBillingInfoCollectionCell: CollectionViewCell {
    
    var name: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 18)
        label.textColor = BellwetherColor.roast
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var company: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = BellwetherColor.roast
        label.alpha = 0.6
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var address: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = BellwetherColor.roast
        label.alpha = 0.6
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var phone: UILabel = {
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
        button.setTitle("EDIT", for: .normal)
        button.addTarget(self, action: #selector(selectEdit), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func setupViews() {
        addSubview(name)
        
        name.addAnchors(anchors: [.top: topAnchor], constant: 16)
        name.addAnchors(anchors: [.left: leftAnchor], constant: 24)
        name.addAnchors(anchors: [.right: rightAnchor], constant: -24)
        name.addAnchors(anchors: [.height: CGFloat(24)])
        
        addSubview(company)
        
        company.addAnchors(anchors: [.top: name.bottomAnchor], constant: 6)
        company.addAnchors(anchors: [.left: leftAnchor], constant: 24)
        company.addAnchors(anchors: [.right: rightAnchor], constant: -24)
        company.addAnchors(anchors: [.height: CGFloat(22)])
        
        addSubview(address)
        
        address.addAnchors(anchors: [.top: company.bottomAnchor], constant: 6)
        address.addAnchors(anchors: [.left: leftAnchor], constant: 24)
        address.addAnchors(anchors: [.right: rightAnchor], constant: -24)
        address.addAnchors(anchors: [.height: CGFloat(22)])
        
        addSubview(phone)
        
        phone.addAnchors(anchors: [.top: address.bottomAnchor], constant: 6)
        phone.addAnchors(anchors: [.left: leftAnchor], constant: 24)
        phone.addAnchors(anchors: [.right: rightAnchor], constant: -24)
        phone.addAnchors(anchors: [.height: CGFloat(22)])
        
        addSubview(edit)
        
        edit.addAnchors(anchors: [.right: rightAnchor], constant: -24)
        edit.addAnchors(anchors: [.centerY: centerYAnchor, .width: CGFloat(44), .height: CGFloat(44)])
    }
    
    override func updateCellData() {
        guard let billingInfo = cellData as? BillingInfo else { return }
        
        name.text = "\(billingInfo.firstName ?? "") \(billingInfo.lastName ?? "")"
        company.text = billingInfo.company
        address.text = billingInfo.address
        phone.text = billingInfo.phone
        
        backgroundColor = cellSelected ? UIColor(red: 0.956, green: 0.96, blue: 0.976, alpha: 1.0) : .white
    }
    
    @objc func selectEdit() {
        handle(action: CheckoutBillingInfoCellAction.edit.rawValue)
    }
    
}
