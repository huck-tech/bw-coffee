//
//  AppDelegate.swift
//  Bellwether Coffee
//
//  Created by Gabe The Coder on 12/5/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit
import Parse
import SwiftyBluetooth
import Braintree
import IQKeyboardManagerSwift
import mailgun
import Cloudinary
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var eventCounter = EventCounter()
    var mailgun: Mailgun?
    var cloudinary: CLDCloudinary?
    
    //offer access to the application delegate
    static var shared: AppDelegate? {return UIApplication.shared.delegate as? AppDelegate}
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        BuddyBuildSDK.setup()
        
        
        if appName.contains("Device Control") {
            //let the storyboard defined in the info.plist be presented
        } else if appName.contains("Tower") {
            
        } else {
            installRootViewController()
        }
        
        configureHeap()
        configureEnvironment()
        configureParse()
        configureBraintree()
        configureKeyboard()
        configureMailgun()
        configureCloudinary()
        configureOneSignal(launchOptions: launchOptions)
                
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        return true
    }
    
    private func configureOneSignal(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        // Replace 'YOUR_APP_ID' with your OneSignal App ID.
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "7cf34ef0-75f8-4c6a-9ea9-a78710e0515e",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
    }
    
    private func configureCloudinary(){
        let config = CLDConfiguration(cloudName: "bellwethercoffee",
                                                apiKey: "814772773377957",
                                                apiSecret: "oXs-YnJcWienQQwd7KRQoMQHGD8")
        self.cloudinary = CLDCloudinary(configuration: config)
    }
    
    private func configureMailgun(){
         mailgun = Mailgun.client(withDomain: "mg.visorlabs.com", apiKey: "key-2354dbb75f920616fe647ae6b224d153")
    }
    
    private func configureKeyboard(){
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    func installRootViewController(){
        let navController = NavigationController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }
    
    private var appName: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    }
    
    private func configureHeap() {
        //setup heap analytics
        Heap.setAppId("1518468243")
        #if DEBUG
            Heap.enableVisualizer()
        #endif

    }
    
    static private var configName: String {
        return Bundle.main.object(forInfoDictionaryKey: "Configuration") as? String ?? "Staging"
    }
    
    static var isProduction: Bool {
        return configName.contains("Production")
    }
    
    static var isSCAEnvironment: Bool { 
        return configName.contains("SCA")
    }
    
    static var roasterIPAddress: String {
        return isSCAEnvironment ? ipAddress : "34.199.57.65"
    }
    
    static var stagingHost: String {
        return "staging.bellwhether.co"
    }
    
    static var productionHost: String {
        return "prod.bellwhether.co"
    }
    
    static var ipAddress: String {
        return isSCAEnvironment ? "192.168.0.101" : stagingHost
    }
    
    private var configName: String { return AppDelegate.configName }
    private var ipAddress: String { return AppDelegate.ipAddress }
    
    public func configureParse() {
        Parse.initialize(with: AppDelegate.isSCAEnvironment ? self.scaParseConfig : self.parseConfig)
        PFUser.enableAutomaticUser()
        PFUser.enableRevocableSessionInBackground()
    }
    
    private func configureBraintree() {
        BTAppSwitch.setReturnURLScheme("com.bellwethercoffee.bwcoffee.payments")
    }
    
    func configureEnvironment() {
        
        if configName.contains("Debug") || configName.contains("Development") {
            let debugUrl = URL(string: "http://\(ipAddress):3000/api")
            SpeedyNetworking.setServerUrl(url: debugUrl)
            
            let stagingAppUrl = URL(string: "http://\(ipAddress):3000")
            SpeedyNetworking.setAppUrl(url: stagingAppUrl)
        }
        if configName.contains("Staging") {
            let stagingUrl = URL(string: "http://\(ipAddress):3001/api")
            SpeedyNetworking.setServerUrl(url: stagingUrl)
            
            let stagingAppUrl = URL(string: "http://\(ipAddress):3001")
            SpeedyNetworking.setAppUrl(url: stagingAppUrl)
        }
        
        if AppDelegate.isSCAEnvironment {
            let stagingUrl = URL(string: "http://\(ipAddress):3000/api")
            SpeedyNetworking.setServerUrl(url: stagingUrl)
            
            let stagingAppUrl = URL(string: "http://\(ipAddress):3000")
            SpeedyNetworking.setAppUrl(url: stagingAppUrl)
        }
        
        if configName.contains("Production") {
            let productionUrl = URL(string: "http://\(AppDelegate.productionHost):3000/api")
            SpeedyNetworking.setServerUrl(url: productionUrl)
            
            let productionAppUrl = URL(string: "http://\(AppDelegate.productionHost):3000")
            SpeedyNetworking.setAppUrl(url: productionAppUrl)
        }
    }
    
    //parse configuration
    let scaParseConfig = ParseClientConfiguration {config in
        config.applicationId = "zGAknV1IWqZ5QahPnDeXIhNlCwKXDSJYVnvJF7R2"
        config.clientKey = "nV7OVrakpPV73fxPaQRozGAknV1IWqZ5QahPnDeX"
        config.server = "http://\(AppDelegate.ipAddress):1337/parse"
    }
    
    let parseConfig = ParseClientConfiguration {config in
        config.applicationId = "XqJ3yxnl0nn4M548JCPJEpAD9tJSRPZjdaHjgVXf"
        config.clientKey = "wdZ3FZNZyrypfJsLKzBiwOaIFPhLl9fuT09SxIk3"
        config.server = "https://parseapi.back4app.com/"
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print(#function)
        if !SwiftyBluetooth.isScanning {
            //start discovering roasting devices
            RoasterBLEDeviceDatabase.shared.start()
        }
    }
}


extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
