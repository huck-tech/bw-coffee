//
//  BWRoastLogSummary.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 01.11.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import SwiftyJSON


struct BWRoastLogSummary {
    var startWeight: BWWeight
    var endWeight: BWWeight
    var chargeTemperature: BWTemperature
    var minutes5Temperature: BWTemperature?
    var minutes8Temperature: BWTemperature?
    var endTemperature: BWTemperature
    var dropTime: TimeInterval
    var firstCrack: TimeInterval?
}


extension BWRoastLogSummary: BWJSONMappable {

    struct JSONKeys {
        static let StartWeight = "startWeight"
        static let EndWeight = "endWeight"
        static let ChargeTemperature = "chargeTemperature"
        static let Minutes5Temperature = "5minutesTemperature"
        static let Minutes8Temperature = "8minutesTemperature"
        static let EndTemperature = "endTemperature"
        static let DropTime = "dropTime"
        static let FirstCrack = "firstCrack"
    }

    static func mapToJSON(_ object: BWRoastLogSummary) -> [String : Any] {
        var json: [String: Any] = [
            JSONKeys.StartWeight: object.startWeight,
            JSONKeys.EndWeight: object.endWeight,
            JSONKeys.ChargeTemperature: object.chargeTemperature,
            JSONKeys.EndTemperature: object.endTemperature,
            JSONKeys.DropTime: object.dropTime,
        ]
        
        if let minutes5Temperature = object.minutes5Temperature {
            json[JSONKeys.Minutes5Temperature] = minutes5Temperature
        }
        
        if let minutes8Temperature = object.minutes8Temperature {
            json[JSONKeys.Minutes8Temperature] = minutes8Temperature
        }
        
        if let firstCrack = object.firstCrack {
            json[JSONKeys.FirstCrack] = firstCrack
        }
        
        return json
    }

    static func mapFromJSON(_ json: Any) throws -> BWRoastLogSummary {
        let swiftyJSON = JSON(json)

        guard
            let startWeight = swiftyJSON[JSONKeys.StartWeight].double,
            let endWeight = swiftyJSON[JSONKeys.EndWeight].double,
            let chargeTemperature = swiftyJSON[JSONKeys.ChargeTemperature].double,
            let endTemperature = swiftyJSON[JSONKeys.EndTemperature].double,
            let dropTime = swiftyJSON[JSONKeys.DropTime].double else {
                throw BWJSONMappableError.incorrectJSON
        }
        
        let minutes5Temperature = swiftyJSON[JSONKeys.Minutes5Temperature].double
        let minutes8Temperature = swiftyJSON[JSONKeys.Minutes8Temperature].double
        let firstCrack = swiftyJSON[JSONKeys.FirstCrack].double

        return BWRoastLogSummary(startWeight: startWeight,
                                 endWeight: endWeight,
                                 chargeTemperature: chargeTemperature,
                                 minutes5Temperature: minutes5Temperature,
                                 minutes8Temperature: minutes8Temperature,
                                 endTemperature: endTemperature,
                                 dropTime: dropTime,
                                 firstCrack: firstCrack)
    }
}
