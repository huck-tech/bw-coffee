//
//  DashboardStatisticCell.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/21/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

struct DashboardStatistic {
    let identifier: String?
    let name: String?
    let detail: String?
    let active: Bool
}

class DashboardStatisticCell: CollectionViewCell {
    
    var name: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Demibold", size: 16)
        label.textColor = .brandPurple
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var detail: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "AvenirNext-Medium", size: 16)
        label.textColor = BellwetherColor.roast
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func setupViews() {
        addSubview(detail)
        
        detail.topAnchor.constraint(equalTo: topAnchor).isActive = true
        detail.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        detail.widthAnchor.constraint(equalToConstant: 110).isActive = true
        detail.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addSubview(name)
        
        name.topAnchor.constraint(equalTo: topAnchor).isActive = true
        name.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        name.rightAnchor.constraint(equalTo: detail.leftAnchor, constant: -8).isActive = true
        name.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    override func updateCellData() {
        guard let dashboardStatistic = cellData as? DashboardStatistic else { return }
        
        name.text = dashboardStatistic.name
        detail.text = dashboardStatistic.detail
        
        //coloring is dependent on whether the cell is active (tappable) or not
        self.name.textColor = dashboardStatistic.active ? .brandPurple : BellwetherColor.roast
        
        let fontName = dashboardStatistic.active ? "AvenirNext-Demibold" : "AvenirNext-Medium"
        self.name.font = UIFont(name: fontName, size: 16)
    }
}
