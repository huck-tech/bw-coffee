//
//  Rates.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 8/17/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class Rates {
    
    func calculate(shippingInfo: String, completion: @escaping (Double?) -> Void) {
        SpeedyNetworking.get(route: "/rates/calculate/\(shippingInfo)") { response in
            guard response.success else { return completion(nil) }
            
            guard let result = response.jsonResults(model: [String: Any].self) else { return completion(nil) }
            
            let cost = result["shippingCost"] as? Double
            completion(cost)
        }
    }
    
}
