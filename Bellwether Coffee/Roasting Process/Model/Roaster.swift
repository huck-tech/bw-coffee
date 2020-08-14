//
//  Roaster.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 6/21/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import Alamofire

let unknown = "<unknown>"

enum ScaleState {
    case unstable
    case nonzero
    case tareable
}

class Roaster: NSObject {
    static let shared = Roaster()
    
    static let weight_mult:Double = -134046
    static let weight_tare_default: Double = 4.1211 + 4.27
    
    static let MAX_PREHEAT: Double = 450.0
    static let AMBIENT_TEMPERATURE: Double = 70
    static let CORE_TEMP_REQUIRED: Double = 375
    static let DEAD_SECONDS: TimeInterval = 2 * 60
    
        
    enum Notifications: String {
        case hopperChanged = "hopperChanged"
        case roasterStateUpdated = "roasterStateUpdated"
        case scaleAutoTared = "scaleAutoTared"
    }
    
    var device: RoasterBLEDevice?
    var delegate: RoasterDelegate?
    var isBeta: Bool = false
    var debug: String?
    
    //all three are necessary for the roast to actually start
    var shouldPreheat: Bool = false
    var temperature: Double = 0.0
    var pseudo: BWTemperature = 0.0
    
    //data on the current roaster
    var firmwareVersion:String?
    var serialNumber: String? {
        didSet{
            if let serialNumber = serialNumber {
                print("serialNumber: -------------------- \(serialNumber) ------------------------------")
                //refresh the statistics on this roaster
                MaintenanceEvent.loadRoasterInfo()
            } else {print("serialNumber: -------------------- NIL ------------------------------")}
        }
    }
    
    var coreTemperature: Double = 0.0
    var longInputWeightAvg: Double = 0.0
    var shortInputWeightAvg: Double = 0.0
    var autoTareRange: Double = 0.2
    
    let httpsServicesFactory = BWRoasterDeviceHTTPSServicesFactory()
    
    public var state: BWRoasterDeviceRoastState = .reset
    
    var notes: String {
        var notes: String = "Timestamp: \(Date().string())\n"
        notes += " Roaster: \(Roaster.shared.device?.roasterID ?? unknown)\n"
        notes += "   State: \(Roaster.shared.state.stringValue)\n"
        notes += "Software: \(Bundle.main.buildVersionNumber ?? unknown)\n"
        notes += "Firmware: \(Roaster.shared.firmwareVersion ?? unknown)\n"
        notes += "Operator: \(BellwetherAPI.auth.currentProfileInfo?.title ?? unknown)\n"
        
        return notes
    }
    
    public func preheat(completion: BWRoasterDeviceRoastServiceCompletion? = nil) {
        RoastEvent.log(state: BWRoasterDeviceRoastState.preheat)
        self.httpsServicesFactory.roastController?.preheatRoaster(temperature:nil){error in
            completion?(error)
        }
    }
    
    public var isMock: Bool {
        return (self.device as? MockRoasterDevice) != nil
    }
    
    public func tare(){
        //we need to generate a voltage ratio to use based on the shortInputWeightAvg
        let voltage: Double = (shortInputWeightAvg - Defaults.shared.tare) / Roaster.weight_mult
        
        //we reverse the equation to then set the tare accordingly, solving around zero
        Defaults.shared.set(tare: 0.0 - (Roaster.weight_mult * voltage))

    }
    
    private func autotare(vratio: Double, weight: Double){
        let short_div = 10.0    //10 readings
        let long_div = 40.0     //40 readings
        
        //calculate new moving averages over the given number of readings
        self.shortInputWeightAvg += (weight - self.shortInputWeightAvg) / short_div
        self.longInputWeightAvg += (weight - self.longInputWeightAvg) / long_div
        
        //are we near zero? That' what we are looking to tare
        guard abs(weight) < 0.1 else {
            return NotificationCenter.default.post(name: .scaleAutoTared, object: ScaleState.nonzero)
        }
        
        //is nothing happening? this is true if there is little different between long and short
        guard abs(shortInputWeightAvg - longInputWeightAvg) < 0.1 else {
            return NotificationCenter.default.post(name: .scaleAutoTared, object: ScaleState.unstable)
        }
        
        NotificationCenter.default.post(name: .scaleAutoTared, object: ScaleState.tareable)

        self.tare()
    }
    
    
    func getInputWeight(_ completion: @escaping BWRoasterDeviceInputWeightCompletion) {
        httpsServicesFactory.roastController?.getInputWeight {[weak self] vratio, weight, error in
            if let vratio = vratio, let weight = weight {
                DispatchQueue.main.async{[weak self] in self?.autotare(vratio: vratio, weight: weight)}
            }
            
            completion(vratio, weight, error)
        }
    }
    
    public var isReadyForNewRoast: Bool {
        //we can start a new roast if we are not roasting or cooling
        return self.state != .roast && self.state != .cool
    }
    
    //reflects whether we are successfully polling on HTTP
    public var isAvailable: Bool {
        guard let lastSuccess = self.httpsServicesFactory.roastController?.lastSuccess else
        {return false}
        
        return lastSuccess.timeIntervalSinceNow > Roaster.DEAD_SECONDS
    }
    
    //reflects whether we are connected on BLE. Used to allow roasting to proceed and to reconnect if hold is lost
    public var isConnected: Bool {
        
        //if no device, we cannot be connected
        guard let device = device else {return false}
        
        guard device.onNetwork else {return false}
        
        //ok, we are connected if BLE says we are
        return device.state == .connected || device.state == .connecting
    }
    
    public func roast(completion: @escaping ErrorHandler) {
        self.httpsServicesFactory.roastController?.forceDropBeans {error in
            print("forceDropBeans worked?:\(error == nil)")
            completion(error)
        }
    }
    
    public func start() {
        RoastingProcess.roasting.state = .started
        
        let beanId = RoastingProcess.roasting.greenItem?._id ?? "<>"
        let beanWeight = RoastingProcess.roasting.inputWeight ?? 6.0
        if let roastController = Roaster.shared.httpsServicesFactory.roastController {
                let roastProfile = RoastingProcess.roasting.roastProfile?.curvedRoastProfile()
                roastController.startRoast(for: beanId, with: beanWeight, using: roastProfile ?? Mujeres.roastProfile)
        }
    }
    
    func shutdown(completion: ErrorHandler? = nil) {
        RoastEvent.log(state: .shutdown)
        self.httpsServicesFactory.roastController?.cancelCurrentRoast {error in
            print("\(#function).\(error?.localizedDescription)")
            completion?(error)
        }
    }
    
    func connect(device:RoasterBLEDevice, port:Int) -> Bool {
        guard let hostname = device.localAddress?.components(separatedBy: ":").first,
            let password = device.password else {return false}
        
        self.device = device
        
        let configurator = NetworkConfigurator(hostname: hostname,
                                               password: password)
        self.httpsServicesFactory.networkConfigurationProvider = configurator
        let deviceInfo = BWRoasterDeviceInfo(id: "-", name: "--")
        
        
        self.httpsServicesFactory.roastController?.stopPolling()
        
        let _ = self.httpsServicesFactory.createServices(for: deviceInfo, port: port)
        
        self.httpsServicesFactory.roastController?.startPolling()
        self.httpsServicesFactory.roastController?.delegate = self
        
        self.updateRoasterInfo()
        
        return true
    }
    
    /*  Poll every five seconds to obtain the firmware version, until the value is captured
     */
    @objc private func updateRoasterInfo(){
        Roaster.shared.refreshFirmwareVersion(){[weak self] in
            guard let _self = self else {return}
            if _self.firmwareVersion == nil || self?.serialNumber == nil {
                _self.perform(#selector(_self.updateRoasterInfo), with: nil, afterDelay: 5)
            }
        }
        
        self.refreshSerialNumber()
    }
    
    private func refreshSerialNumber(){
        Roaster.shared.httpsServicesFactory.roastController?.serialNumber {[weak self] number in
            Roaster.shared.serialNumber = number
        }
    }
    
    func refreshFirmwareVersion(completion: VoidHandler? = nil) {
        self.httpsServicesFactory.roastController?.getFirmwareVersion({version, error in
            self.firmwareVersion = version
            completion?()
        })
        
    }
    
    func getProfile(index:Int = 0, input:[(Int,Int)]? = nil, completion:@escaping ([(Int,Int)]?) -> ()) {
        var output: [(Int,Int)] = input ?? [(Int,Int)]()
        getVector(index: index) {[weak self] result in
            guard let result = result else {return completion(output)} //we are done
            if result["time"] as? Int == 0 {return completion(output)} //we are done
            
            let temp: Int = Int((result["temp"] as! Int) * 1)
            output.append((result["time"] as! Int,temp))
            self?.getProfile(index: index + 1, input: output, completion: completion)
        }
    }
    
    func updateFirmware(completion: @escaping (Bool)->()) {
        guard let address = self.device?.localAddress else {return print("device?.localAddress == nil")}
        
        Alamofire.request("https://\(address)/roaster/upgrade", method:.post, parameters:nil, encoding: JSONEncoding.default, headers:NetworkConfigurator.headers).responseJSON() {response in
            switch response.result {
            case .success(_):
                return completion(true)
            case .failure(_):
                return completion(false)
            }
        }
    }

    
    func getVector(index: Int, completion: @escaping ([String: Any]?)->()) {
        guard let address = self.device?.localAddress else {return print("device?.localAddress == nil")}
        
        Alamofire.request("https://\(address)/roaster/profile/\(index)", method:.get, parameters:nil, encoding: JSONEncoding.default, headers:NetworkConfigurator.headers).responseJSON() {response in
            switch response.result {
            case .success(_):
                guard let valuesDictionary = response.value as? [String: Any]
                    else {return completion(nil)}
                return completion(valuesDictionary["value"] as? [String: Any])
            case .failure(_):
                completion(nil)
            }
        }
    }

    
    func hardReset(completion: BoolHandler? = nil) {
        
        self.device?.bcpService.hardReset(completion: {[weak self] success in
            if success {
                completion?(success)
            } else if let _self = self {
                //backup mode
                _self._hardReset(completion: completion)
            } else {
                completion?(success)
            }
        })
    }
    
    func _hardReset(completion: BoolHandler? = nil) {
        guard let address = self.device?.localAddress else {return print("device?.localAddress == nil")}
        
        Alamofire.request("https://\(address)/roaster/reset", method:.post, parameters:nil, encoding: JSONEncoding.default, headers:NetworkConfigurator.headers).responseJSON() {[weak self] response in
            switch response.result {
            case .success(_):
                completion?(true)
            case .failure(_):
                completion?(false)
            }
        }
    }
    
    func reset() {
        if shouldPreheat {
//            self.preheat() // removed for Gladys @ SCA
        }
        hopperInserted = false
    }

    var firmwareUpdating: Bool = false
//    {
//        didSet{print("Roaster.shared.isUpgrading = \(firmwareUpdating)")}
//    }
    var hopperInserted: Bool = false {
        didSet {
//            print("hopperInserted: \(hopperInserted)")

            if oldValue != hopperInserted {
                Roaster.shared.delegate?.hopperChanged(inserted: hopperInserted)
                NotificationCenter.default.post(name: .hopperChanged, object: nil)
            }
        }
    }
}
