//
//  BWRoasterDeviceBCPHTTPsService.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 18.08.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class BWRoasterDeviceBCPHTTPsService: BWRoasterDeviceHTTPsService, BWRoasterDeviceBCPService {
    
    static let TEMP_FACTOR = 0.5;
    
    // MARK: - BWRoasterDeviceService
    
    override class var name: String {
        return "BCP"
    }
    
    // MARK: - 
    
    struct RESTPaths {
        static let state                = "roaster/state"
        static let beanWeight           = "roaster/bean_weight"
        static let preheat              = "roaster/preheat"
        static let historySize          = "roaster/history_size"
        static let sensor               = "roaster/sensor"
        static let inputWeight          = "roaster/input_weight"
        static let hopperState          = "roaster/hopper"
        static let roastProfile         = "roaster/profile"
        static let roastProfileRecord   = "roaster/profile/%d"
//        static let refresh              = "roaster/refresh"   //unused at this time, but present in the http server
        static let firmware             = "roaster/version"
        static let getReadyToRoast      = "roaster/ready"

        static let roast                 = "roaster/roast"

        static func roastProfileRecord(at index: Int) -> String {
            return String(format: roastProfileRecord, index)
        }
    }
    
    struct JSONKeys {
        static let Weight       = "weight"
        static let Temperature  = "temp"
        static let State        = "state"        
    }
    
    // BCP weight units are 0.1 lbs in integer form, e.g. 1 for 0.1 lbs, 2 for 0.2 lbs, 10 for 1 lbs.
    private let wightConversionCoeficient = 10.0
    
    func getUpdating(completion: @escaping (Bool?)->()){
        guard let address = Roaster.shared.device?.localAddress else {return print("no-address")}

        Alamofire.request("https://\(address)/roaster/upgrading", method:.get, parameters:nil, encoding: JSONEncoding.default, headers:NetworkConfigurator.headers).responseJSON() {response in
            switch response.result {
            case .success(_):
                guard let dict = response.value as? [String: Any]
                    else {return completion(nil)}
                guard let values = dict["message"] as? [String: Any]
                    else {return completion(nil)}
                return completion(values["status"] as? Bool)
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    // MARK: - BWRoasterDeviceRoastService
    
    func serialNumber(completion: @escaping StringHandler) {
        RoasterCommander.shared.serialNumber(completion: completion)
    }

    func setState(_ state: BWRoasterDeviceRoastState, completion: @escaping BWRoasterDeviceBCPSetCompletion) {
        let requestData = [JSONKeys.State: state.rawValue]
        self.postRequest(RESTPaths.state, requestData: requestData as [String : AnyObject], completion: completion)

//        Roaster.shared.device?.bcpService.setState(state){[weak self] error in
//
//            //success, so return with nil error
//            if error == nil {return completion(error)}
//
//            //if we are not around, just pass on the error
//            guard let _self = self else {return completion(error)}
//
//            //backup mode
//            let requestData = [JSONKeys.State: state.rawValue]
//            _self.postRequest(RESTPaths.state, requestData: requestData as [String : AnyObject], completion: completion)
//
//        }
    }
    
    func setBeanWeight(_ weight: BWWeight, completion: @escaping BWRoasterDeviceBCPSetCompletion) {
        let weightRequestData = [JSONKeys.Weight: Int(round(weight * wightConversionCoeficient))]
        postRequest(RESTPaths.beanWeight, requestData: weightRequestData as [String : AnyObject], completion: completion)
    }
    
    func setPreheat(_ preheat: BWTemperature, completion: @escaping BWRoasterDeviceBCPSetCompletion) {
        let preheat = min(preheat, Roaster.MAX_PREHEAT)
        let requestData = [JSONKeys.Temperature: Int(round(preheat))]
        postRequest(RESTPaths.preheat, requestData: requestData as [String : AnyObject], completion: completion)
    }
    
    // MARK: -
    
    func getState(_ completion: @escaping BWRoasterDeviceBCPGetStateCompletion) {

        Roaster.shared.device?.bcpService.getState {[weak self] response, error in
            
            //if it worked, just go ahead and return response
            if let _ = response {return completion(response, error)}
            
            //ensure we are still in place, or just pass on the error
            guard let _self = self else {return completion(response, error)}
            
            //let's attempt to recover via an HTTP request
            _self.getRequest(RESTPaths.state) { (response, error) in
                guard error == nil else {return completion(nil, error)}
    
                guard let stateDoubleValue = response?.value as? Int,
                    let state = BWRoasterDeviceRoastState(rawValue: Int(stateDoubleValue)) else {
                        return completion(nil, NSError.bw_roasterError(.invalidServerResponse))
                }
    
                completion(state, nil)
            }
        }
    }
    
    func getBeanWeight(_ completion: @escaping BWRoasterDeviceBCPGetCompletion) {
        getRequest(RESTPaths.beanWeight) { [unowned self] (response, error) in
            var normalizedResponse = response
            if var value = response?.value as? Double {
                value = value / self.wightConversionCoeficient
                normalizedResponse?.value = value
            }
            completion(normalizedResponse, error)
        }
    }
    
    func getPreheat(_ completion: @escaping BWRoasterDeviceBCPGetCompletion) {
        getRequest(RESTPaths.preheat, completion: completion)
    }
    
    func getHistorySize(_ completion: @escaping BWRoasterDeviceBCPGetCompletion) {
        getRequest(RESTPaths.historySize, completion: completion)
    }
    
    private var tempUnit: Int {
        return Roaster.shared.isBeta ? 9 : 1
    }
    
    func getHopperState(_ completion: @escaping BooleanErrorHandler) {
        return self.getHopperStateHTTP(completion)
        
        //punt on the backup implementation; must be moved to own class in any case
//        Roaster.shared.device?.bcpService.getHopperState({[weak self] isInserted, error in
//
//            //if we are not around, return
//            guard let _self = self else {return completion(isInserted, error)}
//
//            if error == nil {
//                //if no error, return
//                return completion(isInserted, error)
//            } else {
//                //backup mode
//                return _self.getHopperStateHTTP(completion)
//            }
//        })
    }
    
    private func getHopperStateHTTP(_ completion: @escaping BooleanErrorHandler) {
        guard let address = Roaster.shared.device?.localAddress else {return print("no-address")}
        let path = "https://\(address)/\(RESTPaths.hopperState)"
        Alamofire.request(path, method:.get, parameters:nil, encoding: JSONEncoding.default, headers:NetworkConfigurator.headers).responseJSON() {
            response in
            switch response.result {
            case .success(let data):
                completion(JSON(data)["value"].intValue == 1, nil)
            case .failure(_):
                completion(nil, NSError.bw_roasterError(.invalidServerResponse))
            }
        }
    }

    func getInputWeight(_ completion: @escaping BWRoasterDeviceInputWeightCompletion) {
        guard let address = Roaster.shared.device?.localAddress else {return print("no-address")}
        let path = "https://\(address)/\(RESTPaths.inputWeight)"
        Alamofire.request(path, method:.get, parameters:nil, encoding: JSONEncoding.default, headers:NetworkConfigurator.headers).responseJSON() {
            response in
            switch response.result {
            case .success(let data):
                
                let vratio = JSON(data)["value"].doubleValue
                let weight = Roaster.weight_mult * vratio + Defaults.shared.tare
//                print("---weight: \(weight)")
//                print("weight: \(weight)")
                completion(vratio, weight, nil)
            case .failure(_):
                completion(nil, nil, NSError.bw_roasterError(.invalidServerResponse))
            }
        }
//        self.getWeightValue { [weak self] (response, error) in
//            guard let response = response, error == nil else {
//                return completion(nil, error)
//            }
//
//            guard let valuesDictionary = response.value as? [String: Any],
//                let inputWeight = valuesDictionary["value"] as? Double else {
//                    return completion(nil, NSError.bw_roasterError(.invalidServerResponse))
//            }
//
//            completion(inputWeight, nil)
//        }
    }
    

    func getDrumBottomTemperature(completion: @escaping BWRoasterDeviceBCPGetCompletion) {
        return self.getTemperature(unit: 6, completion: completion)
        
        //guard if the device is not there, and use HTTP instead
//        guard let device = Roaster.shared.device else { return getTemperature(unit: 6, completion: completion)}
//
//
//        device.bcpService.getDrumBottomTemperature {[weak self] response, error in
//
//            //if success, break out with it
//            if let response = response, error == nil {return completion(response, nil)}
//
//            //if this object is gone, break out with back we have
//            guard let _self = self else {return completion(response, nil)}
//
//            //backup mode
//            _self.getTemperature(unit: 6, completion: completion)
//        }
    }


    func getChamberTemperature(completion: @escaping BWRoasterDeviceBCPGetCompletion) {
        return getTemperature(unit: self.tempUnit, completion: completion)

        //guard if the device is not there, and use HTTP instead
//        guard let device = Roaster.shared.device else { return getTemperature(unit: tempUnit, completion: completion)}
//
//
//        device.bcpService.getDrumBottomTemperature {[weak self] response, error in
//
//            //if success, break out with it
//            if let response = response, error == nil {return completion(response, nil)}
//
//            //if this object is gone, break out with back we have
//            guard let _self = self else {return completion(response, nil)}
//
//            //backup mode
//            _self.getTemperature(unit: _self.tempUnit, completion: completion)
//        }
    }
    
    func getTemperature(unit: Int, completion: @escaping BWRoasterDeviceBCPGetCompletion) {
        getSensorValue(module: "TMP", unit: unit, command: "VAL") { [weak self] (response, error) in
            guard var response = response, error == nil else {
                completion(nil, error)
                return
            }
            
            guard let valuesDictionary = response.value as? [String: Any],
                let statusCodeString = valuesDictionary["p0"] as? String,
                let statusCodeInt = Int(statusCodeString),
                let statusCode = BWRoasterDeviceStatusCode(rawValue: statusCodeInt),
                let temperatureString = valuesDictionary["p1"] as? String,
                let temperature = Int(temperatureString) else {
                    completion(nil, NSError.bw_roasterError(.invalidServerResponse))
                    return
            }
            
            if statusCode != .ok {
                self?.logger?.error("Roaster error: \(statusCode)")
            }
            
            response.status = statusCode
            response.message = statusCode.stringValue
            response.value = BWTemperature(temperature.asDouble * BWRoasterDeviceBCPHTTPsService.TEMP_FACTOR)
            completion(response, nil)
        }
    }
    
    internal func getWeightValue(_ completion: @escaping BWRoasterDeviceBCPGetCompletion) {
        getRequest(RESTPaths.inputWeight, parameters: [:], encoding: .url, completion: completion)
    }

    
    func getSensorValue(module: String, unit: Int, command: String,
                                 _ completion: @escaping BWRoasterDeviceBCPGetCompletion) {
        let parameters: [String: Any] = [
            "m": module,
            "u": unit,
            "cmd": command,
            ]
        getRequest(RESTPaths.sensor, parameters: parameters, encoding: .url, completion: completion)
    }
    
    // MARK: -
    
    func set(roastProfileRecord step: BWRoastProfileStep,
             at index: Int,
             completion: @escaping BWRoasterDeviceBCPSetCompletion) {
        postRequest(RESTPaths.roastProfile,
                    requestData: RoastProfileRecord(step: step, index: index).mapToJSON(),
                    completion: completion)
    }
    
    func getRoastProfileRecord(at index: Int, completion: @escaping BWRoasterDeviceBCPGetRoastProfileStepCompletion) {
        getRequest(RESTPaths.roastProfileRecord(at: index)) { response, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            if let stepJSON = response?.value,
                let step = try? BWRoastProfileStep.mapFromJSON(stepJSON) {
                completion(step, nil)
            } else {
                completion(nil, NSError.bw_roasterError(.invalidServerResponse))
            }
        }
    }
    
    // MARK: - Private 
    
    fileprivate func postRequest(_ path: String,
                                 requestData: [String : Any],
                                 completion: @escaping BWRoasterDeviceBCPSetCompletion) {
        let start = Date()
        let networkDataProviderCompletion = { (JSON: AnyObject?, error: NSError?, response: HTTPURLResponse?) -> Void in
            
            var resultError: NSError? = nil
            
            if let error = self.responseErrorParser.parse(json: JSON, error: error, response: response) {
                resultError = error
            } else if let JSON = JSON, let parsedItem = try? BWRoasterDeviceRoastServiceResponse.mapFromJSON(JSON) {
                if parsedItem.status != .ok {
                    resultError = NSError.bw_roasterError(for: parsedItem.status, message: parsedItem.message)
                }
            } else {
                resultError = NSError.bw_roasterError(.invalidServerResponse)
            }
            
            if let resultError = resultError {
                self.logger?.error("\(#function) failure: \(resultError)")
            } else {
                self.logger?.debug("\(#function) success")
            }
            
            let timing = Date().timeIntervalSince(start)
            
            print("postRequest ------------------------ \(timing)")
            
            completion(resultError)
        }
        
        networkDataProvider.requestJSON(method: .post,
                                        relativePath: path,
                                        parameters: requestData,
                                        encoding: JSONEncoding.default,
                                        headers: nil,
                                        responseHandler: networkDataProviderCompletion)
    }
    
    fileprivate func getRequest(_ path: String,
                                parameters: [String : Any]? = nil,
                                encoding: ParameterEncoding = .json,
                                completion: @escaping BWRoasterDeviceBCPGetCompletion) {
        let networkDataProviderCompletion = { (JSON: AnyObject?, error: NSError?, response: HTTPURLResponse?) -> Void in
            
            var resultItem: BWRoasterDeviceRoastServiceResponse? = nil
            var resultError: NSError?
            
            if let error = self.responseErrorParser.parse(json: JSON, error: error, response: response) {
                resultError = error
            } else if let JSON = JSON, let parsedItem = try? BWRoasterDeviceRoastServiceResponse.mapFromJSON(JSON) {
                resultItem = parsedItem
                
                if parsedItem.status != .ok {
                    resultItem = nil
                    resultError = NSError.bw_roasterError(for: parsedItem.status, message: parsedItem.message)
                }
                
            } else {
                resultError = NSError.bw_roasterError(.invalidServerResponse)
            }
            
            if let resultError = resultError {
                self.logger?.error("\(#function) failure: \(resultError)")
            } else {
                self.logger?.debug("\(#function) success")
            }
            
            completion(resultItem, resultError)
        }
        
        networkDataProvider.requestJSON(method: .get,
                                        relativePath: path,
                                        parameters: parameters,
                                        encoding: (encoding == .json) ? JSONEncoding.default : URLEncoding.default,
                                        headers: nil,
                                        responseHandler: networkDataProviderCompletion)
    }    
    
    func getFirmwareVersion(_ completion: @escaping BWRoasterDeviceBCPGetFirmwareCompletion) {
        getRequest(RESTPaths.firmware) { (response, error) in
            guard let response = response, error == nil else {
                completion(nil, error)
                return
            }
            
            guard response.status == .ok else {
                let error = NSError.bw_roasterError(for: response.status, message: response.message)
                completion(nil, error)
                return
            }
            
            guard let value = response.value as? String else {
                let error = NSError.bw_roasterError(.invalidServerResponse)
                completion(nil, error)
                return
            }
            
            completion(value, nil)
        }
    }
    
    func checkIsReadyForRoast(_ completion: @escaping BWRoasterDeviceBCPGetCompletion) {
        getRequest(RESTPaths.getReadyToRoast, completion: completion)
    }
}


struct RoastProfileRecord: BWToJSONMappable {
    var step: BWRoastProfileStep
    var index: Int
    
    struct JSONKeys {
        static let index =          "index"
        static let time =           "time"
        static let temperature =    "temp"
    }
    
    static func mapToJSON(_ object: RoastProfileRecord) -> [String : Any] {
        let time = round(object.step.time) == 0 ? 1  : round(object.step.time)
        return [
            JSONKeys.index:         object.index,
            JSONKeys.time:          Int(time),
            JSONKeys.temperature:   Int(round(object.step.temperature)),
        ]
    }
}
