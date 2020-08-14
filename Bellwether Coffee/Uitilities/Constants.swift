//
//  Constants.swift
//  Bellwether Coffee
//
//  Created by Gabe The Coder on 12/11/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import UIKit

// MARK: Reuse Identifiers

let defaultHeaderId = "HeaderCell"
let defaultFooterId = "FooterCell"
let defaultCellId = "Cell"

// MARK: Profile Defaults

let defaultProfileInfo = SidebarProfileInfo(title: "Your Profile",
                                            subtitle: "Sign In",
                                            profilePhoto: nil,
                                            action: nil)

// MARK: Colors

struct BellwetherColor {
    
    static let primaryGreen = UIColor(red: 0.545, green: 0.725, blue: 0.678, alpha: 1.0)
    static let tipHeadline = UIColor(red: 0.698, green: 0.682, blue: 0.682, alpha: 1.0)
    static let darkBlue = UIColor(hue: 0.6, saturation: 0.33, brightness: 0.21, alpha: 1.0)
    static let lightBlue = UIColor(red: 0.956, green: 0.96, blue: 0.976, alpha: 1.0)
    static let gold = UIColor(red: 0.733, green: 0.682, blue: 0.572, alpha: 1.0)
    static let cardHeadline = UIColor(red: 0.321, green: 0.282, blue: 0.282, alpha: 1.0)
    static let roast = UIColor(red: 0.223, green: 0.2, blue: 0.2, alpha: 1.0)
    static let milk = UIColor(red: 0.929, green: 0.917, blue: 0.894, alpha: 1.0)
    static let red = UIColor(red: 0.937, green: 0.403, blue: 0.286, alpha: 1.0)
    
    static let roastOverlay = UIColor(red: 0.223, green: 0.2, blue: 0.2, alpha: 0.8)
    
}

// MARK: System Defaults

let ADMIN_EMAIL = "marcos@bellwethercoffee.com"
let ORDERS_EMAIL = "orders@bellwethercoffee.com"
