//
//  RoastItem.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

struct RoastItem: Codable {
    let _id: String?
    private let beanName: String?
    let roastName: String?
    let roastedQuantity: Double?
    let stockQuantity: Double?

    var _beanName: String? {return self.beanName?.corrected}
}
