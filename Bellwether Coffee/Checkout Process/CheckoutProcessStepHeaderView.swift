//
//  CheckoutProcessStepHeaderView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/12/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class CheckoutProcessStepHeaderView: View {
    
    static let headerHeight: CGFloat = 60
    
    var title: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 19)
        label.textColor = BellwetherColor.roast
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func setupViews() {
        addSubview(title)
        
        title.addAnchors(anchors: [.top: topAnchor], constant: 20)
        title.addAnchors(anchors: [.left: leftAnchor, .right: rightAnchor], insetConstant: 24)
        
        addSubview(actionButton)
        
        actionButton.anchorIn(view: self)
        
        heightAnchor.constraint(equalToConstant: CheckoutProcessStepHeaderView.headerHeight).isActive = true
    }
    
}
