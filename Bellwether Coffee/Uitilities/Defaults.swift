//
//  Defaults.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 7/17/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class Defaults {
    static let shared = Defaults()
    
    static let DEFAULT_STAGING = "DEFAULT_STAGING"
    static let DEFAULT_ROASTER = "DEFAULT_ROASTER"
    static let DEFAULT_PREHEAT = "DEFAULT_PREHEAT"
    static let WEIGHT_TARE = "WEIGHT_TARE"
    static let AUTH_PIN = "AUTH_PIN"
    static let AUTH_CAFE = "AUTH_CAFE" // the cafe for the last email/pword login.
    static let AUTH_TOKEN = "AUTH_TOKEN"
    static let AUTH_LAST = "AUTH_LAST"//recall whether the user logged in with pin or password last time
    static let USER_INFO = "USER_INFO"

    let hardDefaultPreheat: BWTemperature = 177.0
    
    func clearDefaultRoaster() {
        UserDefaults.standard.removeObject(forKey: Defaults.DEFAULT_ROASTER)
        UserDefaults.standard.synchronize()
    }
    
    func set(cafe:String) {
        UserDefaults.standard.set(cafe, forKey: Defaults.AUTH_CAFE)
        UserDefaults.standard.synchronize()
    }
    
    var cafe: String? {
        return UserDefaults.standard.object(forKey: Defaults.AUTH_CAFE) as? String
    }
    
    func set(userInfo: [String:Any]){
        UserDefaults.standard.set(userInfo, forKey: Defaults.USER_INFO)
        UserDefaults.standard.synchronize()
    }
    
    var userInfo: [String:Any]? {
        return UserDefaults.standard.object(forKey: Defaults.USER_INFO) as? [String:Any]
        UserDefaults.standard.synchronize()
    }
    
    func set(usePin: Bool){
        UserDefaults.standard.set(usePin, forKey: Defaults.AUTH_LAST)
        UserDefaults.standard.synchronize()
    }
    
    var usePin: Bool {
        return UserDefaults.standard.bool(forKey: Defaults.AUTH_LAST)
    }
    
    func set(authToken: String){
        UserDefaults.standard.set(authToken, forKey: Defaults.AUTH_TOKEN)
        UserDefaults.standard.synchronize()
    }
    
    func set(stagingHost: String){
        UserDefaults.standard.set(stagingHost, forKey: Defaults.DEFAULT_STAGING)
        UserDefaults.standard.synchronize()
    }

    var stagingHost: String? {
        return UserDefaults.standard.object(forKey: Defaults.DEFAULT_STAGING) as? String
    }
    
    
    var authToken: String? {
        return UserDefaults.standard.object(forKey: Defaults.AUTH_TOKEN) as? String
    }
    
    func set(pin: String){
        UserDefaults.standard.set(pin, forKey: Defaults.AUTH_PIN)
    }
    
    var pin: String? {
        return UserDefaults.standard.object(forKey: Defaults.AUTH_PIN) as? String
    }
    func set(tare: Double) {
        UserDefaults.standard.set(tare, forKey: Defaults.WEIGHT_TARE)
    }
    
    var tare: Double {
        return UserDefaults.standard.object(forKey: Defaults.WEIGHT_TARE) as? Double ?? Roaster.weight_tare_default
    }
    
    func set(defaultRoaster: RoasterBLEDevice) {
        guard let roasterID = defaultRoaster.roasterID, let localAddress = defaultRoaster.localAddress, let password = defaultRoaster.password else {
            return
        }
        
        UserDefaults.standard.set(roasterID, forKey: Defaults.DEFAULT_ROASTER)
        UserDefaults.standard.set(localAddress, forKey: "_localAddress")
        UserDefaults.standard.set(password, forKey: "_readPassword")
        UserDefaults.standard.synchronize()
    }
    
    var defaultPreheat: BWTemperature {
        let preheat = UserDefaults.standard.double(forKey: Defaults.DEFAULT_PREHEAT)
        
        //if the value is 0.0, it has not been set so return the hard-wired value instead
        return preheat == 0.0 ? hardDefaultPreheat : preheat
    }
    
    var defaultRoaster: String? {
        return UserDefaults.standard.value(forKey: Defaults.DEFAULT_ROASTER) as? String
    }
    
    var defaultRoastProfile: RoastProfile {
        return Shared.roastProfile.asRoastProfile
    }
    
    var localAddress: String? {
        if let address = UserDefaults.standard.value(forKey: "_localAddress") as? String {
            return "\(address)"
        }
        
        return nil
    }
    
    var readPassword: String? {
        return UserDefaults.standard.value(forKey: "_readPassword") as? String
    }
}
