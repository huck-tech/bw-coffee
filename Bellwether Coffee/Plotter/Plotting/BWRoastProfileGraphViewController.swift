//
//  BWRoastProfileGraphViewController.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 28.09.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import UIKit
import CorePlot
import SnapKit

enum BWRoastProfileGraphViewInterpolation {
    case linear
    case curved
}

protocol BWRoastProfileGraphView {
    var roastProfileDataSource: BWRoastProfileGraphDataSource! { get set }
    var roastLogDataSource: BWRoastLogGraphDataSource? { get set }
    var roastSkinDataSource: BWRoastLogGraphDataSource? { get set }
    var interpolation: BWRoastProfileGraphViewInterpolation { get set }
    var roastRiseRateDataSource: BWRoastRiseRateGraphDataSource? { get set }
}


class BWRoastProfileGraphViewController: UIViewController, BWRoastProfileGraphView {
    
    let minimumLongPressDuration = 1.0
    
    // MARK: - BWRoastProfileGraphView
    var roastProfileDataSource: BWRoastProfileGraphDataSource! {
        didSet {
            if let dataSource = roastProfileDataSource {
                stepHighlightDataSource = BWStepHighlightDataSource(roastProfileDataSource: dataSource)
                if isViewLoaded {
                    updateGraphs()
                }
            }
            
            self.pointEditor.view.isHidden = true
        }
    }
    
    var roastLogDataSource: BWRoastLogGraphDataSource? {
        didSet {
            if isViewLoaded {
                updateGraphs()
            }
        }
    }
    
    var roastSkinDataSource: BWRoastLogGraphDataSource? {
        didSet {
            if isViewLoaded {
                updateGraphs()
            }
        }
    }
    
    var roastRiseRateDataSource: BWRoastRiseRateGraphDataSource? {
        didSet {
            if isViewLoaded {
                updateGraphs()
            }
        }
    }
    
    var interpolation: BWRoastProfileGraphViewInterpolation = .linear {
        didSet {
            
        }
    }
    
    var pointEditor: RoastProfilePointViewEditor!
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var graphHostingView: CPTGraphHostingView!
    
    // MARK: - Internals
    
    fileprivate var graph: CPTXYGraph!
    fileprivate var stepHighlightDataSource: BWStepHighlightDataSource!
    var roastProfilePlot: CPTScatterPlot!
    var stepHighlightPlot: CPTScatterPlot!
    fileprivate var roastLogPlot: CPTScatterPlot?
    fileprivate var roastSkinPlot: CPTScatterPlot?
    fileprivate var roastRiseRatePlot: CPTScatterPlot?
    

    // MARK: Style
    
    fileprivate static var axisLineStyle = { () -> CPTLineStyle in
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineColor = CPTColor(cgColor: UIColor.bw_color07.cgColor)
        lineStyle.lineWidth = 1
        lineStyle.lineCap = .round
        return lineStyle
    } ()
    
    fileprivate static var axisTextStyle = { () -> CPTTextStyle in
        let axisTextStyle = CPTMutableTextStyle()
        axisTextStyle.fontName = "Helvetica-Bold"
        axisTextStyle.fontSize = 10
        axisTextStyle.color = CPTColor(cgColor: UIColor.bw_color07.cgColor)
        return axisTextStyle
    } ()
    
    fileprivate static var gridLineStyle = { () -> CPTLineStyle in
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineWidth = 1
        lineStyle.lineCap = .round
        lineStyle.lineColor = CPTColor(cgColor: UIColor.bw_color11.withAlphaComponent(0.2).cgColor)
        return lineStyle
    } ()
    
    fileprivate static var tickLineStyle = { () -> CPTLineStyle in
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineWidth = 1
        lineStyle.lineCap = .round
        lineStyle.lineColor = CPTColor(cgColor: UIColor.bw_color07.cgColor)
        return lineStyle
    } ()
    
    fileprivate static var plotSymbolLineStyle = { () -> CPTLineStyle in
        let lineStyle = CPTMutableLineStyle(style: axisLineStyle)
        lineStyle.lineWidth = 30
        lineStyle.lineColor = CPTColor.init(cgColor: UIColor.clear.cgColor)
        return lineStyle
    } ()
    
    public static var plotSymbol = { () -> CPTPlotSymbol in
        let plotSymbol = CPTPlotSymbol.ellipse()
        plotSymbol.fill = CPTFill(color: CPTColor(cgColor: UIColor.brandRoast.cgColor))
        plotSymbol.lineStyle = plotSymbolLineStyle
        plotSymbol.size = CGSize(width: 10, height: 10)
        return plotSymbol
    }()
    
    public static var selectedPlotSymbol = { () -> CPTPlotSymbol in
        let plotSymbol = CPTPlotSymbol.ellipse()
        plotSymbol.fill = CPTFill(color: CPTColor(cgColor: UIColor.orange.cgColor))
        plotSymbol.lineStyle = plotSymbolLineStyle
        plotSymbol.size = CGSize(width: 25, height: 25)
        return plotSymbol
    }()
    
    fileprivate static var roastProfilePlotLineStyle = { () -> CPTLineStyle in
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineColor = CPTColor(cgColor: UIColor.brandRoast.cgColor)
        lineStyle.lineWidth = 4
        lineStyle.lineCap = .round
        lineStyle.lineJoin = .round
        return lineStyle
    } ()
    
    fileprivate static var rateOfRisePlotLineStyle = { () -> CPTLineStyle in
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineColor = CPTColor(cgColor: UIColor.brandJolt.cgColor)
        lineStyle.lineWidth = 1
        lineStyle.lineCap = .round
        lineStyle.lineJoin = .round
        return lineStyle
    } ()
    
    fileprivate static var roastRiseRatePlotLineStyle = { () -> CPTLineStyle in
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineColor = CPTColor(cgColor: UIColor.brandJolt.cgColor)
        lineStyle.lineWidth = 2
        lineStyle.lineCap = .round
        lineStyle.lineJoin = .round
        return lineStyle
    } ()
    
    
    fileprivate static var roastSkinPlotLineStyle = { () -> CPTLineStyle in
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineColor = CPTColor(cgColor: UIColor.blue.cgColor)
        lineStyle.lineWidth = 1
        lineStyle.lineCap = .round
        lineStyle.lineJoin = .round
        return lineStyle
    } ()
    
    fileprivate static var roastLogPlotLineStyle = { () -> CPTLineStyle in
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineColor = CPTColor(cgColor: UIColor.brandPurple.cgColor)
        lineStyle.lineWidth = 5
        lineStyle.lineCap = .round
        lineStyle.lineJoin = .round
        return lineStyle
    } ()
    
    fileprivate static var roastLogPlotLineStyleInvisible = { () -> CPTLineStyle in
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineColor = CPTColor(cgColor: UIColor.clear.cgColor)
        lineStyle.lineWidth = 5
        lineStyle.lineCap = .round
        lineStyle.lineJoin = .round
        return lineStyle
    } ()
    
    
    
    fileprivate let minimalTemperature = BWTemperature.bw_minRoastTemperature
    fileprivate let maximumTemperature = BWTemperature.bw_maxRoastTemperature
    fileprivate let minimalTimeStep: TimeInterval = TimeInterval(BWRoastProfile.minimumStepGap)
    
    fileprivate let graphPaddingTop     = CGFloat(10.0)
    fileprivate let graphPaddingLeft    = CGFloat(20.0)
    fileprivate let graphPaddingBottom  = CGFloat(20.0)
    fileprivate let graphPaddingRight   = CGFloat(10.0)
    
    let RORPlotSpace = CPTXYPlotSpace.init()
    let RORYAxis = CPTXYAxis.init()

    func createRateOfRiseAxis() -> CPTXYAxis {
        RORPlotSpace.yRange = CPTPlotRange.init(locationDecimal: -2.0, lengthDecimal: 48.0)
        RORYAxis.plotSpace = RORPlotSpace
        RORYAxis.coordinate = CPTCoordinate.Y
        graph.add(RORPlotSpace)
        
        return RORYAxis
    }
    
    private func initializeGraph() {
        graph = CPTXYGraph.init()
        
        guard let plotSpace = graph.defaultPlotSpace as? CPTXYPlotSpace,
            let axisSet = graph.axisSet as? CPTXYAxisSet,
            let xAxis = axisSet.xAxis,
            let yAxis = axisSet.yAxis else {
                assert(false)
                return
        }
        
        let rorAxis = createRateOfRiseAxis();

        let _axisSet = CPTAxisSet.init()
            _axisSet.axes = [xAxis, yAxis, rorAxis]
        graph.axisSet = _axisSet
    
        plotSpace.delegate = self
        
        [xAxis, yAxis].forEach { (axis: CPTXYAxis) in
            
            axis.separateLayers = true
            
            axis.axisLineStyle = type(of: self).axisLineStyle
            axis.tickDirection = CPTSign.none
            axis.majorTickLength = 15
            axis.minorTickLength = 0
            
            axis.majorTickLineStyle = type(of: self).tickLineStyle
            
            axis.majorGridLineStyle = type(of: self).gridLineStyle
            
            axis.labelingPolicy = .fixedInterval
            axis.labelTextStyle = type(of: self).axisTextStyle
            axis.tickLabelDirection = CPTSign.negative
            axis.labelOffset = 0
            
            axis.titleOffset = 30
            axis.titleTextStyle = type(of: self).axisTextStyle
        }
        
        [rorAxis].forEach { (axis: CPTXYAxis) in
            
            axis.separateLayers = true
            
            axis.axisLineStyle = type(of: self).axisLineStyle
            axis.tickDirection = CPTSign.none
            axis.majorTickLength = 15
            axis.minorTickLength = 0
            
            axis.majorTickLineStyle = type(of: self).tickLineStyle
            
            
            axis.labelingPolicy = .fixedInterval
            axis.labelTextStyle = type(of: self).axisTextStyle
            axis.tickLabelDirection = CPTSign.negative
            axis.labelOffset = -15
            
            axis.titleOffset = 30
            axis.titleTextStyle = type(of: self).axisTextStyle
        }
        
        xAxis.majorIntervalLength = 60
        xAxis.labelFormatter = BWTimeFormatter(dateComponenetsFormatter: NumberFormatter.bw_secondsNumberFormatter)
        xAxis.orthogonalPosition = NSNumber(value: BWTemperature.bw_minRoastTemperature)
        
        yAxis.majorIntervalLength = 50
        yAxis.labelFormatter = NumberFormatter.bw_temperatureNumberFormatter
        
        rorAxis.majorIntervalLength = 2
        rorAxis.labelFormatter = NumberFormatter.bw_temperatureNumberFormatter

        
        // Graph
        graph.paddingTop    = graphPaddingTop
        graph.paddingLeft   = graphPaddingLeft
        graph.paddingBottom = graphPaddingBottom
        graph.paddingRight  = graphPaddingRight
        graph.plotAreaFrame?.masksToBorder = false
        
        
        // Graph Hosting View
        graphHostingView.hostedGraph = graph
        
        let longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:)))
        
        //lengthen tapping to minimumLongPressDuration seconds
        longTapGestureRecognizer.minimumPressDuration = self.minimumLongPressDuration
        graphHostingView.addGestureRecognizer(longTapGestureRecognizer)
//                graphHostingView.allowPinchScaling = true
    }
    
    private func updateGraphs() {
        guard let plotSpace = graph.defaultPlotSpace as? CPTXYPlotSpace else {
            return
        }
        
        graph.allPlots().forEach { graph.remove($0) }
        
        if let profileDataSource = roastProfileDataSource {
            
            // Plot Space: Ranges
            guard let lastRoastProfileStep = profileDataSource.lastStep else {
                return
            }
            
            plotSpace.xRange = CPTPlotRange(location: NSNumber(value: -10),
                                            length: NSNumber(value: lastRoastProfileStep.time + 20))
            plotSpace.yRange = CPTPlotRange(location: NSNumber(value: -10 + minimalTemperature),
                                            length: NSNumber(value: maximumTemperature + 20))

            
            RORPlotSpace.xRange = plotSpace.xRange
            RORYAxis.orthogonalPosition = plotSpace.xRange.length
            
            // Plots
            
            let interpolation: CPTScatterPlotInterpolation = (self.interpolation == .linear) ? .linear : .curved
            
            // Roast Profile Graph
            let roastPlot = CPTScatterPlot()
            roastPlot.dataSource = profileDataSource
            roastPlot.delegate = self
            roastPlot.interpolation = interpolation
            roastPlot.curvedInterpolationOption = .normal
            roastPlot.dataLineStyle = type(of: self).roastProfilePlotLineStyle
            roastPlot.plotLineMarginForHitDetection = CGFloat(BWRoastProfile.minimumStepGap)
            
            roastProfilePlot = roastPlot
            
            // Hightlight of the selected step
            let highlightPlot = BWStepHighlightPlot()
            highlightPlot.dataSource = stepHighlightDataSource
            highlightPlot.interpolation = .linear
            highlightPlot.dataLineStyle = BWStepHighlightDataSource.lineStyle
            highlightPlot.labelOffset = 15.0
            stepHighlightPlot = highlightPlot
            
            
            graph.add(stepHighlightPlot)
            graph.add(roastProfilePlot)
        }
        
        if let roastLogDataSource = roastLogDataSource {
            // Roast Profile Graph
            let roastLogPlot = CPTScatterPlot()
            roastLogPlot.dataSource = roastLogDataSource
            roastLogPlot.delegate = self
            roastLogPlot.interpolation = .linear
            roastLogPlot.curvedInterpolationOption = .catmullRomUniform
            roastLogPlot.dataLineStyle = showRoastLog ? type(of: self).roastLogPlotLineStyle : type(of: self).roastLogPlotLineStyleInvisible
            
            
            //hold on to it, because we need it to calculate points later
            self.roastLogPlot = roastLogPlot
            graph.add(roastLogPlot)
        }
        
        if let roastSkinDataSource = roastSkinDataSource, showSkinLog {
            // Roast Skin Temperature Graph
            let skinPlot = CPTScatterPlot()
            skinPlot.dataSource = roastSkinDataSource
            skinPlot.delegate = self
            skinPlot.interpolation = .linear
            skinPlot.curvedInterpolationOption = .catmullRomUniform
            skinPlot.dataLineStyle = type(of: self).roastSkinPlotLineStyle
            
            self.roastSkinPlot = skinPlot
            graph.add(skinPlot)
        }
        
        if let roastRiseRateDataSource = roastRiseRateDataSource, showRiseRate {
            // Roast Skin Temperature Graph
            let riseRatePlot = CPTScatterPlot()
            riseRatePlot.dataSource = roastRiseRateDataSource
            riseRatePlot.delegate = self
            riseRatePlot.interpolation = .linear
            riseRatePlot.curvedInterpolationOption = .catmullRomUniform
            riseRatePlot.dataLineStyle = type(of: self).roastRiseRatePlotLineStyle

            self.roastRiseRatePlot = riseRatePlot

            graph.add(riseRatePlot, to: RORPlotSpace)
        }
        
        
        
        graph.reloadData()
    }
    
    var showRoastLog = true
    var showSkinLog = true
    var showRiseRate = true
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeGraph()
        
        self.pointEditor = createPointEditor()
    }
    
    private func createPointEditor() -> RoastProfilePointViewEditor {
        let editor = RoastProfilePointViewEditor.bw_instantiateFromStoryboard()
        
        self.bw_addViewController(editor)
        self.view.addSubview(editor.view)
        editor.view.snp.makeConstraints {make in
            
//            make.aspectRatio(50, by: 60, self: editor.view)
//            make.aspectRatio(100, by: 1, self: self.view)
            make.height.equalTo(60)
            make.width.equalTo(50)
            make.top.equalTo(0)
            make.centerX.equalTo(0)
        }
        editor.view.roundCorners()
        
        return editor
    }
    
    var isEditable: Bool {
        guard let roastProfileDataSource = roastProfileDataSource else {
            return false
        }
        
        return roastProfileDataSource.isEditable
    }
    
    @objc fileprivate func longPress(sender: UILongPressGestureRecognizer) {
        guard isEditable else {return}
        
        guard let space = graph.defaultPlotSpace,
            let plotArea = graph.plotAreaFrame?.plotArea else {
                return
        }
        
        let touchLocation = sender.location(in: graphHostingView)
        let plotAreaViewTouchPoint = graphHostingView.layer.convert(touchLocation, to: plotArea)
        
        guard let points = space.plotPoint(forPlotAreaViewPoint: plotAreaViewTouchPoint) else {
            return
        }
        
        let touchPoint = CGPoint(x: points[CPTScatterPlotField.X.rawValue].doubleValue,
                                 y: points[CPTScatterPlotField.Y.rawValue].doubleValue)
        var closestPlotSymbolIndex = roastProfilePlot.indexOfVisiblePointClosest(toPlotAreaPoint: plotAreaViewTouchPoint)
        
        guard Int(closestPlotSymbolIndex) != NSNotFound else {
            return
        }
        
        let plotPoint = roastProfileDataSource.plotPoint(for: roastProfilePlot,
                                                         recordAt: closestPlotSymbolIndex)
        closestPlotSymbolIndex = roastProfileDataSource.nearestStepIndex(for: TimeInterval(plotPoint.x))
        let closestPlotPoint = roastProfileDataSource.plotPoint(for: roastProfilePlot,
                                                                recordAt: closestPlotSymbolIndex)
        
        guard closestPlotSymbolIndex != 0,
            closestPlotSymbolIndex != roastProfileDataSource.numberOfRecords(for: roastProfilePlot) - 1,
            closestPlotPoint.distance(to: touchPoint) < CGFloat(BWRoastProfile.minimumStepGap) else {
                return
        }
        
        guard roastProfileDataSource.step(at: closestPlotSymbolIndex) != nil else {
            return
        }
        
        
        roastProfileDataSource.deletedStepIndex = closestPlotSymbolIndex
        showDeleteMenuController(forPointAt: closestPlotSymbolIndex)
    }
    
    private func hostingViewPoint(at index: UInt) ->  CGPoint? {
        guard let plotArea = graph.plotAreaFrame?.plotArea else {
            return nil
        }
        
        
        let plotAreaPoint = roastProfilePlot.plotAreaPointOfVisiblePoint(at: index)
        return graphHostingView.layer.convert(plotAreaPoint, from: plotArea)
    }
    
    func showEditor(forPointAt index: UInt, animated: Bool = true) {
        guard let hostingViewPoint = self.hostingViewPoint(at: index) else {return}
        guard self.roastProfileDataSource.isEditable else {return}
        //move it to the right location
        self.pointEditor.view.snp.remakeConstraints {make in
            make.height.equalTo(90)
            make.width.equalTo(75)
            make.top.equalTo(hostingViewPoint.y + 10)
            make.centerX.equalTo(hostingViewPoint.x)
        }
        
        //load it with the right data
        pointEditor.load(index: index, controller: self)
        pointEditor.view.isHidden = false
        pointEditor.view.becomeFirstResponder()
    }
    

    fileprivate func showDeleteMenuController(forPointAt index: UInt, animated: Bool = true) {
        guard let hostingViewPoint = self.hostingViewPoint(at: index) else {return}

        //hide the other one
        self.pointEditor.view.isHidden = true
        
        let menuController = UIMenuController.shared
        menuController.menuItems = [
            UIMenuItem(title: NSLocalizedString("ROAST_PROFILE_EDITING_DELETE_KEYPOINT", comment: ""),
                       action: #selector(deleteStepMenuItemPressed(sender:))),
            UIMenuItem(title: "X",
                       action: #selector(dismissMenuItemPressed(sender:)))
        ]
        
        let targetRect = CGRect(origin: hostingViewPoint, size: CGSize(width: 1, height: 1))
        
        menuController.setTargetRect(targetRect, in: view)
        menuController.setMenuVisible(true, animated: animated)
        view.becomeFirstResponder()
    }
    
    public var lastRoastPlotPoint: CGPoint? {
        guard let roastLogPlot = self.roastLogPlot,
            let roastLogDataSource = self.roastLogDataSource,
            let plotArea = graph.plotAreaFrame?.plotArea else {return nil}
        let index = roastLogDataSource.numberOfRecords(for: roastLogPlot) - 1
        let plotAreaPoint = roastLogPlot.plotAreaPointOfVisiblePoint(at: index)

        return graphHostingView.layer.convert(plotAreaPoint, from: plotArea)
    }
    
    fileprivate func hideDeleteMenuController(animated: Bool = true) {
        UIMenuController.shared.setMenuVisible(false, animated: animated)
    }
    
    @objc fileprivate func editStepMenuItemPressed(sender: UIMenuItem) {
        guard let index = roastProfileDataSource.deletedStepIndex else {
            return
        }
        print(#function)
    }

    
    @objc fileprivate func dismissMenuItemPressed(sender: UIMenuItem) {
        print(#function)
    }
    
    @objc fileprivate func deleteStepMenuItemPressed(sender: UIMenuItem) {
        guard let index = roastProfileDataSource.deletedStepIndex else {
            return
        }
        
        roastProfileDataSource.remove(at: index)
        roastProfileDataSource.deletedStepIndex = nil
        graph.reloadData()
    }
    
}


extension CPTGraph {
    
}


extension BWRoastProfileGraphViewController: CPTScatterPlotDelegate {
    
    func scatterPlot(_ plot: CPTScatterPlot, plotSymbolWasSelectedAtRecord index: UInt) {
        guard plot === roastProfilePlot else {
            return
        }
    }
    
    func scatterPlot(_ plot: CPTScatterPlot, plotSymbolTouchDownAtRecord index: UInt) {
        guard plot === roastProfilePlot else {
            return
        }
        
        //ensure the delete menu is dismissed
        self.hideDeleteMenuController()
    
        NSLog("Plot symbol touch down: \(index)")
        toggle(recordAt: index, selected: true)
        roastProfileDataSource.draggedStepIndex = index
    }
    
    func scatterPlot(_ plot: CPTScatterPlot, plotSymbolTouchUpAtRecord index: UInt) {
        guard plot === roastProfilePlot else {
            return
        }
        
        
    }
    
    func toggle(recordAt index: UInt, selected: Bool) {
        if selected {
            roastProfileDataSource.selectedStepIndex = index
            DispatchQueue.main.async
                {[weak self] in self?.showEditor(forPointAt: index)}
        } else {
            roastProfileDataSource.selectedStepIndex = nil
        }
        roastProfilePlot.reloadPlotSymbols()
        stepHighlightPlot.reloadData()
    }
    
    func scatterPlot(_ plot: CPTScatterPlot, dataLineWasSelectedWith event: UIEvent) {
        
        //ensure the delete menu is dismissed
        self.hideDeleteMenuController()

        guard let space = graph.defaultPlotSpace,
            let plotArea = graph.plotAreaFrame?.plotArea,
            let touch = event.touches(for: graphHostingView)?.first else {
                return
        }
        
        let touchLocation = touch.location(in: graphHostingView)
        let plotAreaViewTouchPoint = graphHostingView.layer.convert(touchLocation, to: plotArea)
        
        guard let pointXY = space.plotPoint(forPlotAreaViewPoint: plotAreaViewTouchPoint) else {
            return
        }
        
        
        let newY = pointXY[CPTScatterPlotField.Y.rawValue].doubleValue
        let fNewY = (newY - 32) * 5/9
        let touchPoint = (x: pointXY[CPTScatterPlotField.X.rawValue].doubleValue,
                          y: fNewY)
        
        
        let nearestLeftStepIndex = roastProfileDataSource.nearestLeftStepIndex(for: touchPoint.x)
        let nearestRightStepIndex = roastProfileDataSource.nearestRightStepIndex(for: touchPoint.x)
        
        if let nearestLeftStep = roastProfileDataSource.step(at: nearestLeftStepIndex),
            fabs(touchPoint.x - nearestLeftStep.time) < minimalTimeStep {
            toggle(recordAt: nearestLeftStepIndex, selected: true)
            roastProfileDataSource.draggedStepIndex = nearestLeftStepIndex
            return
        }
        
        if let nearestRightStep = roastProfileDataSource.step(at: nearestRightStepIndex),
            fabs(touchPoint.x - nearestRightStep.time) < minimalTimeStep {
            toggle(recordAt: nearestRightStepIndex, selected: true)
            roastProfileDataSource.draggedStepIndex = nearestRightStepIndex
            return
        }
        
        let step = BWRoastProfileStep(temperature: touchPoint.y, time: touchPoint.x)
        roastProfileDataSource.selectedStepIndex = UInt(nearestRightStepIndex)
        roastProfileDataSource.insert(step, at: nearestRightStepIndex)
        graph.reloadData()
    }
}


extension BWRoastProfileGraphViewController: CPTPlotSpaceDelegate {
    
    func plotSpace(_ space: CPTPlotSpace,
                   shouldHandlePointingDeviceDraggedEvent event: UIEvent,
                   at point: CGPoint) -> Bool {
        
        
        self.hideDeleteMenuController()
        
        guard isEditable else {return false}
        
        guard space === self.graph.defaultPlotSpace,
            let plotArea = graph.plotAreaFrame?.plotArea,
            let draggedStepIndex = roastProfileDataSource.draggedStepIndex else {
                return false
        }
        
        let plotAreaViewTouchPoint = graph.convert(point, to: plotArea)
        
        guard let pointXY = space.plotPoint(forPlotAreaViewPoint: plotAreaViewTouchPoint) else {
            return false
        }
        
        var touchPoint = (x: pointXY[CPTScatterPlotField.X.rawValue].doubleValue,
                          y: pointXY[CPTScatterPlotField.Y.rawValue].doubleValue)
        touchPoint.y = (touchPoint.y - 32) * 5/9
//        NSLog("Dragging: (\(touchPoint.x), \(touchPoint.y))")
        
        if draggedStepIndex == 0 || draggedStepIndex == roastProfileDataSource.lastStepIndex {
            //pick up the touchpoint in the first place.
            touchPoint.x = roastProfileDataSource.step(at: draggedStepIndex)!.time
            //this changes the roast profiles starting temp, so we have to report it.
            
        } else if let leftStep = roastProfileDataSource.step(before: draggedStepIndex),
            let rightStep = roastProfileDataSource.step(after: draggedStepIndex) {
            
            if fabs(leftStep.time - rightStep.time) < 2 * minimalTimeStep {
                
                //accept the touch as-is
                touchPoint.x = max(touchPoint.x, leftStep.time)
                touchPoint.x = min(touchPoint.x, rightStep.time)
            } else {
                
                //bound the touch to the right
                touchPoint.x = max(touchPoint.x, leftStep.time + minimalTimeStep)
                
                //bound the touch on the right
                touchPoint.x = min(touchPoint.x, rightStep.time - minimalTimeStep)
            }
        } else {
            print("nothing can be done at this point")
            
        }
        
        
        //bound the point vertically, based on min and max temperatures
        touchPoint.y = max(min(touchPoint.y, maximumTemperature.asCelsius), minimalTemperature.asCelsius)
        
        self.showEditor(forPointAt: draggedStepIndex)
        
        let movedStep = BWRoastProfileStep(temperature: touchPoint.y, time: touchPoint.x)
        NSLog("Dragging processed: (\(touchPoint.x), \(touchPoint.y)) for step at \(movedStep)")
        roastProfileDataSource.replaceStep(at: draggedStepIndex,
                                           with: movedStep)
        
//        roastProfilePlot.reloadPlotData(inIndexRange: NSRange(location: Int(draggedStepIndex), length: 1))
        roastProfilePlot.reloadData()
        stepHighlightPlot.reloadData()
        
        return false
    }
    
    func plotSpace(_ space: CPTPlotSpace, shouldHandlePointingDeviceCancelledEvent event: UIEvent) -> Bool {
        return false
    }
    
    func plotSpace(_ space: CPTPlotSpace, shouldHandlePointingDeviceUp event: UIEvent, at point: CGPoint) -> Bool {
        guard isEditable else {return false}

        guard let draggedStepIndex = roastProfileDataSource.draggedStepIndex else {
            return false
        }
        toggle(recordAt: draggedStepIndex, selected: true)
        roastProfileDataSource.draggedStepIndex = nil
        
        if roastProfileDataSource.deletedStepIndex != nil {
            roastProfileDataSource.deletedStepIndex = nil
            hideDeleteMenuController()
        }
        return false
    }
    
}


class BWRoastProfileGraphRootView: UIView {
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(BWRoastProfileGraphViewController.deleteStepMenuItemPressed(sender:)) {
            return true
        } else {
            return super.canPerformAction(action, withSender: sender)
        }
    }
    
    @objc func deleteStepMenuItemPressed(sender: UIMenuItem) {
        _ = self.next?.perform(#selector(deleteStepMenuItemPressed(sender:)), with: sender)
    }
}


extension BWRoastProfileGraphDataSource {
    
    func plotPoint(for plot: CPTPlot, recordAt index: UInt) -> CGPoint {
        let plotPointX = double(for: plot,
                                field: UInt(CPTScatterPlotField.X.rawValue),
                                record: index)
        let plotPointY = double(for: plot,
                                field: UInt(CPTScatterPlotField.Y.rawValue),
                                record: index)
        return CGPoint(x: plotPointX, y: plotPointY)
    }
    
}


fileprivate class BWStepHighlightDataSource: NSObject, CPTScatterPlotDataSource {
    
    // MARK: - BWStepHighlightDataSource
    var roastProfileDataSource: BWRoastProfileGraphDataSource
    
    var points: [BWRoastProfileGraphPoint] {
        if let selectedStep = roastProfileDataSource.selectedStep {
            return [
                (x: 0, y: selectedStep.temperature * 9/5 + 32),
                (x: selectedStep.time, y: selectedStep.temperature * 9/5 + 32),
                (x: selectedStep.time, y: 0),
            ]
        } else {
            return []
        }
    }
    
    init(roastProfileDataSource: BWRoastProfileGraphDataSource) {
        self.roastProfileDataSource = roastProfileDataSource
    }
    
    // MARK: - Style
    
    fileprivate static var lineStyle = { () -> CPTLineStyle in
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineWidth = 1
        lineStyle.lineCap = .round
        return lineStyle
    } ()
    
    // MARK: - CPTPlotDataSource
    
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return UInt(points.count)
    }
    
    func double(for plot: CPTPlot, field fieldEnum: UInt, record index: UInt) -> Double {
        guard let field = CPTScatterPlotField(rawValue: Int(fieldEnum)) else {
            return Double.nan
        }
        
        let point = points[Int(index)]
        
        switch field {
        case .X:
            return point.x
        case .Y:
            return point.y
        }
    }
    
    func dataLabel(for plot: CPTPlot, record index: UInt) -> CPTLayer? {
        let point = points[Int(index)]
        if index == 0 {
            return CPTTextLayer(text: NumberFormatter.bw_formattedTemperatureNoConversion(point.y))
        } else if index == UInt(points.count - 1) {
            let formattedTime = NumberFormatter.bw_formattedSeconds(point.x)
            return CPTTextLayer(text: formattedTime)
        } else {
            return nil
        }
    }
}


class BWStepHighlightPlot: CPTScatterPlot {
    
    override func positionLabelAnnotation(_ label: CPTPlotSpaceAnnotation, for index: UInt) {
        guard let xValue = cachedNumber(forField: UInt(CPTScatterPlotField.X.rawValue), record: index),
            let yValue = cachedNumber(forField: UInt(CPTScatterPlotField.Y.rawValue), record: index) else {
                return
        }
        
        var isPositiveDirection = true
        guard let yRange = plotSpace?.plotRange(for: CPTCoordinate.Y) else {
            return
        }
        
        if CPTDecimalLessThan(yRange.lengthDecimal, CPTDecimalFromInt(0)) {
            isPositiveDirection = !isPositiveDirection
        }
        
        label.anchorPlotPoint = [xValue, yValue]
        label.contentLayer?.isHidden = self.isHidden || xValue.doubleValue.isNaN || yValue.doubleValue.isNaN
        
        if isPositiveDirection {
            label.displacement = CGPoint(x: labelOffset, y: labelOffset)
        } else {
            label.displacement = CGPoint(x: labelOffset, y: labelOffset)
        }
    }
}

extension ConstraintMaker {
    public func aspectRatio(_ x: Int, by y: Int, self instance: ConstraintView) {
        self.width.equalTo(instance.snp.height).multipliedBy(x / y)
    }
}
