//
//  BWCubicSplineInterpolation.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 26.01.17.
//  Copyright © 2017 Bellwether. All rights reserved.
//

import Foundation


extension BWCurve {
    func point(at x: BWReal) -> BWPoint {
        return BWPoint(x: x, y: f(x))
    }
}

// Curve S(x) = a + b(x - x0) + c/2(x - x0)^2 + d/6(x - x0)^3,      for x in [startX, endX]
struct BWConvenientCubicCurve: BWCurve {
    var x0: BWReal
    var coeficients: (a: BWReal, b: BWReal, c: BWReal, d: BWReal)
    
    // MARK: - SplineCurve
    
    func f(_ x: BWReal) -> BWReal {
        return coeficients.a +
            coeficients.b * (x - x0) +
            coeficients.c / 2.0 * pow(x - x0, 2) +
            coeficients.d / 6.0 * pow(x - x0, 3)
    }
}

struct BWCubicSpline: BWCurve {
    private(set) var points: [BWPoint]
    var curves: [BWCurve] {
        return splines
    }
    
    private var splines: [BWConvenientCubicCurve]
    
    init(points: [BWPoint]) {
        self.points = points
        self.splines = type(of: self).calculateCurves(points: points)
    }
    
    static func calculateCurves(points: [BWPoint]) -> [BWConvenientCubicCurve] {
        //guard points.count > 2 else {
            //fatalError("Cubic spline is defined for at least 3 points")
        //}
        
        let n = points.count
        let x = points.map { $0.x }
        let y = points.map { $0.y }
        
        var splines: [BWConvenientCubicCurve] = []
        for i in 0..<n {
            let spline = BWConvenientCubicCurve(x0: x[i], coeficients: (a: y[i], b: BWReal(0), c: BWReal(0), d: BWReal(0)))
            splines.append(spline)
        }
        splines[0].coeficients.c = BWReal(0)
        splines[n-1].coeficients.c = BWReal(0)
        
        // Resolve 3diagonal quation system with Thomas method
        var alpha = Array(repeating: BWReal(0), count: n-1)
        var beta  = Array(repeating: BWReal(0), count: n-1)
        for i in 1..<n-1 {
            let hi      = x[i] - x[i - 1]
            let hi1     = x[i + 1] - x[i]
            let A = hi
            let C = 2.0 * (hi + hi1)
            let B = hi1
            let F = 6.0 * ((y[i + 1] - y[i]) / hi1 - (y[i] - y[i - 1]) / hi)
            let z = (A * alpha[i - 1] + C)
            alpha[i] = -B / z
            beta[i] = (F - A * beta[i - 1]) / z
        }
        
        // Find solution:
        for i in (0...n-2).reversed() {
            splines[i].coeficients.c = alpha[i] * splines[i + 1].coeficients.c + beta[i]
        }
        
        for i in (1...n-1).reversed() {
            let hi = x[i] - x[i - 1]
            splines[i].coeficients.d = (splines[i].coeficients.c - splines[i - 1].coeficients.c) / hi
            splines[i].coeficients.b = hi * (2.0 * splines[i].coeficients.c + splines[i - 1].coeficients.c) / 6.0 + (y[i] - y[i - 1]) / hi
        }
        
        return splines
    }
    
    // MARK: - Curve
    
    func f(_ x: BWReal) -> BWReal {
        guard !splines.isEmpty else {
            fatalError()
        }
        
        let n = splines.count
        let spline: BWCurve
        
        if x <= splines[0].x0 {
            spline = splines[0]
        } else if x >= splines[n - 1].x0 {
            spline = splines[n - 1]
        } else {
            var i = 0
            var j = n - 1
            while i + 1 < j {
                let k = i + (j - i) / 2
                if x <= splines[k].x0 {
                    j = k
                } else {
                    i = k
                }
            }
            spline = splines[j]
        }
        
        return spline.f(x)
    }
}
