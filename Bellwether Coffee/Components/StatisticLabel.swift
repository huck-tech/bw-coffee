//
//  StatisticLabel.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/6/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class StatisticLabel: UILabel {
    
    var statisticText: String? {
        didSet { updateStatistic() }
    }
    
    var valueText: String? {
        didSet { updateStatistic() }
    }
    
    var action: (() -> Void)? {
        didSet { isUserInteractionEnabled = true }
    }
    
    var statisticColor: UIColor = BellwetherColor.roast
    var valueColor: UIColor = BellwetherColor.roast
    
    func updateStatistic() {
        guard let statistic = statisticText, let value = valueText else { return }
        
        let statisticFont = UIFont(name: "AvenirNext-Medium", size: 16)
        let valueFont = UIFont(name: "AvenirNext-Regular", size: 16)
        
        let renderer = TextRenderer()
        
        renderer.appendText(string: "\(statistic): ", separateFont: statisticFont, separateColor: statisticColor)
        renderer.appendText(string: value, separateFont: valueFont, separateColor: valueColor)
        
        attributedText = renderer.renderedText
    }
    
}

// MARK: Actions

extension StatisticLabel {
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        action?()
    }
    
}
