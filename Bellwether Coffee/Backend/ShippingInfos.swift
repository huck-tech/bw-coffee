//
//  ShippingInfos.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/30/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class ShippingInfos {
    
    func getAvailable(completion: @escaping (([ShippingInfo]?) -> Void)) {
        SpeedyNetworking.get(route: "/shippings") { response in
            guard response.success else { return completion(nil) }
            
            let shippingInfos = response.result(model: [ShippingInfo].self)
            completion(shippingInfos)
        }
    }
    
    func create(shippingInfo: ShippingInfo, completion: @escaping (Bool) -> Void) {
        SpeedyNetworking.post(route: "/shippings/create", model: shippingInfo) { response in
            completion(response.success)
        }
    }
    
    func edit(shippingInfo: ShippingInfo, completion: @escaping (Bool) -> Void) {
        guard let shippingInfoId = shippingInfo._id else { return completion(false) }
        
        SpeedyNetworking.post(route: "/shippings/edit/\(shippingInfoId)", model: shippingInfo) { response in
            completion(response.success)
        }
    }
    
    func archive(shippingInfo: ShippingInfo, completion: @escaping (Bool) -> Void) {
        guard let shippingInfoId = shippingInfo._id else { return completion(false) }
        
        SpeedyNetworking.post(route: "/shippings/archive/\(shippingInfoId)", model: shippingInfo) { response in
            completion(response.success)
        }
    }
    
}
