//
//  BWServerInfo.swift
//  Bellwether-iOS
//
//  Created by Anna Yefremova on 24/02/2016.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation


protocol BWServerInfo {
    var baseURL: URL! { get }
}


struct BWServerInfoProvider: BWServerInfo {
    var baseURL: URL!

}


struct BWServerInfoEnpointStage: BWServerInfo {
    
    fileprivate(set) var baseURL: URL!
    
    struct JSONKeys {
        static let Scheme   = "Scheme"
        static let Host     = "Host"
        static let Port     = "Port"
        static let Stage    = "Stage"
        static let Version  = "Version"
    }
    
    static func mapFromJSON(_ json: Any) throws -> BWServerInfoEnpointStage {
        guard let dict = json as? [String : AnyObject],
            let result = BWServerInfoEnpointStage(dict: dict) else {
                throw BWJSONMappableError.incorrectJSON
        }
        
        return result
    }
    
    init?(dict: [String : AnyObject]) {
        guard let scheme = dict[JSONKeys.Scheme] as? String , !scheme.isEmpty,
            let host = dict[JSONKeys.Host] as? String , !host.isEmpty else {
                return nil
        }
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        
        if let portString = dict[JSONKeys.Port] as? String , !portString.isEmpty,
            let port = Int(portString) , port > 0 {
            components.port = NSNumber(value: port as Int) as? Int
        }
        
        var pathComponents = [String]()
        
        if let stage = dict[JSONKeys.Stage] as? String , !stage.isEmpty {
            pathComponents.append(stage)
        }
        
        if let version = dict[JSONKeys.Version] as? String , !version.isEmpty {
            pathComponents.append(version)
        }
        
        if !pathComponents.isEmpty {
            let slash = "/"
            components.path = slash + pathComponents.joined(separator: slash)
        }
        
        guard let url = components.url else {
            return nil
        }
        
        baseURL = url
    }
}
