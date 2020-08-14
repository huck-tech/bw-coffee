//
//  BWGreenBeanInfo.swift
//  Bellwether-iOS
//
//  Created by Iurii Mozharovskyi on 3/10/16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import SwiftyJSON

//{
//    "ICOCode": "103-455-304",
//    "amount": 100,
//    "beanID": "obqL4nx2S7MfJtVwjPVjmQ",
//    "beanName": "Tanzania Mocha beans clone #1",
//    "certifications":
//    {
//        "cert1": ["Organic"],
//        "cert2": ["Bird Friendly"]
//    },
//    "createdDate": 1459440971297,
//    "cuppingNotes":
//    {
//        "c1": ["Sweet", "Floral"],
//        "c2": ["Tobaco", "Burnt", "Cereal"],
//        "c3": ["Achrid", "Smokie", "cardboard"]
//    },
//    "grower": "Horra Tanzania Estate",
//    "origin":
//    {
//        "city": "Bumba",
//        "country": "Tanzania",
//        "elevation": "1250",
//        "images":
//        [
//        "https://c1.staticflickr.com/1/152/350877100_58f090feae_z.jpg",
//        "https://c8.staticflickr.com/3/2463/3623858479_44aa38a77e_b.jpg"
//        ],
//        "info": "Some nice Region in Tanzania where I have never been :(",
//        "location":
//        {
//            "lat": 27.66,
//            "lon": 45.56
//        },
//        "region": "Africa"
//    },
//    "price": 13,
//    "process": "washed",
//    "roasts": ["Medium", "Light", "Cold Brew"],
//    "socialImpactDescription": "One-liner about how purchasing this coffee is helping the farmer's family and community.",
//    "story": "Very good coffee from Tanzania, Africa. Enjoyed from 1950. Buy asap.",
//    "updatedDate": 1459440971297,
//    "variety": ["Red Bourbon"],
//    "whyLoveIt": "This coffee is from one of our favorite growers..."
//}

struct BWGreenBeanInfo {
    var id: String
    var icoCode: String
    var processes: [String]?
    var variety: [String]?
    var title: String
    var roastsTypes: [BWRoastType]
    var certifications: [BWCertificationType]
    var originInfo: BWOriginInfo?
    var cuppingNotes: BWColorWheel?
    var whyLoveIt: String?
    var socialImpactDescription: String?
}


extension BWGreenBeanInfo: BWFromJSONMappable {
    
    struct JSONKeys {
        static let Id                   = "id"
        static let ICOCode              = "icocode"
        static let Story                = "story"
        static let Processes            = "processes"
        static let Grower               = "grower"
        static let Variety              = "variety"
        static let Title                = "name"
        static let Roasts               = "roasts"
        static let Certifications       = "certifications"
        static let Region               = "region"
        static let RegionTitle          = "info"
        static let Location             = "location"
        static let Longitude            = "lon"
        static let Latitude             = "lat"
        static let Elevation            = "elevation"
        static let Origin               = "origin"
        static let Country              = "country"
        static let Images               = "images"
        static let City                 = "city"
        static let CuppingNotes         = "cuppingNotes"
        static let WhyLoveIt            = "whyLoveIt"
        static let SocialImpactDescription = "socialImpact"
    }
    
    static func mapFromJSON(_ json: Any) throws -> BWGreenBeanInfo {
        let swiftyJSON = JSON(json)
        
        guard let idInt   = swiftyJSON[JSONKeys.Id].int,
              let icoCode = swiftyJSON[JSONKeys.ICOCode].string,
              let title   = swiftyJSON[JSONKeys.Title].string else {
            throw BWJSONMappableError.incorrectJSON
        }
        
        var originInfo: BWOriginInfo? = nil
        if let originJSON = swiftyJSON[JSONKeys.Origin].dictionaryObject {
            let region = try BWRegion.mapFromJSON(originJSON)
            
            let growerTitle = swiftyJSON[JSONKeys.Grower].string
            let growerStory = swiftyJSON[JSONKeys.Story].string
            
            let grower = BWGrower(title: growerTitle, story: growerStory)
            
            originInfo = BWOriginInfo(region: region, grower: grower)
        }
        
        let fromJSON = { (value: String) throws -> String in return value.bw_toHumanReadable() }
        let toJSON = { (value: String) -> String in return value.bw_toEnumIdentifier() }
        let transform = BWTransformOf<String, String>(fromJSON: fromJSON,
                                                      toJSON: toJSON)

        var processes: [String]?
        if let processJSON = swiftyJSON[JSONKeys.Processes].arrayObject as? [String] {
            processes = try transform.transformArrayFromJSONOrEmpty(processJSON)
        }
        
        let varietyStrings = swiftyJSON[JSONKeys.Variety].arrayObject as? [String]
        let variety = try transform.transformArrayFromJSONOrEmpty(varietyStrings)
        
        let roastTypesJSON = swiftyJSON[JSONKeys.Roasts].arrayObject as? [String]
        let roasTypes = try BWEnumRawTransformer<BWRoastType>().transformArrayFromJSONOrEmpty(roastTypesJSON)
        
        let certificationsJSON = swiftyJSON[JSONKeys.Certifications].arrayObject as? [String]
        let certifications = try BWEnumRawTransformer<BWCertificationType>().transformArrayFromJSONOrEmpty(certificationsJSON)
        
        let cuppungNotes = try BWColorWheel.mapFromJSONOrNil(swiftyJSON[JSONKeys.CuppingNotes].dictionaryObject)
        let whyLoveIt    = swiftyJSON[JSONKeys.WhyLoveIt].string
        let socialImpact = swiftyJSON[JSONKeys.SocialImpactDescription].string
        
        return BWGreenBeanInfo(id: idInt.identifierValue,
                               icoCode: icoCode,
                               processes: processes,
                               variety: variety,
                               title: title,
                               roastsTypes: roasTypes,
                               certifications: certifications,
                               originInfo: originInfo,
                               cuppingNotes: cuppungNotes,
                               whyLoveIt: whyLoveIt,
                               socialImpactDescription: socialImpact)
        
    }
}


enum BWRoastType: String {
    case Light      = "LIGHT"
    case Medium     = "MEDIUM"
    case Dark       = "DARK"
    case Espresso   = "ESPRESSO"
    case ColdBrew   = "COLD_BREW"
    case Blend      = "BLEND"
    case Decaf      = "DECAF"
    
    init?(intValue: Int) {
        switch intValue {
        case 0: self = .Light
        case 1: self = .Medium
        case 2: self = .Dark
        case 3: self = .Espresso
        case 4: self = .ColdBrew
        case 5: self = .Blend
        case 6: self = .Decaf
        default:
            return nil
        }
    }
    
    var intValue: Int {
        switch self {
        case .Light:
            return 0
        case .Medium:
            return 1
        case .Dark:
            return 2
        case .Espresso:
            return 3
        case .ColdBrew:
            return 4
        case .Blend:
            return 5
        case .Decaf:
            return 6
        }
    }
}


extension BWRoastType: BWStringValueRepresentable {
    var stringValue: String {
        get {
            switch self {
            case .Light:
                return NSLocalizedString("BEAN_ROAST_TYPE_LIGHT", comment: "")
            case .Medium:
                return NSLocalizedString("BEAN_ROAST_TYPE_MEDIUM", comment: "")
            case .Dark:
                return NSLocalizedString("BEAN_ROAST_TYPE_DARK", comment: "")
            case .Espresso:
                return NSLocalizedString("BEAN_ROAST_TYPE_ESPRESSO", comment: "")
            case .ColdBrew:
                return NSLocalizedString("BEAN_ROAST_TYPE_COLD_BREW", comment: "")
            case .Blend:
                return NSLocalizedString("BEAN_ROAST_TYPE_BLEND", comment: "")
            case .Decaf:
                return NSLocalizedString("BEAN_ROAST_TYPE_DECAF", comment: "")
            }
        }
    }
    
    static var stringRawValues: [String] {
        var result = [String]()
        for value in bw_iterateEnum(BWRoastType.self) {
            result.append(value.stringValue)
        }
        
        return result
    }
}

enum BWWorldRegion: String, BWStringValueRepresentable {
    case Africa = "AFRICA"
    case CentralAmerica = "CENTRAL_AMERICA"
    case SouthAmerica = "SOUTH_AMERICA"
    case NorthAmerica = "NORTH_AMERICA"
    case PacificOceania = "PACIFIC_OCEANIA"

    var stringValue: String {
        switch self {
        case .Africa:
            return NSLocalizedString("ORIGIN_AREA_AFRICA", comment: "")
        case .CentralAmerica:
            return NSLocalizedString("ORIGIN_AREA_CENTRAL_AMERICA", comment: "")
        case .SouthAmerica:
            return NSLocalizedString("ORIGIN_AREA_SOUTH_AMERICA", comment: "")
        case .NorthAmerica:
            return NSLocalizedString("ORIGIN_AREA_NORTH_AMERICA", comment: "")
        case .PacificOceania:
            return NSLocalizedString("ORIGIN_AREA_PACIFIC_OCEANIA", comment: "")
        }
    }
}

// TODO: remove this hack once value dictionaries are implemented on BE side.
extension String {
    func bw_toHumanReadable() -> String {
        return self.replacingOccurrences(of: "_", with: " ").capitalized(with: NSLocale.current)
    }
    
    func bw_toEnumIdentifier() -> String {
        return self.replacingOccurrences(of: " ", with: "_").uppercased(with: NSLocale.current)
    }
}
