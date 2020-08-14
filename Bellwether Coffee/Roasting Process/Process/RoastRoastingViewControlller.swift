//
//  RoastRoastingViewControlller.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 3/8/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import SwiftState
import CorePlot

class RoastRoastingViewControlller: RoastingStepController {
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var roastTime: UILabel!
    
    @IBOutlet weak var temperature_2: UILabel!
    @IBOutlet weak var roastTime_2: UILabel!

    @IBOutlet weak var progressView: UIView!
    
    //controls
    @IBOutlet weak var olrSlider: UISlider!
    @IBOutlet weak var olrSliderTitle: UILabel!
    @IBOutlet weak var oldSliderBox: UIView!
    
    @IBOutlet weak var drumTempToggle: ToggleView!
    @IBOutlet weak var airTempToggle: ToggleView!
    @IBOutlet weak var rateOfRiseToggle: ToggleView!

    @IBOutlet weak var manualRoastBox: UIView!
    @IBOutlet weak var manualRoastToggle: ToggleView!


    weak var graphView: BWRoastProfileGraphViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.snp.makeConstraints {[weak self] (make) -> Void in
            guard let _self = self else {return}
            
            make.left.equalTo(_self.progressView.superview!)
            make.right.equalTo(_self.progressView.superview!)
        }
        
        temperature_2.textColor = UIColor.white.withAlphaComponent(1.0)
        roastTime_2.textColor = UIColor.white.withAlphaComponent(1.0)
        
        //
        olrSlider.thumbTintColor = UIColor.brandIce
        olrSlider.minimumTrackTintColor = UIColor.brandJolt
        olrSlider.maximumTrackTintColor = UIColor.brandBrass
        
        //configure toggles
        drumTempToggle.onTap(target: self, selector: #selector(toggleShowDrumTemp))
        airTempToggle.onTap(target: self, selector: #selector(toggleShowAirTemp))
        rateOfRiseToggle.onTap(target: self, selector: #selector(toggleRateofRise))
        manualRoastToggle.onTap(target: self, selector: #selector(toggleManualRoast))
        
        //set the manual roasting slider to its default state
        manualRoastToggle.toggle(value: RoasterCommander.shared.manualRoast)
        olrSlider.enable(RoasterCommander.shared.manualRoast)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.updateEachSecond()
        
        //manual roast control can only be used inside bellwether
        manualRoastBox.isHidden = !BellwetherAPI.auth.isBellwetherUser || useBLE
    }

    override func setupAppearance() {
        super.setupAppearance()
        
        self.view.backgroundColor = .white
    }

    override func addChildViewController(_ childController: UIViewController) {
        super.addChildViewController(childController)
        
        if let graphView = childController as? BWRoastProfileGraphViewController {
            self.graphView = graphView
            graphView.roastProfileDataSource = BWRoastProfileGraphDataSource(roastProfile: RoastingProcess.roasting.roastProfile ?? Mujeres.roastProfile,isEditable: false, splineType: BWRoastProfileGraphDataSource.SplineType.cubic, showsKeyPoints: true)

        }
    }
    
    override internal func load() {
        guard isOnScreen else {return}
        //display the current temperature & time
        self.temperature.text = "\(Roaster.shared.pseudo.asFahrenheit.asInt)°"
        self.temperature_2.text = self.temperature.text

        guard let roastStartTime = RoastingProcess.roasting.roastStartTime else {
            return print("We are roasting without it having started???")
        }
        
        self.roastTime.text = Date().displayMinSec(since: roastStartTime)
        self.roastTime_2.text = self.roastTime.text
        //now let's
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveLinear, animations:
            {[weak self] in
                guard let _self = self else {return}
                _self.progressView.snp.updateConstraints { (make) -> Void in
                    guard let lastPoint = _self.graphView?.lastRoastPlotPoint,
                        let graphLayer = _self.graphView?.graphHostingView.layer else {return}
                    
                    let actualPoint = _self.view.layer.convert(lastPoint, from: graphLayer)
                    make.left.equalTo(actualPoint)
                }
                
                _self.progressView.superview!.layoutIfNeeded()
            }, completion: nil)
        
    }
    
    @objc func toggleManualRoast(recognizer: UIGestureRecognizer){
        guard let toggle = (recognizer.view as? ToggleView),
            let current = toggle.value else {return} //requires an initial value
        
        if current {
            //reset the title and do not display a percentage, since we are not under manual control
            self.olrSliderTitle.text = "PWM for VFD & Diverter"
        }
        
        //change the visuals
        toggle.toggle(value: !current)
        olrSlider.enable(!current)
        
        //send the command to the roaster
        RoasterCommander.shared.manualRoast = !current
    }
    
    @objc func toggleRateofRise(recognizer: UIGestureRecognizer){
        guard let current = graphView?.showRiseRate else {return}
        graphView?.showRiseRate = !current
        (recognizer.view as? ToggleView)?.toggle(value: !current)
    }
    @objc func toggleShowAirTemp(recognizer: UIGestureRecognizer){
        guard let current = graphView?.showRoastLog else {return}
        graphView?.showRoastLog = !current
        (recognizer.view as? ToggleView)?.toggle(value: !current)
    }
    @objc func toggleShowDrumTemp(recognizer: UIGestureRecognizer){
        guard let current = graphView?.showSkinLog else {return}
        graphView?.showSkinLog = !current
        (recognizer.view as? ToggleView)?.toggle(value: !current)
    }
    
    @IBAction func olrChange(_ sender: UISlider){
        RoasterCommander.shared.setManualRoast(temperature: sender.value.asDouble)

        //update the display to show the % we are working at; since values range to a 1000, divide by 10
        self.olrSliderTitle.text = "PWM for VFD & Diverter at \((sender.value.asDouble/10).asInt)%"

    }
    
    @IBAction func stopRoast(_ sender: Any) {
        self.confirm(title: "Are you sure you want to stop the roast?") {confirmed in
            if confirmed {
                
                //capture the roastLog before it is cleared in the abort()
                let roastLog = RoastingProcess.roasting.roastLog

                RoastingProcess.abort() //@fixme - hard reset of roaster -> stuck without resetting the current roast. Required DC
//                self.
                self.roastingStepDelegate?.stepDidComplete()
                
                RoastLogCommentsViewController.showComments(for: roastLog)

            } else {/*do nothing*/}
        }
    }
    
    override func roast(didAppend newMeasurement: BWRoastLogMeasurement) {
        if let measurements = Roaster.shared.httpsServicesFactory.roastController?.currentRoastLogMeasurements {
            graphView?.roastLogDataSource = BWRoastLogGraphDataSource(measurements: measurements)
            graphView?.roastSkinDataSource = BWRoastSkinGraphDataSource(measurements: measurements)
            graphView?.roastRiseRateDataSource = BWRoastRiseRateGraphDataSource(measurements: measurements)
            
            RoastingProcess.roasting.measurements = measurements
        }
    }
}

extension TimeInterval {
    var  asHoursMinutesSeconds: (Int, Int, Int) {
        let seconds = self.asInt
        guard seconds > 0 else {return (0,0,0)}
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}

extension Date {
    func secondsToHoursMinutesSeconds (since: Date) -> (Int, Int, Int) {
        let seconds = self.timeIntervalSince(since).asInt
        guard seconds > 0 else {return (0,0,0)}
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}

class CurvedBorderedView: UIView {
    override func layoutSubviews() {
        self.roundCorners()
        self.layer.borderColor = UIColor.brandRoast.cgColor
        self.layer.borderWidth = 1
    }
}

class ToggleView: UIView {
    @IBOutlet weak var image: UIImageView!
    
    var value: Bool?
    
    func toggle(value: Bool) {
        self.value = value
        image.image = UIImage(named: value ? "indicator_filled" : "indicator")
    }
    
    var isEnabled: Bool {if let value = value {return value } else {return false}}

}
