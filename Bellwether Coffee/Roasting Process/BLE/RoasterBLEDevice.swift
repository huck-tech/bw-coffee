//
//  RoasterBLEDevice.swift
//  Roaster
//
//  Created by Marcos Polanco on 3/2/18.
//  Copyright © 2018 Bellwether. All rights reserved.
//

import Foundation
import SwiftyBluetooth
import CoreBluetooth
import SwiftyJSON

typealias VoidHandler = () -> ()
typealias JSONHandler = (_ json:JSON?, _ error: NSError?) -> ()

class MockRoasterDevice: RoasterBLEDevice {
    var connected = false
    
    override var port: Int {
        guard let email = BellwetherAPI.auth.currentProfileInfo?.subtitle else {return 8443}
        
        let ports = [
            "nathan@bellwethercoffee.com" :     8440,//
            "kimberly@bellwethercoffee.com" :   8441,//
            "teresa@bellwethercoffee.com" :     8442,//
            "ricardo@bellwethercoffee.com" :    8444,
            "john@bellwethercoffee.com" :       8445,//
            "neil@bellwethercoffee.com" :       8446,//
            "bw9@bellwethercoffee.com" :        8447,//
            "g@bellwetthercoffee.com" :         8448,
            "marissa@bellwethercoffee.com" :    8449,//bw1
            "jeremiah@bellwethercoffee.com" :   8450,//bw2
            "greg@bellwethercoffee.com" :       8451,//bw3
            "peter@bellwethercoffee.com" :      8452,//bw4
            "bw5@bellwethercoffee.com" :        8453,//p2
            "bw6@bellwethercoffee.com" :        8454,
            "bw7@bellwethercoffee.com" :        8455,//arno
            "gabe@bellwethercoffee.com" :       8456,//bw8
            "marcos@bellwethercoffee.com" :     8456,//p1
            "katie@bellwethercoffee.com" :      8458 //
        ]
        
        return ports [email] ?? 8443
    }
    init(delegate:  RoasterBLEDeviceDatabaseDelegate) {
        super.init(peripheral: nil, delegate: delegate)
        
        self.values = [.roasterID: "Gladys",
                       .localAddress:"\(AppDelegate.roasterIPAddress):\(port)",
            .readPassword:""]
        
    }
    
    override var onNetwork: Bool {return true}
    override var seenRecently: Bool {return true}
    
    override var state: CBPeripheralState {
        return connected ? .connected : .disconnected
    }
    
    public override func connect(disconnect: Bool = false, completion: @escaping VoidHandler) {
        print("-----------------------------\(#function) for \(self.roasterID ?? "<noname roaster>")")
        connected = true
        completion()
    }
    
    public override func disconnect() {
        print("-----------------------------\(#function) for \(self.roasterID ?? "<noname roaster>")")
        connected = false
    }
    public override func hold(automatically: Bool = false) {connected = true}
    
    fileprivate override func read(uuid:CharacteristicUUID, completion: @escaping BoolHandler) {
        completion(true)
    }
    fileprivate override func load(completion: @escaping VoidHandler) {
        completion()
    }
    public override var localAddress: String? {
        return values[.localAddress]
    }
    
}

enum CharacteristicUUID: String {
    case roasterID        = "01C5B1B0-D3EB-49EF-9606-D88B5C63F86D" //tested
    case getInitStatus    = "85BB86FB-26A2-426A-B654-65E90AB12EDA"
    case setupWiFi        = "0447F164-D30D-41F4-AF20-BDB700A9992B"
    case readPassword     = "0EE51114-F495-4451-B35B-AD5D050325FC"
    case ssid             = "B24B52A1-9DDB-4CDC-8497-0BC20A15A697"
    case status           = "68C662F5-2206-4FC9-B6D0-E0B329F12B9D"
    case localAddress     = "385B377C-7098-4F22-92E6-0B2EF4002483"
    
    // roaster commands
    case reset =            "AFDDCC80-1EF0-4A35-8F98-ED3A139BB1E1"  //tested
    case readyToRoast =     "DF10962D-0151-4AD6-9C80-C7E13D788DBD"  //tested, actually via status
    case state =            "CE9AA815-DB7A-4891-96BF-DBCEB31EF9E4"  //tested, actually via status
    case commander =        "69511145-A207-4AFD-AF90-CF02BE0F7D40"
    case hopper =           "3FD784BB-039F-41DA-91DE-6C57648A0C3C"  //tested
    case profileRecord =    "93C4E624-EEF1-4428-9965-EFFD39CABCE7"  //tested

    case preheat =          "BD078654-C979-4EBF-8305-171341AA6EAA"  //tested
    case drumTemp =         "94C50B44-F289-437F-9273-C5088E92B962"  //tested, actually via status
    case chamberTemp =      "E47EADA3-37E3-47E4-88A6-59B8E567CB93"  //tested, actually via status
    case roastStatus =      "9D553A99-E61F-4CC4-AC14-DF85B5624243"  //tested!
    
    case serialNumber =     "C5CDA263-E8EB-4FBD-A051-CA95B6DE5C45"  //tested
    case firmwareVersion =  "FECA314F-BC10-495B-A4FD-1FFB655D923F"  //tested
    case coolTimeRemaining = "8DC020A5-89D6-4C93-A4FA-C11E97E99EBB" //tested
    case firmwareUpdating = "60F5B5D1-8E14-4F7F-8C7A-AD9134D0DEDC"

    var uuid: UUID {
        return UUID.init(uuidString: self.rawValue)!
    }
    
    static let all: [CharacteristicUUID] = [.roasterID, .getInitStatus, .setupWiFi,
                                            .readPassword, .ssid, .status, .localAddress]
}

class RoasterBLEDevice: NSObject {
    static let serviceUUID = UUID.init(uuidString: "DD613893-991A-4C4F-9115-709BF14A4FD7")!
    
    let CONNECT_TIMEOUT: TimeInterval = 5.0
    
    var peripheral: Peripheral! {
        didSet{
            bcpService.peripheral = peripheral
            print("replaced peripheral for \(peripheral.name ?? "-")")
        }
    }
    fileprivate let delegate: RoasterBLEDeviceDatabaseDelegate
    
    //mapping of characteristics to their current values
    fileprivate var values = [CharacteristicUUID:String]()
    
    var lastSeen = Date()
    
    var autoreconnect = true
    var bcpService: RoasterBLEBCPService
    var port: Int {
        return 8443
    }
    
    public func boot(roasterID: String, localAddress:String, password:String, delegate: RoasterBLEDeviceDatabaseDelegate) {
        self.values[.localAddress] = localAddress
        self.values[.readPassword] = password
        self.values[.roasterID] = roasterID
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public init(peripheral: Peripheral!, delegate: RoasterBLEDeviceDatabaseDelegate) {
        self.peripheral = peripheral
        self.delegate = delegate
        self.bcpService = RoasterBLEBCPService.init(peripheral: peripheral)
        
//        print("<<<<<<<<<<<<<<<<NotificationCenter.default.addObserver: \(peripheral)")
//
//        NotificationCenter.default.addObserver(forName: Peripheral.PeripheralCharacteristicValueUpdate, object: peripheral, queue: nil, using: {notification in
//
//            if UIApplication.shared.applicationState != .active {
//                print("poll: background")
//                Roaster.shared.httpsServicesFactory.roastController?.poll()
//            } else {print("--ignoring notification for \(peripheral.name ?? "peripheral.name == nil")")}
//
//        })
    }
    
    var ssid: String? {
        return values[.ssid]
    }
    
    var roasterID: String? {
        return values[.roasterID]
    }
    
    public var state: CBPeripheralState {
        return peripheral.state
    }
    
    public var localAddress: String? {
        guard let address = values[.localAddress] else {return nil}
        return address
    }
    
    
    public var password: String? {
        return values[.readPassword]
    }
    
    public var seenRecently: Bool {
        return Date().timeIntervalSince(lastSeen) < RoasterBLEDeviceDatabase.shared.SCAN_TIMEOUT
    }
    
    public var onNetwork: Bool {
        return true
        return self.ssid == Network.shared.ssid
    }
    
    //Devices are available if the roasterID, readPassword and localAddress are available
    public var isAvailable: Bool {
        guard let _ = values[.readPassword],
            let _ = values[.localAddress],
            let _ = values[.roasterID] else {return false}
        
        return true
    }
    
    public func select() -> Bool {
        
//        Defaults.shared.set(defaultRoaster: self)
//        RoasterBLEDeviceDatabase.shared.autoconnect()
//        NotificationCenter.default.post(name: .roasterStateUpdated, object: nil)
//        return true
        
        let currentDevice = Roaster.shared.device
        
        //release the old connection
        if currentDevice != self {
            currentDevice?.disconnect()
        } else {
            self.hold()
        }
        
        
        if let _ = self.roasterID, Roaster.shared.connect(device: self, port:port) {

            guard self.onNetwork else {
                return false
            }
            
            Defaults.shared.set(defaultRoaster: self)
            NotificationCenter.default.post(name: .roasterStateUpdated, object: nil)
            
            return true
        } else {
            print("---- roaster selection failed ----")
            return false
        }
        
    }
    
    public func connect(disconnect: Bool = false, completion: @escaping VoidHandler) {
        
        peripheral.connect(withTimeout: CONNECT_TIMEOUT, completion: {[weak self] result in
            switch result {
            case .success:
                self?.load(){
                    if disconnect {
                        self?.peripheral.disconnect {result in
//                            print("disconnect: \(result) for \(self?.roasterID ?? "<>")")
                        }
                    }
                    //this is called when the device becomes available
                    completion()
                }
            case .failure(let error):
                print("\(#function) error: \(error.localizedDescription)")
                //do nothing.
                completion()
            }
        })
    }
    
    public func disconnect() {
        self.autoreconnect = false //if we are getting the command to disconnect, it is intentional so do not autoreconnect
        peripheral.disconnect {result in
        }
    }
    
    public func hold(automatically: Bool = false) {
        if automatically && !autoreconnect {return print("do not autoreconnect automatically")}
        
        autoreconnect = true
        print("\(self.roasterID ?? "<unknown>")<<<<<<<<<<<<<< PRE HOLD STATE: \(peripheral.state.stringValue)")
        peripheral.connect(withTimeout: CONNECT_TIMEOUT) { (result) in
            print("\(self.roasterID ?? "<unknown>").............................>>....>RETURNED FROM peripheral.connect \(result.debugDescription)")
//            print("hold: \(result)") //there is no user-actionable error here
        }
    }
    
    /*
     If after five seconds we are still loading information, perhaps we never will find it all.
     Therefore, we disconnect the device
     */
    @objc func loadTimeout() {
        if isAvailable {
            
        } else {
//            print("loadTimeout for \(self.roasterID ?? "<>")")
            self.disconnect()
            RoasterBLEDeviceDatabase.shared.remove(device: self.roasterID)
        }
    }
    
    /*  Generate the pin code to extract password from Rpi https server
     */
    private func pin(_ id:String) -> String {
        return "1111"
    }

    fileprivate func load(completion: @escaping VoidHandler) {
        
        //we time out the load after five seconds
        self.perform(#selector(loadTimeout), with: nil, afterDelay: 8.0)
        
        //we read only once, so if we are available just report success
//        if self.isAvailable {return completion()}
        
//        self.peripheral.discoverCharacteristics(ofServiceWithUUID: RoasterBLEDevice.serviceUUID.uuidString) {[weak self] characteristics in
//            print("Discovery \(characteristics.value?.count ?? 0) characteristics for \(self?.peripheral.name ?? "-")")
//        }
       
         CharacteristicUUID.all.forEach{[weak self] uuid in
            guard let _self = self else {return}
            
            //in the case of reading the password, first write the pin code
            if uuid == CharacteristicUUID.readPassword {
//                guard let roasterID = roasterID else {return print("nil roasterID so cannot retrieve authentication password")}
                let data = "1111".data(using: String.Encoding.utf8)!
                peripheral.writeValue(ofCharacWithUUID: uuid.uuid, fromServiceWithUUID: RoasterBLEDevice.serviceUUID, value: data, completion: {result in
                    switch result {
                    case .success( _/*data*/):
                        _self.read(uuid: uuid) {_ in
                            if _self.isAvailable {
                                completion()
                            } else {
                                //                                print("--unread")
                            }
                        }
                    case .failure(_/*error*/):
                        //do nothing
                        break
                    }
                })
                
                
                
//                peripheral.setNotifyValue(toEnabled: true, forCharacWithUUID: uuid.rawValue, ofServiceWithUUID: RoasterBLEDevice.serviceUUID.uuidString, completion: {result in
//                    if UIApplication.shared.applicationState != .active {
//                        print("background poll")
//                        Roaster.shared.httpsServicesFactory.roastController?.poll()
//                    }
//                })

            } else {
//                if uuid == CharacteristicUUID.getState {
////                    peripheral.setNotifyValue(toEnabled: true, forCharacWithUUID: uuid.rawValue, ofServiceWithUUID: RoasterBLEDevice.serviceUUID.uuidString, completion: {result in
////                        print("setNotifyValue: \(result)")
////                    })
//                }
                _self.read(uuid: uuid){_ in
                    if _self.isAvailable {
                        completion()
                    } else {
                    }
                }
            }
        }
    }
    
    /*  Read the given characteristic for our peripheral and load it into our values
     */
    fileprivate func read(uuid:CharacteristicUUID, completion: @escaping BoolHandler) {
//        print("<<<<\(#function) uuid:\(uuid) for \(self.roasterID ?? "<roasterID>")")
        peripheral.readValue(ofCharacWithUUID: uuid.uuid,
                             fromServiceWithUUID: RoasterBLEDevice.serviceUUID) {result in
                                switch result {
                                case .success(let data):
                                    //parse and store the data
                                    self.values[uuid] = String(data: data, encoding: String.Encoding.utf8)
                                    print(">>>\(uuid.uuid):\(uuid): \(String(describing: self.values[uuid]))")
                                    completion(true)
                                case .failure(let error):
                                    //do nothing; just retain whatever data we have gathered to date
                                    print("!!!!\(uuid.uuid):\(uuid):\(error.localizedDescription)")
                                    completion(false)
                                }
        }
    }
}

extension CBPeripheralState: BWStringValueRepresentable {
    var stringValue: String {
        switch self {
        case .connected: return "connected"
        case .connecting: return "connecting"
        case .disconnected: return "disconnected"
        case .disconnecting: return "disconnecting"
        }
    }
}

extension StringProtocol {
    var ascii: [UInt32] {
        return unicodeScalars.filter{$0.isASCII}.map{$0.value}
    }
}
extension Character {
    var ascii: UInt32? {
        return String(self).unicodeScalars.filter{$0.isASCII}.first?.value
    }
}

extension String {
    var data: Data { return Data(utf8) }
}

extension Numeric {
    var data: Data {
        var source = self
        // This will return 1 byte for 8-bit, 2 bytes for 16-bit, 4 bytes for 32-bit and 8 bytes for 64-bit binary integers. For floating point types it will return 4 bytes for single-precision, 8 bytes for double-precision and 16 bytes for extended precision.
        return Data(bytes: &source, count: MemoryLayout<Self>.size)
    }
}

extension Data {
    var integer: Int {
        return withUnsafeBytes { $0.pointee }
    }
    var int32: Int32 {
        return withUnsafeBytes { $0.pointee }
    }
    var float: Float {
        return withUnsafeBytes { $0.pointee }
    }

    var double: Double {
        return withUnsafeBytes { $0.pointee }
    }
    var string: String {
        return String(data: self, encoding: .utf8) ?? ""
    }
}
