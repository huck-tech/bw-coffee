//
//  ComponentLabel.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 12/28/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit

enum ComponentLabelCase {
    case normal
    case uppercase
    case lowercase
}

class ComponentLabel: UILabel {
    
    var formattedText: String? {
        didSet { displayFormattedText() }
    }
    
    var formatFont: UIFont? = UIFont.systemFont(ofSize: 13)
    var formatColor: UIColor? = UIColor(white: 0.0, alpha: 1.0)
    var formatSpacing: CGFloat? = 0.0
    var formatLineSpacing: CGFloat? = nil
    var formatCase: ComponentLabelCase = .normal
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupViews()
    }
    
    func setupViews() {
        // override to setup view
    }
    
    func displayFormattedText() {
        guard let text = formattedText else { return }
        
        var textString = text
        
        if formatCase == .lowercase {
            textString = text.lowercased()
        }
        
        if formatCase == .uppercase {
            textString = text.uppercased()
        }
        
        let renderer = TextRenderer()
        renderer.font = formatFont
        renderer.color = formatColor
        renderer.spacing = formatSpacing
        renderer.lineSpacing = formatLineSpacing
        renderer.appendText(string: textString)
        attributedText = renderer.renderedText
    }
    
}
