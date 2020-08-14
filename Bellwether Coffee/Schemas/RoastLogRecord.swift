//
//  RoastLogRecord.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/31/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

struct RoastLogRecord: Codable {
    let _id: String?
    let uuid: String?
    let machine: String?
    let roastStartTime: String?
    let roaster: String?
    let bean: String?
    let profile: String?
    let inputWeight: Double?
    let dropTime: Double?
    let outputWeight: Double?
    let measurements: String?
    let firmware: String?
    let comments: String?
    let favorite: Double?
}
