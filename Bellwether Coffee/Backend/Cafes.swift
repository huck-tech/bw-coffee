//
//  Cafes.swift
//  api-playground
//
//  Created by Gabriel Pierannunzi on 3/2/18.
//  Copyright © 2018 Gabriel Pierannunzi. All rights reserved.
//

import Foundation

class Cafes {
    
    func createCafe(cafe: Cafe, completion: @escaping (Bool) -> Void) {
        SpeedyNetworking.post(route: "/cafes/create", model: cafe) { response in
            completion(response.success)
        }
    }
    
}
