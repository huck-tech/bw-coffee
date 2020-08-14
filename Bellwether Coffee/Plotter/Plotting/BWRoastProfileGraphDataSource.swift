//
//  BWRoastProfileGraphDataSource.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 18.10.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation
import CorePlot


typealias BWRoastProfileGraphPoint = (x: Double, y: Double)


protocol BWRoastProfileEditingDelegate: class {
    func roastProfileChanged(roastProfile: BWRoastProfile)
}


class BWRoastProfileGraphDataSource: NSObject, CPTScatterPlotDataSource {
    
    // MARK: - BWRoastProfileGraphDataSource
    private var roastProfile: BWRoastProfile {
        didSet {
            self.spline = type(of: self).buildSpline(for: roastProfile, of: splineType)
        }
    }
    
    enum SplineType {
        case linear
        case cubic
    }
    
    var splineType: SplineType = .linear
    
    var showsKeyPoints: Bool = true
    
    var isEditable: Bool
    
    weak var editingDelegate: BWRoastProfileEditingDelegate?
    
    func buildRoastProfile() -> BWRoastProfile {
        var profile = self.roastProfile
        for var thestep in profile.steps{
            thestep.temperature = (thestep.temperature - 32) * 5/9
        }
        
        //the last step is always there because curves always start with points.
        profile.preheat = BWRoastProfilePreheat(type: .Manual, temperature: profile.steps.first!.temperature)
        return profile
    }
    
    var selectedStep: BWRoastProfileStep? {
        if let index = selectedStepIndex {
            let point = graphPoints[Int(index)]
            if case let .keyPoint(step, _) = point.type {
                return step
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    var selectedStepIndex: UInt? = nil
    
    var draggedStepIndex: UInt? = nil
    
    var deletedStepIndex: UInt? = nil
    
    init(roastProfile: BWRoastProfile,
         isEditable: Bool = false,
         splineType: SplineType = .linear,
         showsKeyPoints: Bool = true) {
        self.roastProfile = roastProfile
        self.graphPoints = []
        self.splineType = splineType
        self.spline = type(of: self).buildSpline(for: roastProfile, of: splineType)
        self.isEditable = isEditable
        self.showsKeyPoints = showsKeyPoints
        super.init()
        self.graphPoints = buildGraphPoints(for: roastProfile)
    }
    
    var lastStepIndex: UInt {
        return UInt(graphPoints.count - 1)
    }
    
    var lastStep: BWRoastProfileStep? {
        if case let .keyPoint(step, _) = graphPoints[Int(lastStepIndex)].type {
            return step
        } else {
            return nil
        }
    }
    
    func step(at index: UInt?) -> BWRoastProfileStep? {
        guard let index = index else {return nil}
        let point = graphPoints[Int(index)]
        if case let .keyPoint(step, _) = point.type {
            return step
        } else {
            return nil
        }
    }
    
    func step(before index: UInt?) -> BWRoastProfileStep? {
        guard let index = index else {return nil}
        for i in (0..<Int(index)).reversed() {
            if case let .keyPoint(previousStep, _) = graphPoints[i].type {
                return previousStep
            }
        }
        return nil
    }
    
    func step(after index: UInt?) -> BWRoastProfileStep? {
        guard let index = index else {return nil}

        for i in Int(index + 1)..<graphPoints.count {
            if case let .keyPoint(nextStep, _) = graphPoints[i].type {
                return nextStep
            }
        }
        return nil
    }
    
    func nearestLeftStepIndex(for time: TimeInterval) -> UInt {
        let roastProfileIndex = roastProfile.nearestLeftStepIndex(for: time)
        return UInt(pointIndex(for: roastProfileIndex))
    }
    
    func nearestRightStepIndex(for time: TimeInterval) -> UInt {
        let roastProfileIndex = roastProfile.nearestRightStepIndex(for: time)
        return UInt(pointIndex(for: roastProfileIndex))
    }
    
    func nearestStepIndex(for time: TimeInterval) -> UInt {
        let roastProfileIndex = roastProfile.nearestStepIndex(for: time)
        return UInt(pointIndex(for: roastProfileIndex))
    }
    
    public func pointIndex(for roastProfileIndex: Int) -> Int {
        for i in 0..<graphPoints.count {
            if case let .keyPoint(_, index) = graphPoints[i].type, index == roastProfileIndex {
                return i
            }
        }
        fatalError()
    }
    
    // MARK: - Editing
    
    func insert(_ step: BWRoastProfileStep, at index: UInt) {
        guard isEditable else {
            return
        }
        
        if case let .keyPoint(_, originalStepIndex) = graphPoints[Int(index)].type {
            roastProfile.steps.insert(step, at: originalStepIndex)
            editingDelegate?.roastProfileChanged(roastProfile: roastProfile)
        }
    }
    
    func replaceStep(at index: UInt, with step: BWRoastProfileStep) -> UInt {
        guard isEditable else {
            return 0
        }
        
        if case let .keyPoint(_, originalStepIndex) = graphPoints[Int(index)].type {
            roastProfile.steps[originalStepIndex] = step
            editingDelegate?.roastProfileChanged(roastProfile: roastProfile)
            let new_index = self.pointIndex(for: originalStepIndex)
            print("step at:\(index) moved to:\(new_index)")
            return UInt(new_index)
        }
        
        return 0
    }
    
    func remove(at index: UInt) {
        guard isEditable else {
            return
        }
        
        if case let .keyPoint(_, originalStepIndex) = graphPoints[Int(index)].type {
            roastProfile.steps.remove(at: originalStepIndex)
            editingDelegate?.roastProfileChanged(roastProfile: roastProfile)
        }
    }
    
    
    
    // MARK: - CPTPlotDataSource
    
    public func numberOfRecords(for plot: CPTPlot) -> UInt {
        return UInt(graphPoints.count)
    }
    
    public func double(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Double {
        guard let field = CPTScatterPlotField(rawValue: Int(fieldEnum)) else {
            return Double.nan
        }
        
        var point = graphPoints[Int(idx)]
        point.y = point.y * 9/5 + 32
        switch field {
        case .X:
            return point.x
        case .Y:
            return point.y
        }
    }
    
    // MARK: - CPTScatterPlotDataSource
    
    public func symbol(for plot: CPTScatterPlot, record idx: UInt) -> CPTPlotSymbol? {
        guard showsKeyPoints else {
            return nil
        }
        
        let point = graphPoints[Int(idx)]
        if case .linePoint = point.type {
            return nil
        }
        
        if isEditable, let selectedStepIndex = selectedStepIndex, idx == selectedStepIndex {
            return BWRoastProfileGraphViewController.selectedPlotSymbol
        } else {
            return BWRoastProfileGraphViewController.plotSymbol
        }
    }
    
    // MARK: - Curve
    
    private var spline: BWCurve {
        didSet {
            graphPoints = buildGraphPoints(for: roastProfile)
        }
    }
    
    class func buildSpline(for roastProfile: BWRoastProfile, of type: SplineType) -> BWCurve {
        let points = roastProfile.steps.map { BWPoint(x: $0.time, y: $0.temperature) }
        
        switch type {
        case .linear:
            return BWLinearSpline(points: points)
        case .cubic:
            return BWCubicSpline(points: points)
        }
    }
    
    enum GraphPointType {
        case keyPoint(step: BWRoastProfileStep, roastProfileIndex: Int)
        case linePoint
    }
    
    struct GraphPoint {
        var x: BWReal
        var y: BWReal
        var type: GraphPointType
    }
    
    private var graphPoints: [GraphPoint]
    
    private let maxNumberOfSteps = 100
    
    func buildGraphPoints(for roastProfile: BWRoastProfile) -> [GraphPoint] {
        guard roastProfile.steps.count >= 2 else {
            fatalError()
        }
        
        // Preserve selected point indexes on graph points rebuild
        var originalSelectedIndex: Int? = nil
        if let selectedStepIndex = selectedStepIndex {
            if case let .keyPoint(_, originalIndex) = graphPoints[Int(selectedStepIndex)].type {
                originalSelectedIndex = originalIndex
            }
        }
        
        // Preserve dragged point indexes on graph points rebuild
        var originalDraggedIndex: Int? = nil
        if let draggedStepIndex = draggedStepIndex {
            if case let .keyPoint(_, originalIndex) = graphPoints[Int(draggedStepIndex)].type {
                originalDraggedIndex = originalIndex
            }
        }
        
        // Preserve deleted point indexes on graph points build
        var originalDeletedIndex: Int? = nil
        if let deletedStepIndex = deletedStepIndex {
            if case let .keyPoint(_, originalIndex) = graphPoints[Int(deletedStepIndex)].type {
                originalDeletedIndex = originalIndex
            }
        }
        
        var points: [GraphPoint] = []
        
        var currentKeyPointIndex = 0
        var currentKeyPoint = roastProfile.steps[currentKeyPointIndex]
        var time = currentKeyPoint.time
        let step = roastProfile.duration / Double(maxNumberOfSteps)
        
        while time <= roastProfile.duration, currentKeyPointIndex < roastProfile.steps.count {
            currentKeyPoint = roastProfile.steps[currentKeyPointIndex]
            
            let point: GraphPoint
            if time <= currentKeyPoint.time && currentKeyPoint.time < time + step {
                point = GraphPoint.init(x: currentKeyPoint.time,
                                       y: currentKeyPoint.temperature,
                                       type: .keyPoint(step: currentKeyPoint, roastProfileIndex: currentKeyPointIndex))
                
                if let originalSelectedIndex = originalSelectedIndex,
                    currentKeyPointIndex == originalSelectedIndex {
                    selectedStepIndex = UInt(points.count)
                }
                
                if let originalDraggedIndex = originalDraggedIndex,
                    currentKeyPointIndex == originalDraggedIndex {
                    draggedStepIndex = UInt(points.count)
                }
                
                if let originalDeletedIndex = originalDeletedIndex,
                    currentKeyPointIndex == originalDeletedIndex {
                    deletedStepIndex = UInt(points.count)
                }
                
                currentKeyPointIndex += 1
            } else {
                point = GraphPoint.init(x: time, y: spline.f(time), type: .linePoint)
            }
            
            time += step
            
            points.append(point)
        }
        
        return points
    }
}
