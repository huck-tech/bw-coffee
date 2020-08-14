//
//  BWRegion.swift
//  Bellwether-iOS
//
//  Created by Anna Yefremova on 07/03/2016.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation
import SwiftyJSON


struct BWRegion {
    var title: String?
    var worldRegion: BWWorldRegion?
    var latitude: Double?
    var longitude: Double?
    var elevation: Double?
    var country: String?
    var city: String?
    var images: [URL]
}


extension BWRegion: BWFromJSONMappable {
    
    struct JSONKeys {
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
        static let Grower               = "grower"
        static let Story                = "story"
    }
    
    static func mapFromJSON(_ json: Any) throws -> BWRegion {
        let swiftyJSON = JSON(json)
        
        let regionTitle     = swiftyJSON[JSONKeys.RegionTitle].string
        let regionLatitude  = swiftyJSON[JSONKeys.Location][JSONKeys.Latitude].double
        let regionLongitude = swiftyJSON[JSONKeys.Location][JSONKeys.Longitude].double
        let regionElevation = Double(swiftyJSON[JSONKeys.Elevation].stringValue)
        let regionCountry   = swiftyJSON[JSONKeys.Country].string
        let regionCity      = swiftyJSON[JSONKeys.City].string
        let regionImages    = swiftyJSON[JSONKeys.Images].arrayObject as? [String]
        
        var regionWorldRegion: BWWorldRegion? = nil
        if let worldRegion = swiftyJSON[JSONKeys.Origin][JSONKeys.Region].string {
            regionWorldRegion = BWWorldRegion(rawValue: worldRegion)
        }
        
        let images = try BWURLTransformer().transformArrayFromJSONOrEmpty(regionImages)
        
        return BWRegion(title: regionTitle,
                        worldRegion: regionWorldRegion,
                        latitude: regionLatitude,
                        longitude: regionLongitude,
                        elevation: regionElevation,
                        country: regionCountry,
                        city: regionCity,
                        images: images)
    }
}
