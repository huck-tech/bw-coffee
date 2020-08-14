//
//  BWCertificationType.swift
//  Bellwether-iOS
//
//  Created by Iurii Mozharovskyi on 4/4/16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation


enum BWCertificationType: String {
    // Main
    case Organic            = "ORGANIC"
    case FairTrade          = "FAIR_TRADE"
    case Biodynamic         = "BIODYNAMIC"
    case RainforestAlliance = "RAINFOREST_ALLIANCE"
    // Additional
    case Conventional   = "CONVENTIONAL"
    case BirdFriendly   = "BIRD_FRIENDLY"
    case UtzCertified   = "UTZ_CERTIFIED"
    case BCorp          = "BCORP"

    static func filterValues() -> [BWCertificationType] {
        return [Organic,
                FairTrade,
                Biodynamic,
                RainforestAlliance]
    }
}


extension BWCertificationType: BWStringValueRepresentable {
    var stringValue: String {
        get {
            switch self {
                // Main
            case .Organic:
                return NSLocalizedString("BEAN_CERTIFICATION1_TYPE_ORGANIC", comment: "")
            case .FairTrade:
                return NSLocalizedString("BEAN_CERTIFICATION1_TYPE_FAIR_TRADE", comment: "")
            case .Biodynamic:
                return NSLocalizedString("BEAN_CERTIFICATION1_TYPE_BIODYNAMIC", comment: "")
            case .RainforestAlliance:
                return NSLocalizedString("BEAN_CERTIFICATION1_TYPE_RAINFOREST_ALLIANCE", comment: "")
                // Additinal
            case .Conventional:
                return NSLocalizedString("BEAN_CERTIFICATION2_TYPE_CONVENTIONAL", comment: "")
            case .BirdFriendly:
                return NSLocalizedString("BEAN_CERTIFICATION2_TYPE_BIRD_FRIENDLY", comment: "")
            case .UtzCertified:
                return NSLocalizedString("BEAN_CERTIFICATION2_TYPE_UTZ_CERTIFIED", comment: "")
            case .BCorp:
                return NSLocalizedString("BEAN_CERTIFICATION2_TYPE_BCORP", comment: "")
            }
        }
    }
}
