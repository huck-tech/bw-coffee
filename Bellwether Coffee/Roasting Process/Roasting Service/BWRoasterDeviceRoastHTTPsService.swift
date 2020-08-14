//
//  BWRoasterDeviceRoastHTTPsService.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 19.10.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation


internal class BWRoasterDeviceRoastHTTPsService: BWRoasterDeviceService, BWRoasterDeviceRoastService {
    
    func getUpdating(completion: @escaping (Bool?)->()){
        bcpService.getUpdating(completion: completion)
    }
    
    func coolTimeRemaining(completion: @escaping DoubleHandler){
        RoasterCommander.shared.coolTimeRemaining(completion: completion)
    }
    
    func serialNumber(completion: @escaping StringHandler){
        bcpService.serialNumber(completion: completion)
    }
    func set(state: BWRoasterDeviceRoastState){
        bcpService.setState(state) {error in
            if let error = error {
                print("\(#function).\(error.localizedDescription)")
                
            }
        }
    }
    func getInputWeight(_ completion: @escaping BWRoasterDeviceInputWeightCompletion) {
        bcpService.getInputWeight(completion)
    }
    
    func getFirmwareVersion(_ completion: @escaping BWRoasterDeviceBCPGetFirmwareCompletion) {
        bcpService.getFirmwareVersion(completion)
    }
    
    func getHopperState(_ completion: @escaping BooleanErrorHandler) {
        bcpService.getHopperState(completion)
    }
    
    
    // MARK: - DI
    
    var bcpService: BWRoasterDeviceBCPService!

    // MARK: - BWRoasterDeviceHTTPsService

    class var name: String {
        return "Roast"
    }

    // MARK: - BWRoasterDeviceRoastService
    
    func preheatRoaster(to temperature: BWTemperature, completion: @escaping BWRoasterDeviceRoastServiceCompletion) {
        bcpService.setPreheat(temperature) { [weak self] error in
            guard error == nil else {
                return completion(error)
            }
            
            self?.bcpService.setState(.preheat, completion: completion)
        }
    }
    
    func upload(roastProfile: BWRoastProfile, beanWeight weight: BWWeight,
                completion: @escaping BWRoasterDeviceRoastServiceCompletion) {
        clearRoastProfile() { [weak self] error in
            guard error == nil else {
                return completion(error)
            }
            
            self?.upload(roastProfile: roastProfile) { [weak self] error in
                guard error == nil else {
                    return completion(error)
                }
                
                self?.bcpService.setBeanWeight(weight, completion: completion)
            }
        }

    }

    
    func forceDropBeans(completion: @escaping BWRoasterDeviceRoastServiceCompletion) {
        print("------------------------FORCED ROAST------------------------")
        bcpService.setState(.roast, completion: completion)
    }
    
    func getRoastStatus(_ completion: @escaping BWRoasterDeviceRoastStatusCompletion) {
        return self._getRoastStatus(completion)

//        
//        guard let device = Roaster.shared.device else { return _getRoastStatus(completion)}
//
//        device.bcpService.getRoastStatus {[weak self] status, error in
//            //if success, break out with it
//            if let status = status, error == nil {return completion(status, nil)}
//            
//            //if this object is gone, break out with back we have
//            guard let _self = self else {return completion(status, nil)}
//            
//            //backup mode
//            return _self._getRoastStatus(completion)
//        }
    }
    
    func _getRoastStatus(_ completion: @escaping BWRoasterDeviceRoastStatusCompletion) {
        let requestTime = Date()
        let roastStatus = BWRoasterDeviceRoastStatus.init(state: .shutdown, temperature: 0, drumpBottomTemp:0, timestamp: requestTime)
        
        let errorCompletion = { (error: NSError?) in
            completion(nil, error)
        }
        let start = Date()
        getState(roastStatus: roastStatus, errorCompletion: errorCompletion) { [weak self] (roastStatus) in
            self?.checkIsReadyForRoast(roastStatus: roastStatus, errorCompletion: errorCompletion) { [weak self] (roastStatus) in
                self?.getChamberTemperature(roastStatus: roastStatus, errorCompletion: errorCompletion) { [weak self] (roastStatus) in
                    self?.getDrumBottomTemperature(roastStatus: roastStatus, errorCompletion: errorCompletion, successCompletion: {(roastStatus) in
                        
                        
                        let timing = Date().timeIntervalSince(start)
                        
                        print("statusRequest ------------------------ \(timing)")
                        
                        completion(roastStatus, nil)
                    })
                }
            }
        }
    }
    
    func set(state: BWRoasterDeviceRoastState, completion: @escaping BWRoasterDeviceRoastServiceCompletion) {
        bcpService.setState(state, completion: completion)
    }
    
    func cancelCurrentRoast(completion: @escaping BWRoasterDeviceRoastServiceCompletion) {
    
        let state: BWRoasterDeviceRoastState = (Roaster.shared.state == .roast) ? .cool : .shutdown
        bcpService.setState(state, completion: completion)
    }
    
    internal func upload(roastProfile: BWRoastProfile, completion: @escaping BWRoasterDeviceRoastServiceCompletion) {
        
        print("Uploading step count: \(roastProfile.steps.count) of roast profile: \(roastProfile)")
        
        var uploadNextRecord: ((Int) -> Void)! = nil
            
        uploadNextRecord = { (recordIndex: Int) -> Void in
            let step = roastProfile.steps[recordIndex]
            self.bcpService.set(roastProfileRecord: step, at: recordIndex) { error in
                if error != nil || recordIndex == roastProfile.steps.count - 1 {
                    completion(error)
                } else {
                    Roaster.shared.getVector(index: recordIndex, completion: {values in
//                        guard let roasterVectorTemp = values?["temp"] as? Int,
//                            roasterVectorTemp == Int(step.temp) else {
//                            return completion(NSError.bw_awsErrorWithCode(.incorrectRoastProfileVector))
//                        }
//                        print("Uploading roast profile step (time: \(step.time), temp: \(step.temperature)) -> \("roasterVectorTemp") at index \(recordIndex)")
                        uploadNextRecord(recordIndex + 1)
                    })
                }
            }
        }
        
        uploadNextRecord(0) //key to demarcate the end of the roast profile
    }
    
    internal func clearRoastProfile(completion: @escaping BWRoasterDeviceRoastServiceCompletion) {
        
        var clearNextRecord: ((Int) -> Void)! = nil
        
        clearNextRecord = { (recordIndex: Int) -> Void in
            self.bcpService.getRoastProfileRecord(at: recordIndex) { step, error in
                if error != nil {
                    completion(error)
                } else if let step = step, step.time == 0, step.temperature == 0 {
                    completion(nil) //we have reached the zero records, so no need to continue
                } else {
                    self.bcpService.set(roastProfileRecord: BWRoastProfileStep.zero, at: recordIndex) { error in
                        if error != nil {
                            completion(error)
                        } else {
                            clearNextRecord(recordIndex + 1)
                        }
                    }
                }
            }
        }
        
        clearNextRecord(0)
    }
}
typealias ErrorCompletion = (NSError?) -> Void
typealias SuccessCompletion = (BWRoasterDeviceRoastStatus) -> Void


extension BWRoasterDeviceRoastHTTPsService {
    
    
    fileprivate func getState(roastStatus: BWRoasterDeviceRoastStatus,
                  errorCompletion: @escaping ErrorCompletion,
                  successCompletion: @escaping SuccessCompletion) {
        bcpService.getState() { (state, error) in
            guard error == nil else {
                errorCompletion(error)
                return
            }
            
            guard let state = state else {
                let error = NSError.bw_roasterError(.invalidServerResponse)
                errorCompletion(error)
                return
            }
            
            var newStatus = roastStatus
            newStatus.state = state
            successCompletion(newStatus)
        }
    }
    
    fileprivate func checkIsReadyForRoast(roastStatus: BWRoasterDeviceRoastStatus,
                                          errorCompletion: @escaping ErrorCompletion,
                                          successCompletion: @escaping SuccessCompletion) {
        bcpService.checkIsReadyForRoast() { (response, error) in
            guard error == nil else {
                errorCompletion(error)
                return
            }
            
            guard let response = response else {
                let error = NSError.bw_roasterError(.invalidServerResponse)
                errorCompletion(error)
                return
            }
            
            guard response.status == .ok else {
                let message = "\(response.status.rawValue) - \(response.status.stringValue) - \(response.message)"
                let error = NSError.bw_roasterError(.invalidSTMStatusCode, message: message)
                errorCompletion(error)
                return
            }
            
            let isReadyToRoast: Bool
            if let readyToRoast = response.value as? Bool {
                isReadyToRoast = readyToRoast
            } else if let readyToRoast = response.value as? Int {
                isReadyToRoast = readyToRoast != 0
            } else if let readyToRoast = response.value as? String {
                isReadyToRoast = readyToRoast == "YES"
            } else {
                let error = NSError.bw_roasterError(.invalidServerResponse,
                                                    message: "Could not parse isReadyForRoast response '\(String(describing: response.value))' as a bool value")
                errorCompletion(error)
                isReadyToRoast = false
            }
            
            var newStatus = roastStatus
            newStatus.isReadyToRoast = isReadyToRoast
            successCompletion(newStatus)
        }
    }
    
    fileprivate func getDrumBottomTemperature(roastStatus: BWRoasterDeviceRoastStatus,
                                           errorCompletion: @escaping ErrorCompletion,
                                           successCompletion: @escaping SuccessCompletion) {
        
        let completion: BWRoasterDeviceBCPGetCompletion = { (response, error) in
            guard error == nil else
            {return errorCompletion(error)}
            
            guard let response = response else {
                let error = NSError.bw_roasterError(.invalidServerResponse)
                errorCompletion(error)
                return
            }
            
            guard response.status == .ok else {
                let message = "\(response.status.rawValue) - \(response.status.stringValue) - \(response.message)"
                let error = NSError.bw_roasterError(.invalidSTMStatusCode, message: message)
                errorCompletion(error)
                return
            }
            
            guard let temperature = response.value as? BWTemperature else {
                let error = NSError.bw_roasterError(.invalidServerResponse,
                                                    message: "Could not parse roaster chamber temperature from \(String(describing: response.value))")
                errorCompletion(error)
                return
            }
            
            var newStatus = roastStatus
            newStatus.drumpBottomTemp = temperature
            successCompletion(newStatus)
        }
        
        
        bcpService.getDrumBottomTemperature(completion: completion)
    }
    
    fileprivate func getChamberTemperature(roastStatus: BWRoasterDeviceRoastStatus,
                                           errorCompletion: @escaping ErrorCompletion,
                                           successCompletion: @escaping SuccessCompletion) {
        
        let completion: BWRoasterDeviceBCPGetCompletion = { (response, error) in
            guard error == nil else
                {return errorCompletion(error)}
            
            guard let response = response else {
                let error = NSError.bw_roasterError(.invalidServerResponse)
                errorCompletion(error)
                return
            }
            
            guard response.status == .ok else {
                let message = "\(response.status.rawValue) - \(response.status.stringValue) - \(response.message)"
                let error = NSError.bw_roasterError(.invalidSTMStatusCode, message: message)
                errorCompletion(error)
                return
            }
            
            guard let temperature = response.value as? BWTemperature else {
                let error = NSError.bw_roasterError(.invalidServerResponse,
                                                    message: "Could not parse roaster chamber temperature from \(String(describing: response.value))")
                errorCompletion(error)
                return
            }
            
            var newStatus = roastStatus
            newStatus.temperature = temperature
            successCompletion(newStatus)
        }
        
        
        bcpService.getChamberTemperature(completion: completion) 
    }
}
