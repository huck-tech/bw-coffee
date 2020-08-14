//
//  GreenItem.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/6/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

struct GreenItem: Codable {
    let _id: String?
    let bean: String?       //
    let name: String?
    let quantity: Double?
    
    var _name: String? {return self.name?.corrected}
}


