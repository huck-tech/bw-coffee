//
//  BWRoasterDeviceInfo.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 01.08.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation
import SwiftyJSON


struct BWRoasterDeviceInfo {
    var id: BWIdentifier
    var name: String
}


extension BWRoasterDeviceInfo: Equatable { }
func == (lhs: BWRoasterDeviceInfo, rhs: BWRoasterDeviceInfo) -> Bool {
    return lhs.id == rhs.id
}


extension BWRoasterDeviceInfo: Hashable {
    var hashValue: Int {
        return id.hashValue
    }
}


extension BWRoasterDeviceInfo: BWFromJSONMappable {
    
    struct JSONKeys {
        static let ID = "serialNumber"
        static let name = "name"
    }
    
    static func mapFromJSON(_ json: Any) throws -> BWRoasterDeviceInfo {
        let swiftyJSON = JSON(json)
        
        guard let id = swiftyJSON[JSONKeys.ID].string else {
                throw BWJSONMappableError.incorrectJSON
        }
        
        let name = swiftyJSON[JSONKeys.name].string ?? "Roaster"
        
        return BWRoasterDeviceInfo(id: id, name: name)
    }
}


enum BWRoasterDeviceInitializationStatus: String {
    case NewDevice = "NEED_SETUP"
    case Initialized = "READY"
}
