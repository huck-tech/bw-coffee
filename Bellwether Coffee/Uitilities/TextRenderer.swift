//
//  TextRenderer.swift
//  Bellwether Coffee
//
//  Created by Gabe The Coder on 12/11/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit

class TextRenderer {
    
    var renderedText = NSMutableAttributedString()
    
    var font: UIFont? = nil
    var color: UIColor? = nil
    var spacing: CGFloat? = nil
    var lineSpacing: CGFloat? = nil
    
    func appendText(string: String, separateFont: UIFont? = nil, separateColor: UIColor? = nil) {
        var attributes = [NSAttributedStringKey: Any]()
        
        if let textFont = separateFont ?? font {
            attributes[.font] = textFont
        }
        
        if let textColor = separateColor ?? color {
            attributes[.foregroundColor] = textColor
        }
        
        if let textSpacing = spacing {
            attributes[.kern] = textSpacing
        }
        
        if let textLineSpacing = lineSpacing {
            attributes[.paragraphStyle] = paragraphStyle(lineSpacing: textLineSpacing)
        }
        
        let attributedText = NSAttributedString(string: string, attributes: attributes)
        renderedText.append(attributedText)
    }
    
}

// MARK: Helpers

extension TextRenderer {
    
    func paragraphStyle(lineSpacing: CGFloat) -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        return paragraphStyle
    }
    
}
