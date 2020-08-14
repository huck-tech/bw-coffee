//
//  Bean.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 12/29/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import Foundation

struct Bean: Codable {
    let _id: String?
    let producer: String?
    let farm: String?
    let lot: String?
    let name: String?
    let price: Double?
    let amount: Double?
    let story: String?
    let highlight: String?
    let grower: String?
    let tastingNotes: String?
    let icoCode: String?
    let location: String?
    let roastProfiles: String?
    let certification: String?
    let photos: [String]?
    let cuppingNotes1: String?
    let cuppingNotes2: String?
    let cuppingNotes3: String?
    let variety: String?
    let process: String?
    let whyWeLoveIt: String?
    let elevation: String?
    let impact: String?
    let sku: String?

    var _name: String? {return self.name?.corrected}

    
    var readableCuppingNotes: String? {
        get {
            guard let name = name else {return nil}

            guard let cup1 = cuppingNotes1 else { return nil }
            guard let cup2 = cuppingNotes2 else { return nil }
            guard let cup3 = cuppingNotes3 else { return nil }
            
            return "\(cup1), \(cup2), \(cup3)"
        }
    }
}


extension String {
    var corrected: String? {
        return self.contains("Columbia") || self.contains("Colombia Cafe") ? "Colombia Cafe de Mujeres" : self
    }
}
