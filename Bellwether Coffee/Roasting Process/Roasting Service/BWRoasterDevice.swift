//
//  BWRoasterDevice.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 01.08.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation
import SwiftState

class BWRoasterDevice {
    var info: BWRoasterDeviceInfo
    var services: [BWRoasterDeviceService]
    
    init(info: BWRoasterDeviceInfo, services: [BWRoasterDeviceService]) {
        self.info = info
        self.services = services
    }
}


enum BWRoasterDeviceRoastState: Int, StateType {
    case reset      = 0
    case initialize = 1
    case offline    = 2
    case ready      = 3
    case preheat    = 4
    case roast      = 5
    case cool       = 6
    case shutdown   = 7
    case error      = 8
    
    static var all: [BWRoasterDeviceRoastState] = [.reset, .initialize, .offline, .ready, .preheat, .roast, .cool, .shutdown, .error]
}


extension BWRoasterDeviceRoastState: BWStringValueRepresentable {
    var stringValue: String {
        switch self {
        case .reset:
            return "Reset"
        case .initialize:
            return "Initialize"
        case .offline:
            return "Offline"
        case .ready:
            return "Ready"
        case .preheat:
            return "Preheat"
        case .roast:
            return "Roast"
        case .cool:
            return "Cool"
        case .shutdown:
            return "Shutdown"
        case .error:
            return "Error"
        }
    }
}

/**
 @enum BWRoasterDeviceStatusCode
 Represents status of low-lewel roaster commands
 */
enum BWRoasterDeviceStatusCode: Int, BWStringValueRepresentable {
    case ok = 0
    case invalidModule = 1
    case invalidUnitNumber = 2
    case invalidCommand = 3
    case incorrectNumberOfParameters = 4
    case invalidParameter = 5
    case incorrectChecksum = 6
    case commandOverflow = 7
    case commandRejectedControllerDisabled = 8
    case motorCommandRejectedMotorBusy = 9
    case unsupportedMotorCommandNoEncoder = 10
    case motorCommandRejectedOptoAlreadyInUseAsStopCondition = 11
    case reserved = 12
    case firmwareInternalLogicError = 13
    case commandNotYetSupported = 14
    case unachievableMoveParameters = 15
    case parseError = 99
    case invalidRequest = 400

    var stringValue: String {
        switch self {
        case .ok:
            return "OK"
        case .invalidModule:
            return "Invalid module"
        case .invalidUnitNumber:
            return "Invalid unit number"
        case .invalidCommand:
            return "Invalid command"
        case .incorrectNumberOfParameters:
            return "Incorrect number of parameters"
        case .invalidParameter:
            return "Invalid parameter"
        case .incorrectChecksum:
            return "Incorrect checksum"
        case .commandOverflow:
            return "Command overflow"
        case .commandRejectedControllerDisabled:
            return "Command rejected: controller disabled"
        case .motorCommandRejectedMotorBusy:
            return "Motor command rejected: motor busy"
        case .unsupportedMotorCommandNoEncoder:
            return "Unsupported motor command: no encoder"
        case .motorCommandRejectedOptoAlreadyInUseAsStopCondition:
            return "Motor command rejected: opto already in use as stop condition"
        case .reserved:
            return ""
        case .firmwareInternalLogicError:
            return "Firmware internal logic error"
        case .commandNotYetSupported:
            return "Command not yet supported"
        case .unachievableMoveParameters:
            return "Unachievable move parameters"
        case .parseError:
            return "Parse error"
        case .invalidRequest:
            return "Invalid request"
        }
    }
}
