//
//  CGGeometry.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 05.10.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import CoreGraphics


extension CGPoint {
    
    func distance(to otherPoint: CGPoint) -> CGFloat {
        return hypot(otherPoint.x - self.x, otherPoint.y - self.y)
    }
    
}
