//
//  BWRoastLogGraphDataSource.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 02.11.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import UIKit
import CorePlot


class BWRoastLogGraphDataSource: NSObject, CPTPlotDataSource {
    
    // MARK: - BWRoastLogGraphDataSource
    
    var measurements: [BWRoastLogMeasurement]
    
    init(measurements: [BWRoastLogMeasurement]) {
        self.measurements = measurements
    }
    
    // MARK: - CPTPlotDataSource
    
    public func numberOfRecords(for plot: CPTPlot) -> UInt {
        return UInt(measurements.count)
    }
    
    public func double(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Double {
        guard let field = CPTScatterPlotField(rawValue: Int(fieldEnum)) else {
            return Double.nan
        }
        
        let measurement = measurements[Int(idx)]
        
        switch field {
        case .X:
            return measurement.time
        case .Y:
            return temp(at: Int(idx))
        }
    }
    
    func temp(at index:Int) -> BWTemperature {
        return measurements[index].temperature
    }

}

class BWRoastSkinGraphDataSource: BWRoastLogGraphDataSource {
    override func temp(at index:Int) -> BWTemperature {
        return measurements[index].skinTemp
    }
}

class BWRoastRiseRateGraphDataSource: BWRoastLogGraphDataSource {
    override func temp(at index:Int) -> BWTemperature {
        //we blend the results over a range to smooth out the curve
        let window = 3
        
        let range: [Int] = Array((index - window)...(index + window))
        let values = range.map {_temp(at: $0)} .filter {$0 != Double.nan}
        
        return values.reduce(0.0,+) / values.count.asDouble
        
    }
    
    private func _temp(at index:Int) -> BWTemperature {
        let range: Int = 15
        guard index >= range && index < measurements.count else {return Double.nan}
        
       //obtain the range we care about
        let trail = measurements[(index - range)...index]
        guard let lastTemp = trail.last?.temperature, let firstTemp = trail.first?.temperature else {return Double.nan}
        guard let lastTime = trail.last?.time, let firstTime = trail.first?.time else {return Double.nan}
        
//        print("i:\(index)\ttemp: \(firstTemp) -> \(lastTemp)\t time:\(firstTime) -> \(lastTime)")

        let deltaTemp = lastTemp - firstTemp
        let deltaTime = lastTime - firstTime
        
        if deltaTime == 0 {return Double.nan}
        
        //express in terms of 30 seconds
        let result =  30.0 * deltaTemp / deltaTime
    
//        print("i:\(index)\t\(result)\t\(deltaTemp)\t\(firstTemp)")

//        print("i:\(index)\ttemp: \(firstTemp) -> \(lastTemp)\t time:\(firstTime) -> \(lastTime)"+"\t\(result)\t\(range.asDouble)\t\(deltaTemp)\t\(deltaTime)")
        return result
    }
    
}

extension Array where Element == BWRoastLogMeasurement {
    var rateOfRise: Double? {return nil}
}
