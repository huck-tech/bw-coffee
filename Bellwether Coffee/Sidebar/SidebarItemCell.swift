//
//  SidebarItemCell.swift
//  Bellwether Coffee
//
//  Created by Gabe The Coder on 12/11/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit

class SidebarItemCell: ComponentCell {
    
    var item: SidebarItem? {
        didSet {
            guard let cellItem = item else { return }
            titleText = cellItem.name
        }
    }
    
    var titleText: String! {
        didSet {
            let renderer = TextRenderer()
            renderer.font = UIFont(name: "OpenSans-Semibold", size: 15)
            renderer.color = UIColor(white: 1.0 , alpha: 1.0)
            renderer.spacing = 3
            renderer.appendText(string: titleText.uppercased())
            title.attributedText = renderer.renderedText
        }
    }
    
    var title: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "OpenSans-Regular", size: 17)
        label.textColor = UIColor(white: 1.0, alpha: 1.0)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func setupViews() {
        addSubview(title)
        
        title.topAnchor.constraint(equalTo: topAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 28).isActive = true
        title.rightAnchor.constraint(equalTo: rightAnchor, constant: -28).isActive = true
        title.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
}

