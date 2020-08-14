//
//  MarketListArrowView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/25/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class MarketListArrowView: ComponentView {
    
    override func setupViews() {
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY / 2))
        context.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.closePath()
        
        context.setFillColor(UIColor.brandPurple.cgColor)
        context.fillPath()
    }
    
}
