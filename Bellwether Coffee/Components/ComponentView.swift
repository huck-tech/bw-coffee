//
//  CustomView.swift
//  Bellwether Coffee
//
//  Created by Gabe The Coder on 12/11/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit

class ComponentView: UIView {
    
    var height: CGFloat {
        get { return calculateHeight() }
    }
    
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
    
}

// MARK: Utilities

extension ComponentView {
    
    func calculateHeight() -> CGFloat {
        var height = CGFloat()
        
        subviews.forEach { view in
            let viewHeight = view.bounds.height
            
            if height < viewHeight {
                height = viewHeight
            }
        }
        
        return height
    }
    
}
