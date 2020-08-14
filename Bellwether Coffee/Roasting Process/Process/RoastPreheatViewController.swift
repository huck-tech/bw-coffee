//
//  RoastPreheatViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 3/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import UIKit
import SwiftState
import NotificationBannerSwift

enum Mode {
    case release
    case debug
    
    static var shared: Mode {
//        guard let email = BellwetherAPI.auth.currentProfileInfo?.subtitle else {return .release}

        return .debug //["john@b", "marcos@b"].filter{email.contains($0)}.count == 0 ? .release : .debug
    }
}

class RoastPreheatViewController: RoastingStepController {
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var coreTemperature: UILabel!
    @IBOutlet weak var bellwetherlogo: UIImageView!
    @IBOutlet weak var hopperSwitch: UISwitch!
    
    let ANIMATION_SCALE = 1.1
    
    var promptedForBucket = false
    var banner: NotificationBanner?
    
    override func setupAppearance() {
        super.setupAppearance()
        
        self.view.backgroundColor = .white
        self.coreTemperature.isHidden = Mode.shared == .release
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.load()
        self.animate()
        self.updateEachSecond()
        
        DispatchQueue.main.async{[weak self] in
            guard let _self = self else {return}
            //remind the user to have a bucket ready to roll
            if !_self.promptedForBucket {
                _self.promptedForBucket = true
                _self.banner = NotificationBanner(title: "Place Bean Bucket", subtitle: "Please ready the bucket for bean exit.",
                                                style: .info, colors: BWColors())
                _self.banner?.autoDismiss = false
                _self.banner?.dismissOnTap = true
                _self.banner?.show()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        banner?.dismiss()
    }

    @objc private func animate() {
        //go ahead only if the virew is being presented
        guard self.viewIfLoaded?.window != nil else {return}
        
        UIView.animate(withDuration: 1.0) {[weak self ] in
            guard let _self = self else {return}
            
            //every second, either expand to ANIMATION_SCALE or contract back to 1
            let y = Date().timeIntervalSinceReferenceDate.asInt % 2 == 0 ? _self.ANIMATION_SCALE : 1
            let x = CGFloat(y)
            _self.bellwetherlogo.transform = CGAffineTransform(scaleX: x, y: x)
        }
    }
    
    override internal func load() {

        //if we are not preheating, disappear exit stage left
        
        self.animate()
        
        self.hopperSwitch.isOn = Roaster.shared.hopperInserted

        //display the current temperature adnd the target
        guard let target = RoastingProcess.roasting.roastProfile?.actualPreheat?.asFahrenheit else {return}
        let temp = Roaster.shared.temperature.asFahrenheit
        let core = Roaster.shared.coreTemperature.asFahrenheit
        
        let required = RoastingProcess.roasting.roastProfile?.firstTemperature?.asFahrenheit ?? Roaster.CORE_TEMP_REQUIRED
        var tempRatio = (temp - Roaster.AMBIENT_TEMPERATURE)/(target - Roaster.AMBIENT_TEMPERATURE)
        var coreRatio = (core - Roaster.AMBIENT_TEMPERATURE)/(required - Roaster.AMBIENT_TEMPERATURE)
        
        if tempRatio < 0.0 {tempRatio = 0}
        if coreRatio < 0.0 {coreRatio = 0}

        
        if tempRatio > 1.0 {tempRatio = 1}
        if coreRatio > 1.0 {coreRatio = 1}
        
        //there is no requirement of core temperature for beta units
        if Roaster.shared.isBeta {coreRatio = 1.0}

        let percent = (min(tempRatio, coreRatio)*100.0).asInt
        
        self.temperature.text = "\(percent)%"
        self.coreTemperature.text = "Skins: \(core)° / \(required)°"
    }
    
    override func addChildViewController(_ childController: UIViewController) {
        super.addChildViewController(childController)
        
        if let graphView = childController as? BWRoastProfileGraphViewController {
            graphView.roastProfileDataSource = BWRoastProfileGraphDataSource(roastProfile: RoastingProcess.roasting.roastProfile ?? Mujeres.roastProfile,isEditable: false, splineType: BWRoastProfileGraphDataSource.SplineType.cubic, showsKeyPoints: true)
        }
    }

    @IBAction func stopRoast(_ sender: Any) {
        self.confirm(title: "Are you sure you want to stop the roast?") {confirmed in
            if confirmed {
                
                //capture the roastLog, becausae the abort() will blow it away
                let roastLog = RoastingProcess.roasting.roastLog
                
                RoastingProcess.abort()
                self.roastingStepDelegate?.stepDidComplete()
                
                //critical to present this last, because otherwise presentNextStep() not called
                RoastLogCommentsViewController.showComments(for: roastLog)
            } else {/*do nothing*/}
        }
    }
}

extension String {
    static var degree: String {
        return "°"
    }
}

extension Double {
        var asFahrenheit: Double {
        return  (self * (9/5)) + 32
    }
    
    var asCelsius: Double {
        return (self - 32.0) / 1.8
    }
}


class BWColors: BannerColorsProtocol {
    
    internal func color(for style: BannerStyle) -> UIColor {
        switch style {
        case .danger:   return .brandJolt
        case .info:     return .brandPurple
        case .none:     return .clear
        case .success:  return UIColor(red:0.22, green:0.80, blue:0.46, alpha:1.00)
        case .warning:  return UIColor(red:1.00, green:0.66, blue:0.16, alpha:1.00)
        }
    }
}

