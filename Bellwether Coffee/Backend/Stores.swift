//
//  Stores.swift
//  api-playground
//
//  Created by Gabriel Pierannunzi on 3/2/18.
//  Copyright © 2018 Gabriel Pierannunzi. All rights reserved.
//

import Foundation

class Stores {
    
    func createStore(store: Store, completion: @escaping (Bool) -> Void) {
        SpeedyNetworking.post(route: "/stores/create", model: store) { response in
            completion(response.success)
        }
    }
    
}

