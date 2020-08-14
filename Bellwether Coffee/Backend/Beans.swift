//
//  Beans.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/3/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class Beans {
    
    let forHive = ["BW0009","BW0006","BW0014","BW0015","BW0020"]
    let forSweetBar = ["BW0006", "BW0014", "BW0015", "BW0020", "BW0017", "BW0018"]
    let forFirebrand = ["BW0006", "BW0014", "BW0015", "BW0020", "BW0017", "BW0018", "BW0019"]

    func getBean(id: String, completion: @escaping (Bean?) -> Void) {
        SpeedyNetworking.get(route: "/beans/\(id)") { response in
            guard response.success else { return completion(nil) }
            
            let bean = response.result(model: Bean.self)
            completion(bean)
        }
    }
    
    func getBeans(completion: @escaping ([Bean]?) -> Void) {
        SpeedyNetworking.get(route: "/beans") {[weak self] response in
            guard response.success else { return completion(nil) }
            
            var beans = response.result(model: [Bean].self)
            
            //filter in only the beans approved for these particular customers
            if let _self = self {
                if BellwetherAPI.auth.isHive {beans = beans?.filter {_self.forHive.index(of: $0.sku ?? "") != nil}}
                if BellwetherAPI.auth.isSweetBar {beans = beans?.filter {_self.forSweetBar.index(of: $0.sku ?? "") != nil}}
                if BellwetherAPI.auth.isFirebrand {beans = beans?.filter {_self.forFirebrand.index(of: $0.sku ?? "") != nil}}
            }
            completion(beans)
        }
    }
    
}
