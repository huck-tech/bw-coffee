//
//  CartItem.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/18/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

struct CartItem: Codable {
    let bean: Bean?
    let quantity: Int?
}
