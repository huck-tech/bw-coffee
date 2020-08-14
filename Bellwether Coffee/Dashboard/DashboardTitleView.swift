//
//  DashboardTitleView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/24/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class DashboardTitleView: View {
    
    var text: String? {
        didSet { title.text = text }
    }
    
    var title: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var separator: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .brandPurple
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func setupViews() {
        addSubview(title)
        
        title.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        title.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        title.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        title.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        addSubview(separator)
        
        separator.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8).isActive = true
        separator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        separator.widthAnchor.constraint(equalToConstant: 80).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
}
