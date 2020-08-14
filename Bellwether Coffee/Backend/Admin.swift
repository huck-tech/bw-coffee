//
//  Admin.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/3/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class Admin {
    
    func createProducer(producer: Producer, completion: @escaping (String?) -> Void) {
        SpeedyNetworking.post(route: "/producers/create", model: producer) { response in
            guard response.success else { return completion(nil) }
            
            let producer = response.jsonResults(model: [String: Any].self)
            let producerId = producer?["producer"] as? String
            
            completion(producerId)
        }
    }
    
    func createFarm(farm: Farm, completion: @escaping (String?) -> Void) {
        SpeedyNetworking.post(route: "/farms/create", model: farm) { response in
            guard response.success else { return completion(nil) }
            
            let farm = response.jsonResults(model: [String: Any].self)
            let farmId = farm?["farm"] as? String
            
            completion(farmId)
        }
    }
    
    func createLot(lot: Lot, completion: @escaping (String?) -> Void) {
        SpeedyNetworking.post(route: "/lots/create", model: lot) { response in
            guard response.success else { return completion(nil) }
            
            let lot = response.jsonResults(model: [String: Any].self)
            let lotId = lot?["lot"] as? String
            
            completion(lotId)
        }
    }
    
    func createBean(bean: Bean, completion: @escaping (String?) -> Void) {
        SpeedyNetworking.post(route: "/beans/create", model: bean) { response in
            guard response.success else { return completion(nil) }
            
            let bean = response.jsonResults(model: [String: Any].self)
            let beanId = bean?["bean"] as? String
            
            completion(beanId)
        }
    }
    
}
