//
//  MarketListCell.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 12/12/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit

class MarketListCell: CollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                content.backgroundColor = .brandPurple
                
                textColor = UIColor(white: 1.0, alpha: 1.0)
                detailArrow.alpha = 1.0
            } else {
                content.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
                
                textColor = UIColor(white: 0.3, alpha: 1.0)
                detailArrow.alpha = 0.0
            }
        }
    }
    
    var textColor: UIColor? {
        didSet {
            guard let color = textColor else { return }
            
            coffee.formatColor = color
            lbs.formatColor = color
            price.formatColor = color
            
            updateCellData()
        }
    }
    
    var content: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var coffee: ComponentLabel = {
        let label = ComponentLabel(frame: .zero)
        label.formatFont = UIFont(name: "AvenirNext-Regular", size: 16)
        label.formatColor = UIColor(white: 0.3, alpha: 1.0)
        label.textAlignment = .left
        label.formattedText = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var lbs: ComponentLabel = {
        let label = ComponentLabel(frame: .zero)
        label.formatFont = UIFont(name: "AvenirNext-Regular", size: 16)
        label.formatColor = UIColor(white: 0.3, alpha: 1.0)
        label.textAlignment = .center
        label.formattedText = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var price: ComponentLabel = {
        let label = ComponentLabel(frame: .zero)
        label.formatFont = UIFont(name: "AvenirNext-Regular", size: 16)
        label.formatColor = UIColor(white: 0.3, alpha: 1.0)
        label.formatSpacing = 1
        label.textAlignment = .center
        label.formattedText = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var detailArrow: MarketListArrowView = {
        let view = MarketListArrowView(frame: .zero)
        view.alpha = 0.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func setupViews() {
        setupAppearance()
        setupLayout()
    }
    
    func setupAppearance() {
        content.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
    }
    
    func setupLayout() {
        addSubview(content)
        
        content.topAnchor.constraint(equalTo: topAnchor).isActive = true
        content.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        content.rightAnchor.constraint(equalTo: rightAnchor, constant: -22).isActive = true
        content.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        content.addSubview(price)
        
        price.topAnchor.constraint(equalTo: content.topAnchor).isActive = true
        price.rightAnchor.constraint(equalTo: content.rightAnchor).isActive = true
        price.bottomAnchor.constraint(equalTo: content.bottomAnchor).isActive = true
        price.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        content.addSubview(lbs)
        
        lbs.topAnchor.constraint(equalTo: content.topAnchor).isActive = true
        lbs.rightAnchor.constraint(equalTo: price.leftAnchor).isActive = true
        lbs.bottomAnchor.constraint(equalTo: content.bottomAnchor).isActive = true
        lbs.widthAnchor.constraint(equalToConstant: 90).isActive = true
        
        content.addSubview(coffee)
        
        coffee.topAnchor.constraint(equalTo: content.topAnchor).isActive = true
        coffee.leftAnchor.constraint(equalTo: content.leftAnchor, constant: 14).isActive = true
        coffee.rightAnchor.constraint(equalTo: lbs.leftAnchor).isActive = true
        coffee.bottomAnchor.constraint(equalTo: content.bottomAnchor).isActive = true
        
        content.addSubview(detailArrow)
        
        detailArrow.topAnchor.constraint(equalTo: content.topAnchor).isActive = true
        detailArrow.leftAnchor.constraint(equalTo: content.rightAnchor).isActive = true
        detailArrow.widthAnchor.constraint(equalToConstant: 22).isActive = true
        detailArrow.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    override func updateCellData() {
        guard let marketBean = cellData as? Bean else { return }
        
        coffee.formattedText = marketBean._name
        
        let lbsFormatter = NumberFormatter()
        lbsFormatter.numberStyle = .decimal
        lbsFormatter.minimumFractionDigits = 0
        lbsFormatter.maximumFractionDigits = 0
        lbs.formattedText = lbsFormatter.string(for: marketBean.amount)
        
        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency
        price.formattedText = priceFormatter.string(for: marketBean.price)
    }
    
}
