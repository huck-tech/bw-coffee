//
//  CardSize.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/12/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

class CardSize {
    
    var size: CGSize = CGSize(width: 100, height: 100) {
        didSet { updateSize() }
    }
    
    var widthConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    
    func updateSize() {
        widthConstraint?.constant = size.width
        heightConstraint?.constant = size.height
    }
    
}
