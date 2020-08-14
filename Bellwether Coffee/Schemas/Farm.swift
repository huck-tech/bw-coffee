//
//  Farm.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/3/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

struct Farm: Codable {
    let id: String?
    let producer: String?
    let name: String?
    let city: String?
    let country: String?
    let specificLocation: String?
    let photos: [String]?
}
