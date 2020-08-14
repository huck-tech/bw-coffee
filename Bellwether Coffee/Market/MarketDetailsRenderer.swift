//
//  MarketDetailsRenderer.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 2/8/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class MarketDetailsRenderer {
    
    var renderer: TextRenderer = {
        let textRenderer = TextRenderer()
        textRenderer.font = UIFont(name: "AvenirNext-Regular", size: 16)
        textRenderer.color = UIColor(white: 0.2, alpha: 1.0)
        textRenderer.lineSpacing = 4
        return textRenderer
    }()
    
    var renderedDetails: NSAttributedString {
        get { return renderer.renderedText }
    }
    
    func addDetail(name: String?, content: String?) {
        if let detailName = name {
            renderer.appendText(string: "\(detailName): ", separateFont: UIFont(name: "AvenirNext-Medium", size: 16))
        }
        
        if let detailContent = content {
            renderer.appendText(string: "\(detailContent)\n")
        }
        
        renderer.appendText(string: "\n", separateFont: UIFont(name: "AvenirNext-Medium", size: 4))
    }
    
}
