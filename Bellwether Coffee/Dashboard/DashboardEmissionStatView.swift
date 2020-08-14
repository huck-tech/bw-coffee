//
//  DashboardEmissionStatView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/22/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class DashboardEmissionStatView: View {
    
    var statistic: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 40)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var name: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 14)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func setupViews() {
        addSubview(statistic)
        
        statistic.topAnchor.constraint(equalTo: topAnchor).isActive = true
        statistic.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        statistic.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        addSubview(name)
        
        name.topAnchor.constraint(equalTo: statistic.bottomAnchor, constant: 14).isActive = true
        name.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        name.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
}
