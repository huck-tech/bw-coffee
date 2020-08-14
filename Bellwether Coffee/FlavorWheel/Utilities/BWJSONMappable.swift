//
//  BWJSONMappable.swift
//  Bellwether-iOS
//
//  Created by Iurii Mozharovskyi on 6/6/16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

enum BWJSONMappableError: Error {
    case incorrectJSON
}


protocol BWFromJSONMappable {
    static func mapFromJSON(_ json: Any) throws -> Self
}


protocol BWToJSONMappable {
    static func mapToJSON(_ object: Self) -> [String : Any]
}


protocol BWJSONMappable: BWFromJSONMappable, BWToJSONMappable {
    
}


extension BWFromJSONMappable {
    
    static func mapFromJSONOrNil(_ json: Any?) throws -> Self? {
        if let json = json {
            return try mapFromJSON(json)
        } else {
            return nil
        }
    }
    
    static func mapArrayFromJSON(_ json: Any) throws -> [Self] {
        guard let array = json as? [AnyObject] else {
            throw BWJSONMappableError.incorrectJSON
        }
        
        var result = [Self]()
        
        for objectJSON in array {
            // TODO: Temp for legacy data format
            if let object = try? mapFromJSON(objectJSON) {
                result.append(object)
            }
            //let object = try mapFromJSON(objectJSON)
            //result.append(object)
        }
        
        return result
    }
    
    static func mapArrayFromJSONOrEmpty(_ json: Any?) throws -> [Self] {
        if let json = json {
            return try mapArrayFromJSON(json)
        } else {
            return [Self]()
        }
    }
}

extension BWToJSONMappable {
    func mapToJSON() -> [String : Any] {
        return type(of: self).mapToJSON(self)
    }
}
