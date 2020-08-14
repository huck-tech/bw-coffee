//
//  BWRoastProfile+CurvedApproximation.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 03.02.17.
//  Copyright © 2017 Bellwether. All rights reserved.
//

import Foundation


extension BWRoastProfile {
    
    func calcIntervals(count: Int) -> (Int, Int, Int) {
        
        //round up to find the interval length
        var interval: Int = (duration/Double(count)).rounded(.up).asInt
        let core = Int(duration) / interval //@fixme - fatal if this is zero

        let remainder = Int(duration) - interval * core
        return (interval, core, remainder)
    }
    
    func evenIntervals(count:Int = 98) -> BWRoastProfile {
        var roastProfile = self
        let (interval, core, remainder) = calcIntervals (count: count)
        
        var evenSteps: [BWRoastProfileStep] = []
        for i in 0...core {
            let time = TimeInterval(i) * TimeInterval(interval)
            evenSteps.append(BWRoastProfileStep(temperature: temp(at: time)!, time: time))
        }
        
        if remainder != 0 {
            evenSteps.append(BWRoastProfileStep(temperature: temp(at: self.duration)!, time: self.duration))
        }
        
        roastProfile.steps = evenSteps
        return roastProfile
    }
    
    func temp(at current: TimeInterval) -> BWTemperature? {
        
        var result: BWTemperature?
        
        steps.enumerated().forEach{index, step in
            guard result == nil else {return}
            if step.time >= current {
                if index == 0 {
                    //we just started, so we have to go with the first time we see
                    result = steps[0].temperature
                } else {
                    //let target = m * time + k
                    let deltaY = steps[index].temp - steps[index - 1].temp
                    let deltaX = steps[index].time - steps[index - 1].time
                    let m = deltaY/deltaX
                    let k =  steps[index].temp - m * steps[index].time
                    result = m * current + k
                }
            }
        }
        
        return result
    }
    
    // Uses roast profile steps as keypoint, builds approximation curve,
    // splits curve onto linear steps to build new roast profile
    func curvedRoastProfile(maxNumberOfSteps: Int = 100) -> BWRoastProfile {
        var roastProfile = self
        
        let points = roastProfile.steps.map { BWPoint(x: $0.time, y: $0.temperature) }
        let spline = BWCubicSpline(points: points)
        
        var resultSteps: [BWRoastProfileStep] = []
        var currentKeyPointIndex = 0
        var currentKeyPoint = roastProfile.steps[currentKeyPointIndex]
        var time = currentKeyPoint.time
        let step = roastProfile.duration / Double(maxNumberOfSteps)
        
        while time <= roastProfile.duration, currentKeyPointIndex < roastProfile.steps.count {
            currentKeyPoint = roastProfile.steps[currentKeyPointIndex]
            
            let point: BWRoastProfileStep
            if time <= currentKeyPoint.time && currentKeyPoint.time < time + step {
                point = BWRoastProfileStep(temperature: currentKeyPoint.temperature,
                                           time: currentKeyPoint.time)
                
                currentKeyPointIndex += 1
            } else {
                point = BWRoastProfileStep(temperature: spline.f(time), time: time)
            }
            
            time += step
            
            resultSteps.append(point)
        }
        
        roastProfile.steps = resultSteps
        return roastProfile
    }
    
    
    func normalizedRoastProfile() -> BWRoastProfile {
        var roastProfile = self
        
        var normalizedSteps: [BWRoastProfileStep] = []
        for i in 0..<(steps.count - 1) {
            let currentStep = steps[i]
            let nextStep = steps[i + 1]
            let normalizedStep = BWRoastProfileStep(temperature: currentStep.temperature,
                                                    time: nextStep.time - currentStep.time)
            normalizedSteps.append(normalizedStep)
        }
        
        if let lastStep = steps.last {
            normalizedSteps.append(BWRoastProfileStep(temperature: lastStep.temperature, time: 0))
        }
        
        roastProfile.steps = normalizedSteps
        return roastProfile
    }
    
    func replaceSteps(steps: [BWRoastProfileStep])  -> BWRoastProfile  {
        var roastProfile = self
        roastProfile.steps = steps
        return roastProfile
    }
}
