//
//  BWRoastProfile+Validation.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 08.02.17.
//  Copyright © 2017 Bellwether. All rights reserved.
//

import Foundation


extension BWRoastProfile {

    var hasOutOfRangeValues: Bool {
        if duration > TimeInterval.bw_maxRoastProfileDuration {
            return true
        }
        for step in steps {
            if step.time < 0 || step.time > duration {
                return true
            }
            if step.temperature < BWTemperature.bw_minRoastTemperature ||
                step.temperature > BWTemperature.bw_maxRoastTemperature {
                return true
            }
        }
        return false
    }
    
    mutating func trimOutOfRangeValues() {
        var index = 0
        while index < steps.count {
            var step = steps[index]
            
            if step.temperature < BWTemperature.bw_minRoastTemperature {
                step.temperature = BWTemperature.bw_minRoastTemperature
                steps[index] = step
            }
            
            if step.temperature > BWTemperature.bw_maxRoastTemperature {
                step.temperature = BWTemperature.bw_maxRoastTemperature
                steps[index] = step
            }
            
            if step.time < 0 {
                steps.remove(at: index)
            } else if step.time > TimeInterval.bw_maxRoastProfileDuration {
                steps.remove(at: index)
            } else {
                index += 1
            }
        }
    }

}
