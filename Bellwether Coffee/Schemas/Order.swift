//
//  Order.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/4/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

struct Order: Codable {
    let _id: String?

    let orderNumber: Int?
    let status: String?
    let items: [OrderItem]?
    let totalPrice: Double?
    let shipment: String?
    let paymentType: String?
    let paymentDescription: String?
    let createdBy: String?
    let createdDate: String?
}
