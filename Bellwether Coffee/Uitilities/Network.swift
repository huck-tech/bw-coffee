//
//  Network.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 7/30/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork

class Network {
    static let shared = Network()
    var ssid: String? {
        guard let interfaces:CFArray = CNCopySupportedInterfaces() else {return nil}
        
        for i in 0..<CFArrayGetCount(interfaces){
            let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interfaces, i)
            let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
            if let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString),
                let interfaceData = unsafeInterfaceData as? Dictionary<String, AnyObject>,
                let currentSSID = interfaceData["SSID"] as? String {
                return currentSSID
            }
        }
        
        return nil
    }
}
