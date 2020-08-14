//
//  BeanDetailRoastProfileListCell.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 4/2/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class BeanDetailRoastProfileListCell: CollectionViewCell {
    
    var content: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var profileName: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var detailArrow: MarketListArrowView = {
        let view = MarketListArrowView(frame: .zero)
        view.isHidden = true
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
        
        content.addSubview(profileName)
        
        profileName.topAnchor.constraint(equalTo: content.topAnchor).isActive = true
        profileName.leftAnchor.constraint(equalTo: content.leftAnchor, constant: 14).isActive = true
        profileName.rightAnchor.constraint(equalTo: content.rightAnchor, constant: -14).isActive = true
        profileName.bottomAnchor.constraint(equalTo: content.bottomAnchor).isActive = true
        
        content.addSubview(detailArrow)
        
        detailArrow.topAnchor.constraint(equalTo: content.topAnchor).isActive = true
        detailArrow.leftAnchor.constraint(equalTo: content.rightAnchor).isActive = true
        detailArrow.widthAnchor.constraint(equalToConstant: 22).isActive = true
        detailArrow.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    override func updateCellData() {
        guard let roastProfile = cellData as? RoastProfile else { return }
        
        profileName.text = roastProfile.name
        
        profileName.textColor = cellSelected ? .white : BellwetherColor.roast
        content.backgroundColor = cellSelected ? .brandPurple : UIColor(white: 0.96, alpha: 1.0)
        
        detailArrow.isHidden = !cellSelected
    }
    
}
