//
//  InventoryGreenCell.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 2/9/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class InventoryGreenCell: CollectionViewCell {
    
    var actionDelegate: ActionDelegate?
    
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
    
    var lbs: UIButton = {
        let button = UIButton(frame: .zero)
        let label = button.titleLabel
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Demibold", size: 16)
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var flag: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(named: "inventory_flag")
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var cardWidth: NSLayoutConstraint?
    
    override func setupViews() {
        setupAppearance()
        setupLayout()
        setupAction()
    }
    
    func setupAppearance() {
        backgroundColor = .clear
    }
    
    /*  We need to intercept the touch event and funnel it to the lbs button with this crazy piece of code
     */
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let views = contentView.subviews[0].subviews
        for i in (0..<views.count-1).reversed() {
            let newPoint = views[i].convert(point, from: self)
            if let view = views[i].hitTest(newPoint, with: event) {
                return view
            }
        }
        return super.hitTest(point, with: event)
    }
    
    func setupAction(){
        self.lbs.addTarget(self, action: #selector(updateQuantity(_:)), for: .touchUpInside)
    }
    
    @objc func updateQuantity(_ sender:UIButton){
        self.actionDelegate?.actionOn(target: self)
    }
    
    func setupLayout() {
        contentView.addSubview(card)
        
        card.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        card.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        
        cardWidth = card.widthAnchor.constraint(equalToConstant: 225)
        cardWidth?.isActive = true
        
        card.addSubview(name)
        
        name.topAnchor.constraint(equalTo: card.topAnchor).isActive = true
        name.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 20).isActive = true
        name.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -20).isActive = true
        name.heightAnchor.constraint(equalToConstant: 74).isActive = true
        
        card.addSubview(lbs)
        
        lbs.topAnchor.constraint(equalTo: name.bottomAnchor).isActive = true
        lbs.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 20).isActive = true
        lbs.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -20).isActive = true
        lbs.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        card.addSubview(flag)
        
        flag.topAnchor.constraint(equalTo: lbs.topAnchor, constant: 16).isActive = true
        flag.leftAnchor.constraint(equalTo: lbs.leftAnchor, constant: 18).isActive = true
        flag.widthAnchor.constraint(equalToConstant: 15).isActive = true
        flag.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    override func updateCellData() {
        guard let inventoryItem = cellData as? GreenItem else { return }
        
        name.text = inventoryItem._name
        
        lbs.setTitle("\(inventoryItem.quantity?.formattedLbs(fractionDigits: 1) ?? "?") lbs.", for: .normal)
    }
}

extension InventoryGreenCell: Target {
    func action(delegate: ActionDelegate?){
        self.actionDelegate = delegate
    }
}

protocol ActionDelegate {
    func actionOn(target: AnyObject)
}

protocol Target {
    func action(delegate: ActionDelegate?)
}
