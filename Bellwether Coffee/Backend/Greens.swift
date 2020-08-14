//
//  Greens.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/26/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class Greens {
    
    // TODO: Move logic relating to green inventory to this class. Currently much of it is in Orders.
    
    func updateGreenQuantity(green: GreenItem, quantity: Double, completion: @escaping (Bool) -> Void) {
        guard let greenId = green._id else { return completion(false) }
        
        let params: [String: Any] = ["quantity": quantity]
        
        SpeedyNetworking.postData(route: "/orders/green/updateQuantity/\(greenId)", data: params) { response in
            completion(response.success)
        }
    }
    
}
