//
//  BWLinearSplineInterpolation.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 03.02.17.
//  Copyright © 2017 Bellwether. All rights reserved.
//

import Foundation


struct BWLinearSpline: BWCurve {
    
    private(set) var points: [BWPoint]
    
    init(points: [BWPoint]) {
        guard points.count >= 2 else {
            fatalError()
        }
        
        self.points = points
    }
    
    // MARK: - BWCurve 
    
    func f(_ x: BWReal) -> BWReal {
        // 
        guard x >= points[0].x, x <= points[points.count - 1].x else {
            return 0
        }
        // Find left and right points
        var leftPoint = points[0]
        var rightPoint = points[1]
        for i in 0..<points.count-1 {
            if points[i].x <= x && x <= points[i + 1].x {
                leftPoint = points[i]
                rightPoint = points[i + 1]
            }
        }
        
        // from line equation: 
        return (leftPoint.y - rightPoint.y) * (x - leftPoint.x) / (leftPoint.x - rightPoint.x) + leftPoint.y
    }
    
}
