//
//  RoastingProcess.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 6/22/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import SwiftyJSON

class RoastingProcess {
    var state: RoastingState = .none {
        didSet {
            NotificationCenter.default.post(name: .roastingChanged, object: nil)
        }
    }
    //only one process at a time for now.
    static var editing = RoastingProcess()
    static var roasting = RoastingProcess() {
        didSet {
            print("RoastingProcess.roasting didSet")
        }
    }
    var greenItem: GreenItem? = GreenItem.empty()
    
    var uuid = UUID().uuidString //generate a unique identifier
    var roastProfile: BWRoastProfile? = Mujeres.roastProfile
    var targetWeight: Double? = 6.0 * (1 - 0.18)
    var inputWeight: Double? = 6.0
    var outputWeight: Double? {
        guard let inputWeight = inputWeight,
            let shrinkage = roastProfile?.shrinkage else {return nil}
        return inputWeight * (1.0 - shrinkage)
    }
    
    func weightToLoad(inputWeight: Double?) -> Double? {
        guard let roastProfile = roastProfile,
            let targetWeight = targetWeight else {return nil}
        
        return targetWeight/(1.0 - roastProfile.shrinkage)
    }
    
    var startedPreheat = false
    var roastStartTime: Date?
    var coolStartTime: Date?
    var measurements = [BWRoastLogMeasurement]()
    
    var roastLog: RoastLog?
    
    func log(completion: BoolHandler? = nil) {
        print("...................................\(#function)")
        let roastLog = self.roastLog ?? RoastLog() //create one if needed or just recycle the existing
        roastLog.date = roastStartTime
        roastLog.roaster = BellwetherAPI.auth.currentProfileInfo?.title
        roastLog.bean = greenItem?.bean
        roastLog.profile = roastProfile?.metadata?.id
        roastLog.inputWeight = inputWeight?.asNumber
        roastLog.dropTime = roastProfile?.duration.asNumber
        roastLog.outputWeight = self.targetWeight?.asNumber
        roastLog.measurements = JSON.init(measurements.map{$0.mapToJSON()}).rawString()
        roastLog.firmware = Roaster.shared.firmwareVersion
        roastLog.state = Roaster.shared.state.rawValue.asNumber
        roastLog.machine = Roaster.shared.device?.roasterID
        roastLog.serialNumber = Roaster.shared.serialNumber
        
        roastLog.cafe = BellwetherAPI.auth.cafe
        
        //create a RoastData object for the roast log if it does not already exist
        let roastData = roastLog.data ?? RoastData()
        
        roastData.log = roastLog
        roastData.measurements = JSON.init(measurements.map{$0.mapToJSON()}).rawString()
        roastData.saveInBackground {success, error in
            roastLog.data = roastData
            roastLog.saveInBackground {success, error in
                if let error = error {
                    completion?(false)
                    return print("\(#function) error:\(error)")
                }
                completion?(success)
            }
            
            self.roastLog = roastLog
        }
    }
    
    func start() {
        if startedPreheat == false {
            startedPreheat = true
            self.log()  //log our starting point
            Roaster.shared.start()
        }
    }
    
    func roast(completion: @escaping ErrorHandler) {
        roastStartTime = Date()
        Roaster.shared.roast(completion: completion)
    }
    
    static func reset() {
        roasting = RoastingProcess()
        Roaster.shared.reset()
    }
    
    static func abort(completion: ErrorHandler? = nil) {
        RoastingProcess.roasting.state = .aborted
        Roaster.shared.shutdown() {error in
            completion?(error)
        }
        RoastingProcess.reset()
    }
}

extension RoastingProcess: RoastingInfoSource {
    var beanName: String? {return self.greenItem?._name}
}
