//
//  RoastRequest.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

struct RoastRequest: Codable {
    let green: String?
    let profile: String?
    let loadedQuantity: Double?
    let roastedQuantity: Double?
}
