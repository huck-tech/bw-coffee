//
//  ServerInfo.swift
//  Bellwether-iOS
//
//  Created by Marcos Polanco on 2/24/18.
//  Copyright © 2018 Bellwether. All rights reserved.
//

import Foundation

struct ServerInfo: BWServerInfo {
    var baseURL: URL! {
        var components = URLComponents()
        components.host = hostName
        components.port = port
        components.scheme = "https"
        
        guard let url = components.url else {
            assert(false)
            return nil
        }
        
        return url
    }
    var hostName: String
    var port: Int
}

