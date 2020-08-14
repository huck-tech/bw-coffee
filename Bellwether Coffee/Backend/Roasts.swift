//
//  Roasts.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class Roasts {
    
    func getRoasts(completion: @escaping ([RoastItem]?) -> Void) {
        SpeedyNetworking.get(route: "/roasts") { response in
            guard response.success else { return completion(nil) }
            
            let roastItems = response.result(model: [RoastItem].self)
            completion(roastItems)
        }
    }
    
    func completeRoast(request: RoastRequest, completion: @escaping (Bool) -> Void) {
        SpeedyNetworking.post(route: "/roasts/complete", model: request) { response in
            completion(response.success)
        }
    }
    
    func update(quantity: Double, for roastItem: RoastItem, completion: @escaping (Bool) -> Void) {
        guard let id = roastItem._id else {return completion(false)}
        SpeedyNetworking.postData(route: "/roasts/updateQuantity/\(id)", data: ["roastedAmount": quantity]) {response in
            completion(response.success)
        }
    }
    
}
