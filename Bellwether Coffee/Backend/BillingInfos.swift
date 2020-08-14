//
//  BillingInfos.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/31/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class BillingInfos {
    
    func getAvailable(completion: @escaping (([BillingInfo]?) -> Void)) {
        SpeedyNetworking.get(route: "/billings") { response in
            guard response.success else { return completion(nil) }
            
            let billingInfos = response.result(model: [BillingInfo].self)
            completion(billingInfos)
        }
    }
    
    func create(billingInfo: BillingInfo, completion: @escaping (Bool) -> Void) {
        SpeedyNetworking.post(route: "/billings/create", model: billingInfo) { response in
            completion(response.success)
        }
    }
    
    func edit(billingInfo: BillingInfo, completion: @escaping (Bool) -> Void) {
        guard let billingInfoId = billingInfo._id else { return completion(false) }
        
        SpeedyNetworking.post(route: "/billings/edit/\(billingInfoId)", model: billingInfo) { response in
            completion(response.success)
        }
    }
    
    func archive(billingInfo: BillingInfo, completion: @escaping (Bool) -> Void) {
        guard let billingInfoId = billingInfo._id else { return completion(false) }
        
        SpeedyNetworking.post(route: "/billings/archive/\(billingInfoId)", model: billingInfo) { response in
            completion(response.success)
        }
    }
    
}
