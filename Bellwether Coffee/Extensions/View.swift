//
//  View.swift
//  BellwetherCoffee
//
//  Created by Gabriel Pierannunzi on 1/21/18.
//  Copyright © 2018 Gabriel Pierannunzi. All rights reserved.
//

import UIKit

class View: UIView {
    
    var layoutConstraints = [LayoutAnchor: NSLayoutConstraint]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupViews()
    }
    
    func setupViews() {
        // override to customize view
    }
    
}
