//
//  BWRoastLogMetadata.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 01.11.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import SwiftyJSON


struct BWRoastLogMetadata {
    var roastProfileID: BWIdentifier
    var roastProfileType: BWRoastType
    var startTime: Date
    var beanWeight: BWWeight
    var beanID: BWIdentifier
    var profileName: String
    var roasterDeviceID: BWIdentifier
}


extension BWRoastLogMetadata: BWJSONMappable {

    struct JSONKeys {
        static let RoastProfileID       = "roastProfileId"
        static let RoastProfileType     = "type"
        static let StartTime            = "roastStartTime"
        static let BeanWeight           = "beanGreenWeight"
        static let BeanID               = "beanId"
        static let ProfileName          = "profileName"
        static let BeanHouseName        = "beanHouseName"
        static let RoasterDeviceID      = "roasterSerialNumber"
    }

    static func mapToJSON(_ object: BWRoastLogMetadata) -> [String : Any] {
        return [
            JSONKeys.RoastProfileID:    object.roastProfileID.bw_intIdentifierValue,
            JSONKeys.RoastProfileType:  object.roastProfileType.intValue,
            JSONKeys.StartTime:         object.startTime.timeIntervalSince1970,
            JSONKeys.BeanWeight:        object.beanWeight,
            JSONKeys.BeanID:            object.beanID.bw_intIdentifierValue,
            JSONKeys.ProfileName:       object.profileName,
            JSONKeys.BeanHouseName:     object.profileName, //backward compatibility
            JSONKeys.RoasterDeviceID:   object.roasterDeviceID,
        ]
    }

    static func mapFromJSON(_ json: Any) throws -> BWRoastLogMetadata {
        let swiftyJSON = JSON(json)

        guard
            let roastProfileIDInt = swiftyJSON[JSONKeys.RoastProfileID].int,
            let roastProfileTypeInt = swiftyJSON[JSONKeys.RoastProfileType].int,
            let roastProfileType = BWRoastType(intValue: roastProfileTypeInt),
            let startTimestamp = swiftyJSON[JSONKeys.StartTime].double,
            let beanWeight = swiftyJSON[JSONKeys.BeanWeight].double,
            let beanIDInt = swiftyJSON[JSONKeys.BeanID].int,
            let profileName = swiftyJSON[JSONKeys.ProfileName].string ?? swiftyJSON[JSONKeys.BeanHouseName].string,
            let roasterDeviceID = swiftyJSON[JSONKeys.RoasterDeviceID].string else {
                throw BWJSONMappableError.incorrectJSON
        }

        let startTime = Date(timeIntervalSince1970: startTimestamp)
        return BWRoastLogMetadata(roastProfileID: roastProfileIDInt.identifierValue,
                                  roastProfileType: roastProfileType,
                                  startTime: startTime,
                                  beanWeight: beanWeight,
                                  beanID: beanIDInt.identifierValue,
                                  profileName: profileName,
                                  roasterDeviceID: roasterDeviceID)
    }
}
