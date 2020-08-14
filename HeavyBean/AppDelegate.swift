//
//  AppDelegate.swift
//  HeavyBean
//
//  Created by Marcos Polanco on 5/4/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import mailgun

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mailgun: Mailgun?

    static var shared: AppDelegate? {return UIApplication.shared.delegate as? AppDelegate}


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        mailgun = Mailgun.client(withDomain: "mg.visorlabs.com", apiKey: "key-2354dbb75f920616fe647ae6b224d153")

        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true

        return true
    }
}

