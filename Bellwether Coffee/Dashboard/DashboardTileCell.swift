//
//  DashboardTileCell.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class DashboardTileCell: ComponentCell {
    
    var instrument: DashboardInstrument? {
        didSet { updateCell() }
    }
    
    var card: DashboardCardView = {
        let dashboardCard = DashboardCardView(frame: .zero)
        dashboardCard.translatesAutoresizingMaskIntoConstraints = false
        return dashboardCard
    }()
    
    var cardWidth: NSLayoutConstraint?
    
    override func setupViews() {
        setupAppearance()
        setupLayout()
    }
    
    func updateCell() {
        guard let dashboardInstrument = instrument else { return }
        
        card.componentName.formattedText = dashboardInstrument.name
        card.highlightInfo.formattedText = dashboardInstrument.highlight
        card.descriptionInfo.formattedText = dashboardInstrument.description
        card.additionalInfo.formattedText = dashboardInstrument.info
    }
    
}

// MARK: Layout

extension DashboardTileCell {
    
    func setupAppearance() {
        backgroundColor = UIColor(white: 1.0, alpha: 0.0)
    }
    
    func setupLayout() {
        addSubview(card)
        
        card.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        card.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        cardWidth = card.widthAnchor.constraint(equalToConstant: 320)
        cardWidth?.isActive = true
    }
    
    override func layoutSubviews() {
        
        if bounds.width > 520 {
            cardWidth?.constant = 460
        } else if bounds.width > 480 {
            cardWidth?.constant = 380
        } else if bounds.width > 340 {
            cardWidth?.constant = 320
        } else {
            cardWidth?.constant = 280
        }
    }
    
}
