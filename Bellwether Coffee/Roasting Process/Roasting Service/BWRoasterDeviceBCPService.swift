//
//  BWRoasterDeviceBCPService.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 18.08.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation


typealias BWRoasterDeviceBCPSetCompletion = (_ error: NSError?) -> Void
typealias BWRoasterDeviceBCPGetCompletion = (_ response: BWRoasterDeviceRoastServiceResponse?, _ error: NSError?) -> Void
typealias BWRoasterDeviceInputWeightCompletion = (_ ratio: Double?, _ weight: Double?, _ error: NSError?) -> Void
typealias BooleanErrorHandler = (_ response: Bool?, _ error: NSError?) -> Void
typealias IntErrorHandler = (_ response: Int?, _ error: NSError?) -> Void

typealias BWRoasterDeviceBCPGetStateCompletion = (_ state: BWRoasterDeviceRoastState?, _ error: NSError?) -> Void
typealias BWRoasterDeviceBCPGetRoastProfileStepCompletion = (_ step: BWRoastProfileStep?, _ error: NSError?) -> Void
typealias BWRoasterDeviceBCPGetFirmwareCompletion = (_ firmwareVersion: String?, _ error: NSError?) -> Void


struct BWRoasterDeviceRoastServiceResponse {
    var status: BWRoasterDeviceStatusCode
    var message: String
    var value: Any?
    
    static func okResponse(value: Any?) -> BWRoasterDeviceRoastServiceResponse {
        return BWRoasterDeviceRoastServiceResponse(status: .ok, message: "OK", value: value)
    }
}


import SwiftyJSON

extension BWRoasterDeviceRoastServiceResponse: BWFromJSONMappable {

    struct JSONKeys {
        static let Status    = "status"
        static let Message   = "message"
        static let Value     = "value"
    }

    static func mapFromJSON(_ json: Any) throws -> BWRoasterDeviceRoastServiceResponse {
        let swiftyJSON = JSON(json)

        guard let statusInt = swiftyJSON[JSONKeys.Status].int,
            let status = BWRoasterDeviceStatusCode(rawValue: statusInt),
            let message = swiftyJSON[JSONKeys.Message].string else {
                throw BWJSONMappableError.incorrectJSON
        }

        let value = swiftyJSON[JSONKeys.Value].object

        return BWRoasterDeviceRoastServiceResponse(status: status, message: message, value: value)
    }
}


/// Bellwether protocol service
protocol BWRoasterDeviceBCPService: BWRoasterDeviceService {

    func serialNumber(completion: @escaping StringHandler)
    func setState(_ state: BWRoasterDeviceRoastState, completion: @escaping BWRoasterDeviceBCPSetCompletion)
    func setBeanWeight(_ weight: BWWeight, completion: @escaping BWRoasterDeviceBCPSetCompletion)
    func setPreheat(_ preheat: BWTemperature, completion: @escaping BWRoasterDeviceBCPSetCompletion)
    
    func getState(_ completion: @escaping BWRoasterDeviceBCPGetStateCompletion)
    func getBeanWeight(_ completion: @escaping BWRoasterDeviceBCPGetCompletion)
    func getPreheat(_ completion: @escaping BWRoasterDeviceBCPGetCompletion)
    func getHistorySize(_ completion: @escaping BWRoasterDeviceBCPGetCompletion)
    func getDrumBottomTemperature(completion: @escaping BWRoasterDeviceBCPGetCompletion)
    func getChamberTemperature(completion: @escaping BWRoasterDeviceBCPGetCompletion)
    func getInputWeight(_ completion: @escaping BWRoasterDeviceInputWeightCompletion)
    func getHopperState(_ completion: @escaping BooleanErrorHandler)

    func set(roastProfileRecord step: BWRoastProfileStep,
             at index: Int,
             completion: @escaping BWRoasterDeviceBCPSetCompletion)
    func getRoastProfileRecord(at index: Int, completion: @escaping BWRoasterDeviceBCPGetRoastProfileStepCompletion)
    
    func getFirmwareVersion(_ completion: @escaping BWRoasterDeviceBCPGetFirmwareCompletion)
    func checkIsReadyForRoast(_ completion: @escaping BWRoasterDeviceBCPGetCompletion)
    func getUpdating(completion: @escaping (Bool?)->())
}
