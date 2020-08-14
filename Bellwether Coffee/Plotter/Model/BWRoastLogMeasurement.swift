//
//  BWRoastLogMeasurement.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 01.11.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import SwiftyJSON


struct BWRoastLogMeasurement {
    var time: TimeInterval
    var temperature: BWTemperature
    var skinTemp: BWTemperature
    var humidity: BWHumidity?
}


extension BWRoastLogMeasurement: BWJSONMappable {
    
    struct JSONKeys {
        static let Time         = "time"
        static let Temperature  = "temp"
        static let SkinTemp     = "skin"
    }
    
    static func mapToJSON(_ object: BWRoastLogMeasurement) -> [String : Any] {
        return [
            JSONKeys.Time:          object.time,
            JSONKeys.Temperature:   object.temperature,
            JSONKeys.SkinTemp:      object.skinTemp
        ]
    }
    
    static func mapFromJSON(_ json: Any) throws -> BWRoastLogMeasurement {
        let swiftyJSON = JSON(json)
        
        guard let timestamp = swiftyJSON[JSONKeys.Time].double,
            let temperature = swiftyJSON[JSONKeys.Temperature].double else {
                throw BWJSONMappableError.incorrectJSON
        }
        
        let skinTemp = swiftyJSON[JSONKeys.SkinTemp].double  ?? 0.0

        return BWRoastLogMeasurement(time: timestamp, temperature: temperature, skinTemp: skinTemp, humidity: nil)
    }
}
