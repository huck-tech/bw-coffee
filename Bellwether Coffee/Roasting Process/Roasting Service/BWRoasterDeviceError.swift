//
//  BWRoasterDeviceError.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 14.09.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation


let BWRoasterDeviceErrorDomain = "BWRoasterDeviceErrorDomain"


enum BWRoasterDeviceErrorCode: Int {
    case authenticationFailed = 1001
    case bleFailure
    case invalidServerResponse
    case internalServerError
    case invalidSTMStatusCode
    case invalidState
    case pollingError
    case tooManyStepsInRoastProfile
}


extension NSError {
    
    struct BWRoasterDeviceErrorKey {
        static let StatusCode = "status_code"
    }
    
    static func bw_roasterError(_ code: BWRoasterDeviceErrorCode,
                                message: String? = nil,
                                underlyingError: NSError? = nil) -> NSError {
        var userInfo: [AnyHashable: Any]? = [:]
        if let message = message {
            userInfo?[NSLocalizedDescriptionKey] = message
        }
        if let underlyingError = underlyingError {
            userInfo?[NSUnderlyingErrorKey] = underlyingError
        }
        if userInfo?.isEmpty ?? false {
            userInfo = nil
        }
        
        return NSError(domain: BWRoasterDeviceErrorDomain, code: code.rawValue, userInfo: userInfo as? [String : Any])
    }
    
    static func bw_roasterError(for statusCode: BWRoasterDeviceStatusCode,
                                message: String? = nil) -> NSError {
        let userInfo: [String : Any] = [
            NSLocalizedDescriptionKey: message ?? statusCode.stringValue,
            BWRoasterDeviceErrorKey.StatusCode: statusCode
        ]
        
        return NSError(domain: BWRoasterDeviceErrorDomain,
                       code: BWRoasterDeviceErrorCode.invalidSTMStatusCode.rawValue,
                       userInfo: userInfo)

    }
}
