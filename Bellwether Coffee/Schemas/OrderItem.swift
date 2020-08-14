//
//  OrderItem.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/5/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

struct OrderItem: Codable {
    let _id: String?
    let bean: String?
    let name: String?
    let price: Double?
    let quantity: Double?
    let totalPrice: Double?
    
    var forEmail: String {
        return "name:\(String.describe(name)) - " +
            "\(String.describe(price?.description)) @ " +
            "\(String.describe(quantity?.description)) = " +
            "\(String.describe(totalPrice?.description))\n"
    }
}
