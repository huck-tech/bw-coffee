//
//  BWGreenBeanMarketplaceItem.swift
//  Bellwether-iOS
//
//  Created by Iurii Mozharovskyi on 3/10/16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import SwiftyJSON

//{
//    "ICOCode": "123-123-123",
//    "amount": 345,
//    "beanID": "nCmRGzRX3uL0ny1cXHXXQw",
//    "beanName": "New beans",
//    "price": 36
//}

struct BWGreenBeanMarketplaceItem {
    var id: BWIdentifier
    var amount: Double
    var greenBeanID: BWIdentifier
    var greenBean: BWGreenBeanInfo?
    var price: BWCurrency
    var title: String
    
    mutating func update(greenBean: BWGreenBeanInfo?) {
        self.greenBean = greenBean
    }
}


extension BWGreenBeanMarketplaceItem: BWFromJSONMappable {
    
    struct JSONKeys {
        static let Id           = "id"
        static let Amount       = "amount"
        static let GreenBeanID  = "id"
        static let Price        = "price"
        static let Title        = "name"
    }
    
    // MARK: BWFromJSONMappable
    
    static func mapFromJSON(_ json: Any) throws -> BWGreenBeanMarketplaceItem {
        let swiftyJSON = JSON(json)
        
        guard let idInt      = swiftyJSON[JSONKeys.Id].int,
              let amount         = swiftyJSON[JSONKeys.Amount].double,
              let greenBeanIDInt = swiftyJSON[JSONKeys.GreenBeanID].int,
              let priceDouble    = swiftyJSON[JSONKeys.Price].double,
              let title          = swiftyJSON[JSONKeys.Title].string else {
                throw BWJSONMappableError.incorrectJSON
        }
        
        let price = try BWCurrencyTransform().transformFromJSON(priceDouble)
        
        return BWGreenBeanMarketplaceItem(id: idInt.identifierValue,
                                          amount: amount,
                                          greenBeanID: greenBeanIDInt.identifierValue,
                                          greenBean: nil,
                                          price: price,
                                          title: title)
    }
}
