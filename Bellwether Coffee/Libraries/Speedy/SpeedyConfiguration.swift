//
//  SpeedyConfiguration.swift
//  Networking
//
//  Created by Gabe The Coder on 10/2/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import Foundation

class SpeedyConfiguration {
    
    static let shared = SpeedyConfiguration()
    
    var defaultUrl: URL?
    var defaultAppUrl: URL?
    var defaultAuthorizationHeader: String?
    
}
