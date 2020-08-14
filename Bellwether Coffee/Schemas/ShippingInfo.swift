//
//  ShippingInfo.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/31/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

struct ShippingInfo: Codable {
    let _id: String?
    let customerName: String?
    let company: String?
    let address: String?
    let city: String?
    let state: String?
    let postalCode: String?
    let phone: String?
    
    var forEmail: String {
        return "customerName:\(String.describe(customerName))\n" +
        "company:\(String.describe(company))\n" +
        "address:\(String.describe(address))\n" +
        "city\(String.describe(city)), " +
        "state:\(String.describe(state)) " +
        "postalCode:\(String.describe(postalCode))\n" +
        "phone:\(String.describe(phone))\n"
    }
}
