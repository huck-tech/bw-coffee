//
//  CheckoutProcessAddNewFooterView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/27/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class CheckoutProcessAddNewFooterView: View {
    
    var addNew: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = BellwetherColor.roast
        label.alpha = 0.6
        label.text = "Add New"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var button: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(selectNew), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var separator: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(white: 0.93, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var action: (() -> Void)?
    
    override func setupViews() {
        addSubview(addNew)
        
        addNew.addAnchors(anchors: [.top: topAnchor, .bottom: bottomAnchor])
        addNew.addAnchors(anchors: [.left: leftAnchor], constant: 24)
        addNew.addAnchors(anchors: [.right: rightAnchor], constant: -24)
        
        addSubview(button)
        button.anchorIn(view: self)
        
//        addSubview(separator)
//        
//        separator.addAnchors(anchors: [
//            .bottom: bottomAnchor,
//            .left: leftAnchor,
//            .right: rightAnchor,
//            .height: CGFloat(1)
//        ])
        
        addAnchors(anchors: [.height: CGFloat(60)])
    }
    
    @objc func selectNew() {
        action?()
    }
    
}
