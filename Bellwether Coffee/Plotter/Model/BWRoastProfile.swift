//
//  BWRoastProfile.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 18.08.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation
import SwiftyJSON


struct BWRoastProfilePreheat {
    
    enum `Type`: String {
        case Manual = "MANUAL"
        case Automatic = "AUTOMATIC"
    }
    
    var type: Type
    var temperature: BWTemperature? = nil
}


struct BWRoastProfileStep {
    var temperature: BWTemperature
    var time: TimeInterval
    
    var temp: BWTemperature {return temperature}
    
    mutating func update(temperature: BWTemperature) {
        self.temperature = temperature
    }

    mutating func update(time: TimeInterval) {
        self.time = time
    }
    
    var description: String {
        return "(\(temp):\(time)"
    }
}

extension RoastProfile {
    var asBWRoastProfile: BWRoastProfile? {
        guard let profile = self.profile else {return nil}
        
         let roastProfile: BWRoastProfile? = {
            guard var roastProfile = try? BWRoastProfile.mapFromJSON(profile) else {return nil}

            roastProfile.metadata = BWRoastProfileMetadata(id: self._id ?? "",
                                                           beanID: self.bean ?? "",
                                                           name: self.name ?? "Unknown",
                                                           style: .Light,
                                                           updated: Date(),
                                                           isPublic: self.privacy == Privacy.isPublic.rawValue)
            
            return roastProfile
        }()
        
        return roastProfile
    }
}

extension BWRoastProfile {
    var asRoastProfile: RoastProfile {
        return self.asRoastProfile(for: self.metadata?.beanID ?? "", _id: self.metadata?.id)
    }
    
    func asRoastProfile(for beanId: String, _id:String? = nil, named:String? = nil, privacy: Privacy = Privacy.isPrivate) -> RoastProfile {
        let json = JSON(self.mapToJSON()).rawString()
        
        let name = named ?? self.metadata?.name
        return RoastProfile(_id: _id, bean:beanId, name: name, profile:json, privacy: privacy.rawValue, version:0)
   }
}

struct BWRoastProfile: BWStringValueRepresentable {
    static let minimumStepGap: Int = 15
    
    var metadata: BWRoastProfileMetadata?
    var preheat: BWRoastProfilePreheat
    var steps: [BWRoastProfileStep] = []
    var shrinkage: Double = 0.18
    
    init(preheat: BWRoastProfilePreheat,
         steps: [BWRoastProfileStep],
         metadata: BWRoastProfileMetadata? = nil){
        self.preheat = preheat
        self.steps = steps
        self.metadata = metadata
    }
    
    var firstTemperature: BWTemperature? {
        return self.steps.first?.temp
    }
    
    var actualPreheat: BWTemperature? {
        if let firstTemp = self.steps.first?.temperature {
            return firstTemp
        } else {
            return self.preheat.temperature
        }
    }
    
    //implementation of BWStringValueRepresentable
    var stringValue: String {
        return metadata?.name ?? "<Unnamed>"
    }
}


func bw_roastProfilesHaveSameContent(_ profileA: BWRoastProfile, profileB: BWRoastProfile) -> Bool {
    guard profileA.preheat == profileB.preheat,
        profileA.steps.count == profileB.steps.count else {
        return false
    }
    
    for i in 0..<profileA.steps.count {
        let stepA = profileA.steps[i]
        let stepB = profileB.steps[i]
        if !(stepA == stepB) {
            return false
        }
    }
    
    return true
}

func == (lhs: BWRoastProfilePreheat, rhs: BWRoastProfilePreheat) -> Bool {
    return lhs.type == rhs.type && lhs.temperature == rhs.temperature
}

func == (lhs: BWRoastProfileStep, rhs: BWRoastProfileStep) -> Bool {
    return lhs.temperature == rhs.temperature && lhs.time == rhs.time
}

extension BWRoastProfilePreheat: BWJSONMappable {
    
    struct JSONKeys {
        static let PreheatType = "type"
        static let Temperature = "temp"
    }
    
    static func mapFromJSON(_ json: Any) throws -> BWRoastProfilePreheat {
        let swiftyJSON = JSON(json)
        
        guard let typeString = swiftyJSON[JSONKeys.PreheatType].string,
            let type = Type(rawValue: typeString) else {
                throw BWJSONMappableError.incorrectJSON
        }
        
        switch type {
        case .Manual:
            guard let temperature = swiftyJSON[JSONKeys.Temperature].double else {
                throw BWJSONMappableError.incorrectJSON
            }
            return BWRoastProfilePreheat(type: type, temperature: temperature)
        case .Automatic:
            return BWRoastProfilePreheat(type: type, temperature: nil)
        }
    }
    
    static func mapToJSON(_ object: BWRoastProfilePreheat) -> [String : Any] {
        var json: [String: AnyObject] = [
            JSONKeys.PreheatType: object.type.rawValue as AnyObject
        ]
        
        if let temperature = object.temperature {
            json[JSONKeys.Temperature] = temperature as AnyObject?
        }
        return json
    }
}


extension BWRoastProfileStep {
    static var zero: BWRoastProfileStep {
        return BWRoastProfileStep(temperature: 0, time: 0)
    }
}


extension BWRoastProfileStep: BWJSONMappable {
    
    struct JSONKeys {
        static let Temperature  = "temp"
        static let Time         = "time"
    }
    
    static func mapFromJSON(_ json: Any) throws -> BWRoastProfileStep {
        let swiftyJSON = JSON(json)
        
        guard let temperature = swiftyJSON[JSONKeys.Temperature].int,
            let time = swiftyJSON[JSONKeys.Time].int else {
                throw BWJSONMappableError.incorrectJSON
        }
        
        return BWRoastProfileStep(temperature: BWTemperature(temperature),
                                  time: BWTemperature(time))
    }
    
    static func mapToJSON(_ object: BWRoastProfileStep) -> [String : Any] {
        return [
            JSONKeys.Temperature: Int(round(object.temperature)) as AnyObject,
            JSONKeys.Time: Int(round(object.time)) as AnyObject,
        ]
    }
}


extension BWRoastProfile: BWJSONMappable {
    
    struct JSONKeys {
        static let Profile      = "profile"
        static let Preheat      = "preheat"
        static let Steps        = "steps"
    }
    
    static func mapFromJSON(_ json: Any) throws -> BWRoastProfile {
        guard let parsable = json as? String else {
            throw BWJSONMappableError.incorrectJSON
        }
        let swiftyJSON = JSON.init(parseJSON: parsable)
        
        guard let profileJSONString = swiftyJSON[JSONKeys.Profile].string else {
            throw BWJSONMappableError.incorrectJSON
        }
        
        let profileJSON = JSON.init(parseJSON: profileJSONString)
        
        let preheat = try BWRoastProfilePreheat.mapFromJSON(profileJSON[JSONKeys.Preheat].object as AnyObject)
        
        guard let stepObjects = profileJSON[JSONKeys.Steps].arrayObject else {
            throw BWJSONMappableError.incorrectJSON
        }
        
        let steps = try stepObjects.map { object in
            try BWRoastProfileStep.mapFromJSON(object as AnyObject)
        }
        
        let metadata = try? BWRoastProfileMetadata.mapFromJSON(json)
        
//        let preheat = BWRoastProfilePreheat.init(type: .Automatic, temperature: 204.0)
        return BWRoastProfile(preheat: preheat, steps: steps, metadata: metadata)
    }
    
    static func mapFromInnerJSON(_ json: Any) throws -> BWRoastProfile {
        let swiftyJSON = JSON(json)
        
        let preheat = try BWRoastProfilePreheat.mapFromJSON(swiftyJSON[JSONKeys.Preheat].object as AnyObject)
        
        guard let stepObjects = swiftyJSON[JSONKeys.Steps].arrayObject else {
            throw BWJSONMappableError.incorrectJSON
        }
        
        let steps = try stepObjects.map { object in
            try BWRoastProfileStep.mapFromJSON(object as AnyObject)
        }
        
        return BWRoastProfile(preheat: preheat, steps: steps, metadata: nil)
    }
    
    static func mapToJSON(_ object: BWRoastProfile) -> [String : Any] {
        let profileJSON: [String: Any] = [
            JSONKeys.Preheat:   object.preheat.mapToJSON(),
            JSONKeys.Steps:     object.steps.map { $0.mapToJSON() },
        ]
        
        guard let profileJSONString = JSON(profileJSON).rawString() else {
            assert(false)
            return [:]
        }
        
        if var metadataJSON = object.metadata?.mapToJSON() {
            metadataJSON[JSONKeys.Profile] = profileJSONString
            return metadataJSON
        } else {
            return [
                JSONKeys.Profile: profileJSONString
            ]
        }
    }
}
