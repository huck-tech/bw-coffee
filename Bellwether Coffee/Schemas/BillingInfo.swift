//
//  BillingInfo.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/3/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

struct BillingInfo: Codable {
    let _id: String?
    let firstName: String?
    let lastName: String?
    let company: String?
    let email: String?
    let phone: String?
    let address: String?
    let city: String?
    let state: String?
    let country: String?
    let postalCode: String?
    let isDefault: Bool?
}
