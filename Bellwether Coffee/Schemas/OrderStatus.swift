//
//  OrderStatus.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 7/13/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

enum OrderStatus: String {
    case carted = "carted"
    case ordered = "ordered"
    case readyToShip = "readyToShip"
    case inTransit = "inTransit"
    case delivered = "delivered"
    case cancelled = "cancelled"

    var translation: String {
        switch self {
        case .carted: return "Carted"
        case .ordered: return "Paid"
        case .readyToShip: return "Ready To Ship"
        case .inTransit: return "In Transit"
        case .delivered: return "Delivered"
        case .cancelled: return "Cancelled"
        }
    }
}
