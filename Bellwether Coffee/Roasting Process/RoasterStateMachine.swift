//
//  RoasterStateMachine.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 3/2/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import SwiftState
import UIKit
import Alamofire

typealias Mujeres = Shared

protocol RoasterDelegate: BWRoasterDeviceRoastControllerDelegate {
    func roaster(available: Bool)
    func roasterUpdated(status: BWRoasterDeviceRoastStatus?)//
    func roastCooling()
    func hopperChanged(inserted: Bool)
}

extension Notification.Name {
    static let hopperChanged = Notification.Name(Roaster.Notifications.hopperChanged.rawValue)
    static let roasterStateUpdated = Notification.Name(Roaster.Notifications.roasterStateUpdated.rawValue)
    static let scaleAutoTared = Notification.Name(Roaster.Notifications.scaleAutoTared.rawValue)
}

typealias ErrorHandler = (NSError?) -> Void



extension Roaster: RoasterDelegate {
    func roaster(available: Bool) {
    
    }
    func hopperChanged(inserted: Bool) {
        delegate?.hopperChanged(inserted: inserted)
    }
    
    func roasterUpdated(status: BWRoasterDeviceRoastStatus?) {
        
        if UIApplication.shared.applicationState != .active {print("roasterUpdate in background")}
        
        guard let status = status else {return}
        
        self.debug = "\(Date().timeIntervalSinceReferenceDate.asInt % 10) : \(status.state) @ s:\(status.drumpBottomTemp.asFahrenheit),b:\(status.temperature.asFahrenheit) isReadyToRoast:\(status.isReadyToRoast?.description ?? "nil") roasting:\(RoastingProcess.roasting.state), \(Roasting.roasting.description) hopper:\(Roaster.shared.hopperInserted) updating:\(Roaster.shared.firmwareUpdating)"
        
        print(debug ?? "--")

        self.state = status.state
        
        if (self.state == .roast || self.state == .cool) && Roasting.roasting.state == .none {
            //this should never happen! Must mean that we launched and the roaster was already at work.
//            print("launched without a roast")
        }
        
        //if we are getting roasterUpdated *but* we report as disconnected, turn on bluetooth again
        if !isConnected {
            self.device?.hold(automatically: true)
        }
        
        if status.temperature != 0 {
            self.temperature = status.temperature
            self.coreTemperature = status.drumpBottomTemp
        }
        self.delegate?.roasterUpdated(status: status)
        
        NotificationCenter.default.post(name: .roasterStateUpdated, object: nil)
    }
    
    func roastDidStart() {
        print(#function)
        self.delegate?.roastDidStart()
    }
    
    func roast(didAppend newMeasurement: BWRoastLogMeasurement) {
        self.delegate?.roast(didAppend: newMeasurement)
    }
    func roast(didChange summary: BWRoastLogSummaryBlank) {
        self.delegate?.roast(didChange: summary)
    }
    func roastDidChangeState(from oldState: BWRoasterDeviceRoastState,
                             to newState: BWRoasterDeviceRoastState) {
        print("\(#function) old:\(oldState) new: \(newState)")
        
        self.delegate?.roastDidChangeState(from: oldState, to: newState)
    }
    func roasterIsReadyToRoast() {
        self.delegate?.roasterIsReadyToRoast()
    }
    func roastDidFinish() {
        print(#function)
        self.delegate?.roastDidFinish()
    }
    func roastDidFail(with error: NSError) {
        print(#function)
        self.delegate?.roastDidFail(with: error)
    }
    
    func roastCooling() {
        print(#function)
        delegate?.roastCooling()
    }
}
