//
//  BWRoastProfileMetadata.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 18.08.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import SwiftyJSON


struct BWRoastProfileMetadata {
    var id: BWIdentifier
    var beanID: BWIdentifier
    
    var name: String
    var style: BWRoastType
    
    var updated: Date
    var isPublic: Bool
    
    mutating func rename(name: String) {
        self.name = name
    }
}


extension BWRoastProfileMetadata: BWJSONMappable {
    
    struct JSONKeys {
        static let identifier   = "id"
        static let beanID       = "beanId"
        
        static let name         = "name"
        static let style        = "type"
        
        static let updated      = "updated"
        static let isPublic     = "public"
    }
    
    static func mapFromJSON(_ json: Any) throws -> BWRoastProfileMetadata {
        let swiftyJSON = JSON(json)
        
        guard let id = swiftyJSON[JSONKeys.identifier].int?.identifierValue,
            let beanID = swiftyJSON[JSONKeys.beanID].int?.identifierValue,
            let name = swiftyJSON[JSONKeys.name].string,
            let styleInt = swiftyJSON[JSONKeys.style].int,
            let style = BWRoastType(intValue: styleInt),
            let updatedTimestamp = swiftyJSON[JSONKeys.updated].double,
            let isPublic = swiftyJSON[JSONKeys.isPublic].bool else {
                throw BWJSONMappableError.incorrectJSON
        }
        
        let updatedDate = Date(timeIntervalSince1970: updatedTimestamp)
        
        return BWRoastProfileMetadata(id: id,
                                      beanID: beanID,
                                      name: name,
                                      style: style,
                                      updated: updatedDate,
                                      isPublic: isPublic)
    }
    
    static func mapToJSON(_ object: BWRoastProfileMetadata) -> [String : Any] {
        return [
            JSONKeys.identifier:    object.id,
            JSONKeys.beanID:        object.beanID,
            
            JSONKeys.name:          object.name,
            JSONKeys.style:         object.style.intValue,
            
            JSONKeys.updated:       object.updated.timeIntervalSince1970,
            JSONKeys.isPublic:      object.isPublic,
        ]
    }
    
}
