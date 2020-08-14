//
//  SpeedyParams.swift
//  Networking
//
//  Created by Gabe The Coder on 10/2/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import Foundation

class SpeedyParams {
    
    var paramData: Data!
    
    init?(params: Any) {
        do {
            paramData = try JSONSerialization.data(withJSONObject: params)
        } catch {
            return nil
        }
    }
    
    init?<T: Encodable>(model: T, data: [String: Any]? = nil) {
        do {
            let jsonData = try JSONEncoder().encode(model)
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData)
            
            guard let additionalData = data else {
                paramData = jsonData
                return
            }
            
            guard let json = jsonObject as? [String: Any] else { return nil }
            guard let data = concatJsonData(a: json, b: additionalData) else { return nil }
            
            paramData = data
        } catch {
            return nil
        }
    }
    
    func concatJsonData(a: [String: Any], b: [String: Any]) -> Data? {
        var jsonObject = a
        
        for (key, value) in b {
            jsonObject[key] = value
        }
        
        do {
            return try JSONSerialization.data(withJSONObject: jsonObject)
        } catch {
            return nil
        }
    }
    
}

extension SpeedyParams {
    
    convenience init?(id: String) {
        self.init(params: ["id": id])
    }
    
}

//some commands take no parameters. This null parameters helper class can help present an empty model
class NullParams: Codable {}
