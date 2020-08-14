//
//  OnOrderItem.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/5/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

struct OnOrderItem: Codable {
    let order: String?
    let orderItem: String?
    let name: String?
    let quantity: Double?
    let orderNumber: Int?
    let status: String?
    let createdDate: String?
    
    var _name: String? {return self.name?.corrected}
}
