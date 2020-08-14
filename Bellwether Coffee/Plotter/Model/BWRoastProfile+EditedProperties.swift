//
//  BWRoastProfile+EditedProperties.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 30.11.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation


extension BWRoastProfile {
    // MARK: - Editable properties
    
    var duration: TimeInterval {
        get {
            return steps.last?.time ?? 0
        }
        set {
            setDuration(newValue)
        }
    }
    
    var min5Temperature: BWTemperature? {
        get {
            
            return getStep(with: 5 * 60)?.temperature
        }
        set {
            setTemperature(newValue, for: 5 * 60)
        }
    }
    
    var min8Temperature: BWTemperature? {
        get {
            
            return getStep(with: 8 * 60)?.temperature
        }
        set {
            setTemperature(newValue, for: 8 * 60)
        }
    }
    
    // MARK: - Utils
    
    func nearestLeftStepIndex(for time: TimeInterval) -> Int {
        var nearestStepIndex: Int = 0
        for i in 0..<steps.count {
            if time > steps[i].time {
                nearestStepIndex = i
            } else {
                break
            }
        }
        return nearestStepIndex
    }
    
    func nearestRightStepIndex(for time: TimeInterval) -> Int {
        var nearestStepIndex: Int = 0
        for i in (0..<steps.count).reversed() {
            if time < steps[i].time {
                nearestStepIndex = i
            } else {
                break
            }
        }
        return nearestStepIndex
    }
    
    func nearestStepIndex(for time: TimeInterval) -> Int {
        var nearestStepIndex: Int = 0
        var minDistance = Double.infinity
        for i in (0..<steps.count) {
            if fabs(time - steps[i].time) < minDistance {
                nearestStepIndex = i
                minDistance = time - steps[i].time
            }
        }
        return nearestStepIndex
    }
    
    // MARK: - Private utils
    
    private mutating func setTemperature(_ temperature: BWTemperature?, for time: TimeInterval) {
        // Find point with x = time if exists
        for i in 0..<steps.count {
            if steps[i].time == time {
                if let newTemperature = temperature {
                    steps[i].temperature = (newTemperature - 32.0) * 5/9
                } else {
                    steps.remove(at: i)
                }
                return
            }
        }
        
        // Insert point with x = time if not exists
        if var newTemperature = temperature {
            newTemperature = (newTemperature - 32.0) * 5/9
            
            let index = nearestLeftStepIndex(for: time)
            let newStep = BWRoastProfileStep(temperature: newTemperature, time: time)
            steps.insert(newStep, at: index + 1)
        }
    }
    
    private func getStep(with time: TimeInterval) -> BWRoastProfileStep? {
        return steps.filter { $0.time == time }.first
    }
    
    private mutating func setDuration(_ duration: TimeInterval) {
        if self.duration < duration {
            let lastStep = steps.last ?? BWRoastProfileStep(temperature: 100, time: 0)
            let newStep = BWRoastProfileStep(temperature: lastStep.temperature, time: duration)
            steps.insert(newStep, at: steps.endIndex)
        } else {
            // Assume point on existing graph (x0, y0) with x0 = duration
            // is surrounded by points (x1, y1) and (x2, y2) to the left and right appropriatelly.
            // We calculate y0, make (x0, y0) the last point of the graph, and truncate whatever is after.
            
            let nearestLeftIndex = nearestLeftStepIndex(for: duration)
            let nearestLeftStep = steps[nearestLeftIndex]
            let nearestRightStep = steps[nearestLeftIndex + 1]
            
            // Line equation: (x - x1) / (x1 - x2) = (y - y1) / (y1 - y2)
            // From where line function is y(x) = (x - x1) / (x1 - x2) * (y1 - y2) + y1
            let lineFunction = { (x: Double) -> Double in
                let x1 = nearestLeftStep.time
                let y1 = nearestLeftStep.temperature
                let x2 = nearestRightStep.time
                let y2 = nearestRightStep.temperature
                return (x - x1) / (x1 - x2) * (y1 - y2) + y1
            }
            
            // Calculate targetStep = (x0, y0) = y(x0):
            let targetStep = BWRoastProfileStep(temperature: lineFunction(duration),
                                                time: duration)
            
            // Replace right step with target one
            steps[nearestLeftIndex + 1] = targetStep
            
            // Remove whatever is after target one
            while steps.count > nearestLeftIndex + 2 {
                steps.remove(at: steps.endIndex - 1)
            }
        }
    }
}
