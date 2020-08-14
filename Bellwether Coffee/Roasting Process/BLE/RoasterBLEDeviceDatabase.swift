//
//  RoasterBLEDeviceDatabase.swift
//  Roaster
//
//  Created by Marcos Polanco on 3/2/18.
//  Copyright © 2018 Bellwether. All rights reserved.
//

import Foundation
import SwiftyBluetooth

class RoasterBLEDeviceDatabase {
    static let shared = RoasterBLEDeviceDatabase()
    
    let SCAN_TIMEOUT: TimeInterval = 15.0
    
    private var _devices = [String:RoasterBLEDevice]()
    
    public var delegate: RoasterBLEDeviceDatabaseDelegate?
    
    
    func startGladys() {
        guard BellwetherAPI.auth.isBellwetherUser else {return}

        let gladys = MockRoasterDevice(delegate: self)
        _devices["Gladys"] = gladys
    }
    
    public func remove(device name: String?) {
        guard let name = name else {return}
        _devices.removeValue(forKey: name)
    }

    
    /*  Return a list of the discovered BLE devices, sorted by name
     */
    public var devices: [RoasterBLEDevice] {
        return Array(_devices.values.sorted(by:{prev,next in prev.roasterID ?? "" < next.roasterID ?? ""}))
    }
    
    
    public func device(named: String) -> RoasterBLEDevice? {
        guard let result = _devices[named] else {return nil}
        
        //only return the device once it becomes available
        return result.isAvailable ? result : nil
    }
    
    private func bootConnect() {
        guard let roasterID = Defaults.shared.defaultRoaster, let localAddress = Defaults.shared.localAddress, let password = Defaults.shared.readPassword else {return}
    }
    
    public func start() {
        SwiftyBluetooth.scanForPeripherals(withServiceUUIDs: [RoasterBLEDevice.serviceUUID], options: nil, timeoutAfter: SCAN_TIMEOUT) {[weak self] result in
            guard let _self = self else {return}
            
            switch result {
            case .scanStarted:
                print(".scanStarted")
                break //do nothing
            case .scanResult(let peripheral, let advertisementData/*advertisementData*/, _/*RSSI*/):
                //we have a peripheral, place in our database,
                if let name = advertisementData["kCBAdvDataLocalName"] as? String {
//                    print("^^^^^^^^^ name:\(name)")
                    //create a device only if we have not seen it already
                    let current = _self._devices[name]
                    
                    //if we do not have the name or we have it but we don not have complete information
                    //then connect and retrieve the peripheral's characteristics
                    if current == nil || !(current!.isAvailable){
                        let device = RoasterBLEDevice.init(peripheral: peripheral, delegate: _self)
                        _self._devices[name] = device
                        device.connect(disconnect: true){
                            _self.delegate?.devicesDidChange()
                            _self.devicesDidChange()
                        }
                    } else if current?.state == .disconnected || current?.state == .connecting {
                        //we want to replace the peripheral with the newly discovered one
                        current?.peripheral = peripheral
                        current?.lastSeen = Date()
                    } else {
                        //update the device's last-seen date
                        current?.lastSeen = Date()
                    }
                }
            case .scanStopped( _/*error*/):                
                //scan again
                DispatchQueue.main.async {
                    self?.start()
                }
            }
        }
    }
    
    func autoconnect() {
        
        //if no default roaster is set, just connect to the first one we find.
        //this is better for production environments to ensure connection
        
        if Defaults.shared.defaultRoaster == nil, let roastingDevice = _devices.values.first {
            if Roaster.shared.connect(device: roastingDevice, port: roastingDevice.port){
                //if we connect, get out of here
                return roastingDevice.hold()
            }
        }
 
        
////        guard let roaster = Defaults.shared.defaultRoaster else {return}
////        print("trying to autoconnect to: \(roaster).")
        if let defaultRoasterID = Defaults.shared.defaultRoaster,
            let defaultRoaster = _devices[defaultRoasterID], defaultRoaster.autoreconnect, defaultRoaster.onNetwork {
            if Roaster.shared.connect(device: defaultRoaster, port:defaultRoaster.port) {
                defaultRoaster.hold()
            }
        } else {
            print("guard fail at \(#function)")
        }
    }
}

protocol RoasterBLEDeviceDatabaseDelegate {
    func devicesDidChange()
}

extension RoasterBLEDeviceDatabase: RoasterBLEDeviceDatabaseDelegate {
    func devicesDidChange() {
        self.autoconnect()
        self.delegate?.devicesDidChange()
    }
}
