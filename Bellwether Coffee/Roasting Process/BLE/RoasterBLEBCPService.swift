//
//  RoasterBLEBCPService.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 10/20/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import SwiftyBluetooth
import CoreBluetooth
import SwiftyJSON

extension RoasterBLEBCPService: BWRoasterDeviceRoastService {
    
    func getUpdating(completion: @escaping (Bool?)->()){
        self.read(uuid: CharacteristicUUID.firmwareUpdating) {json, error in
            completion(json?["status"].bool)
        }
    }
    
    func coolTimeRemaining(completion: @escaping DoubleHandler){
        self.read(uuid: CharacteristicUUID.coolTimeRemaining) {json, _ in
            completion(json?["value"]["p0"].doubleValue)
        }
    }
    
    func set(state: BWRoasterDeviceRoastState){
        self.setState(state) {_ in}
    }
    
    func preheatRoaster(to temperature: BWTemperature, completion: @escaping BWRoasterDeviceRoastServiceCompletion){
        self.setPreheat(temperature) { [weak self] error in
            guard error == nil else {return completion(error)}
            self?.setState(.preheat, completion: completion)
        }
    }
    
    func upload(roastProfile: BWRoastProfile, beanWeight weight: BWWeight, completion: @escaping BWRoasterDeviceRoastServiceCompletion) {
        
        print("Uploading step count: \(roastProfile.steps.count) of roast profile: \(roastProfile)")
        
        var uploadNextRecord: ((Int) -> Void)! = nil
        uploadNextRecord = { (recordIndex: Int) -> Void in
            let step = roastProfile.steps[recordIndex]
            self.set(roastProfileRecord: step, at: recordIndex) { error in
                if error != nil || recordIndex == roastProfile.steps.count - 1 {
                    completion(error)
                } else {
                    uploadNextRecord(recordIndex + 1)
                }
            }
        }
        
        uploadNextRecord(0) //key to demarcate the end of the roast profile
    }

    
    func forceDropBeans(completion: @escaping BWRoasterDeviceRoastServiceCompletion){
        self.setState(.roast, completion: completion)
    }
    
    func getRoastStatus(_ completion: @escaping BWRoasterDeviceRoastStatusCompletion) {
        self.read(uuid: .roastStatus) {dict, error in
            guard let json = dict else {return completion(nil, error)}
            
            let state = BWRoasterDeviceRoastState.init(rawValue: json["s"].intValue) ?? BWRoasterDeviceRoastState.error
            let drumTemp = json["d"].doubleValue  * BWRoasterDeviceBCPHTTPsService.TEMP_FACTOR
            let airTemp = json["a"].doubleValue  * BWRoasterDeviceBCPHTTPsService.TEMP_FACTOR
            let readyToRoast = json["r"].boolValue
            Roaster.shared.hopperInserted = json["h"].boolValue
            
            let roastStatus = BWRoasterDeviceRoastStatus.init(state: state, temperature: airTemp, drumpBottomTemp:drumTemp, timestamp: Date(), isReadyToRoast: readyToRoast)
            completion(roastStatus,  nil)
        }
    }
    
    
    func cancelCurrentRoast(completion: @escaping BWRoasterDeviceRoastServiceCompletion){
        let state: BWRoasterDeviceRoastState = (Roaster.shared.state == .roast) ? .cool : .shutdown
        self.setState(state, completion: completion)
    }
}

enum RoasterUpdateStatus: Int {
    case none = 0
    case pending = 1
    case updating = 2
}

class RoasterBLEBCPService: BWRoasterDeviceBCPService {

    static var name: String {
        return "BLE BCP Service"
    }    
    var peripheral: Peripheral!
    
    init (peripheral: Peripheral) {
        self.peripheral = peripheral
    }
    
    func readCommand(completion: @escaping ResponseHandler){
        self.read(uuid: .commander) {dict, error in
            completion(dict?.dictionaryObject)
        }
    }
    
    func process(module: String, command:String, unit:Int, completion: @escaping ResponseHandler){
        let value = JSON.init(["m":module, "c":command,"u":unit.description]).description
        self.write(uuid: CharacteristicUUID.commander.uuid, value: value){error in
            completion([:])
        }
    }
    
    func serialNumber(completion: @escaping StringHandler) {
        self.read(uuid: .serialNumber) {dict, error in
            completion(dict?["value"].dictionaryObject? ["p0"] as? String)
        }
    }

    //punt until we move out of 6lb roasts
    func setBeanWeight(_ weight: BWWeight, completion: @escaping BWRoasterDeviceBCPSetCompletion) {
        return completion(nil)
    }
    
//    func setUpdateS
    
    func getUpdateStatus(completion: @escaping IntErrorHandler) {
        return completion(nil, nil)
    }
    
    
    
    func setPreheat(_ preheat: BWTemperature, completion: @escaping BWRoasterDeviceBCPSetCompletion) {
        let preheat = min(preheat, Roaster.MAX_PREHEAT)
        self.write(uuid: CharacteristicUUID.preheat.uuid, value: preheat.asInt.description, completion: completion)
    }
    
    //punt until we move out of 6lb roasts
    func getBeanWeight(_ completion: @escaping BWRoasterDeviceBCPGetCompletion) {
        return completion(BWRoasterDeviceRoastServiceResponse.okResponse(value: 6), nil)
    }
    
    //put...no one calls this
    func getPreheat(_ completion: @escaping BWRoasterDeviceBCPGetCompletion) {
        fatalError()
    }
    
    //this is fixed and unlikely to change, so the hardcode is fine
    func getHistorySize(_ completion: @escaping BWRoasterDeviceBCPGetCompletion) {
        return completion(BWRoasterDeviceRoastServiceResponse.okResponse(value: 100), nil)
    }
    
    func getInputWeight(_ completion: @escaping BWRoasterDeviceInputWeightCompletion) {
        return completion(nil, 6.0, nil)
    }
    
    func set(roastProfileRecord step: BWRoastProfileStep, at index: Int, completion: @escaping BWRoasterDeviceBCPSetCompletion) {
        let dict = RoastProfileRecord(step: step, index: index).mapToJSON()
        var value = JSON.init(dict).description
        self.write(uuid: CharacteristicUUID.profileRecord.uuid, value: value, completion: completion)
    }
    
    //punt; we upload the entire 100 records, so no need to fetch and clear
    func getRoastProfileRecord(at index: Int, completion: @escaping BWRoasterDeviceBCPGetRoastProfileStepCompletion) {
        fatalError()
    }
    
    func getFirmwareVersion(_ completion: @escaping BWRoasterDeviceBCPGetFirmwareCompletion) {
        self.read(uuid: .firmwareVersion) {json, error in
            guard let json = json else {return completion(nil, error)}
            guard let value = json["value"]["p0"].string else {return completion(nil,  NSError.bw_roasterError(.invalidServerResponse))}
            completion(value, nil)
        }
    }
    
    //punt; not called in BLE
    func checkIsReadyForRoast(_ completion: @escaping BWRoasterDeviceBCPGetCompletion) {
        fatalError()
    }
    
    
    private func read(uuid: CharacteristicUUID, completion: @escaping JSONHandler) {
//        print("reading from \(peripheral.name ?? "") \(uuid.rawValue) in state \(peripheral.state.stringValue)")
        peripheral.readValue(ofCharacWithUUID: uuid.uuid,
                             fromServiceWithUUID: RoasterBLEDevice.serviceUUID){result in
                                switch result {
                                case .success(let data):
                                    if let json = String(data: data, encoding: String.Encoding.utf8) {
                                        return completion(JSON.init(parseJSON: json), nil)
                                    }
                                    completion(nil, NSError.bw_roasterError(.invalidServerResponse))
                                case .failure(let error):
                                    print(error.localizedDescription)
                                    completion(nil, NSError.bw_roasterError(.invalidServerResponse))
                                }
        }
    }
    
    func getHopperState(_ completion: @escaping BooleanErrorHandler) {
        
        //we skip fetching this ourselves, since getRoastStatus does it in a bundle
        return completion(Roaster.shared.hopperInserted, nil)
        
//        self.read(uuid: .hopper) {json, error in
//            guard let json = json else {return completion(nil, error)}
//        }
    }
    
    //punt; not called in BLE
    func getChamberTemperature(completion: @escaping BWRoasterDeviceBCPGetCompletion) {
        fatalError()
        self.read(uuid: .chamberTemp) {json, error in
            guard let json = json else {return completion(nil, error)}
            print("\(#function).\(json)")
        }
    }
    
    //punt; not called in BLE
    func getDrumBottomTemperature(completion: @escaping BWRoasterDeviceBCPGetCompletion) {
        fatalError()
        self.read(uuid: .drumTemp) {json, error in
            guard let json = json else {return completion(nil, error)}
            print("\(#function).\(json)")
        }
    }
    
    func getState(_ completion: @escaping BWRoasterDeviceBCPGetStateCompletion){
        self.read(uuid: .state) {json, error in
            guard let json = json else {return completion(nil, error)}
            
            //            print("\(json["value"]["p0"].intValue) json[\"p0\"].intValue\(json)")
            completion(BWRoasterDeviceRoastState.init(rawValue: json["value"]["p0"].intValue), nil)
        }
    }
    
    //punt; BLE does not call this
    func getReadyToRoast(_ completion: @escaping BWRoasterDeviceBCPGetCompletion) {
        fatalError()
        self.read(uuid: .readyToRoast) {json, error in
            guard let json = json else {return completion(nil, error)}
            print("\(#function).\(json)")
        }
    }
    
    private func write(uuid: UUID, value: String, completion: @escaping BWRoasterDeviceBCPSetCompletion){
        peripheral.writeValue(ofCharacWithUUID: uuid, fromServiceWithUUID: RoasterBLEDevice.serviceUUID, value: value.data(using: String.Encoding.utf8)!) {result in
            switch result {
            case .success():
                completion(nil)
            case .failure:
                completion(NSError.bw_roasterError(.invalidServerResponse))
            }
        }
    }
    
    func setState(_ state: BWRoasterDeviceRoastState, completion: @escaping BWRoasterDeviceBCPSetCompletion) {
        self.write(uuid: CharacteristicUUID.state.uuid, value: state.rawValue.description, completion: completion)
    }
    
    func hardReset(completion: BoolHandler? = nil){
        self.write(uuid: CharacteristicUUID.reset.uuid, value: ""){result in
            completion?(result == nil)
        }
    }
}
