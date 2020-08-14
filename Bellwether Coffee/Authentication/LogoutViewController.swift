//
//  LogoutViewController.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 7/18/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class LogoutViewController: UIViewController {

    @objc func logout(){
        //blow out any existing authentication header
        SpeedyNetworking.setAuthHeader(authorization: "")
        
        UIView.animate(withDuration: 0.7, animations: {
            AppDelegate.navController?.view.alpha = 0.0
        }) {_ in

            //just rip out the existing view hierarchy and replace it wholesale
            DispatchQueue.main.async{AppDelegate.shared?.installRootViewController()}        }

    }
}
