//
//  RectUtils.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/4/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit

extension CGRect {
    
    func updating(width: CGFloat) -> CGRect {
        var newFrame = self
        newFrame.size.width = width
        return newFrame
    }
    
    func updating(height: CGFloat) -> CGRect {
        var newFrame = self
        newFrame.size.height = height
        return newFrame
    }
    
}
