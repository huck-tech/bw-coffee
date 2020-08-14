//
//  Billings.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/3/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class Billings {
    
    func create(info: BillingInfo, completion: @escaping (Bool) -> Void) {
        SpeedyNetworking.post(route: "/billings/create", model: info) { response in
            completion(response.success)
        }
    }
    
    func fetchOptions(completion: @escaping ([BillingInfo]?) -> Void) {
        SpeedyNetworking.get(route: "/billings/options") { response in
            guard response.success else { return completion(nil) }
            
            let options = response.result(model: [BillingInfo].self)
            completion(options)
        }
    }
    
    func fetchDefault(completion: @escaping (BillingInfo?) -> Void) {
        SpeedyNetworking.get(route: "/billings/default") { response in
            guard response.success else { return completion(nil) }
            
            let defaultBillingInfo = response.result(model: BillingInfo.self)
            completion(defaultBillingInfo)
        }
    }
    
}
