//
//  RoasterViewController.swift
//  Roaster
//
//  Created by Marcos Polanco on 2/23/18.
//  Copyright © 2018 Bellwether. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyBluetooth

extension UIViewController {
    func acceptInvalidSSLCerts() {        
        SessionManager.default.delegate.sessionDidReceiveChallenge = {session, challenge in
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
                        
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            } else {
                if challenge.previousFailureCount > 0 {
                    disposition = .cancelAuthenticationChallenge
                } else {
                    if let storage = SessionManager.default.session.configuration.urlCredentialStorage {
                        credential = storage.defaultCredential(for: challenge.protectionSpace)
                        disposition = .useCredential
                    }
                }
            }
            
            return (disposition, credential)
        }
    }
}

class ErrorParser: BWResponseErrorParser {
    func parse(json: AnyObject?, error: NSError?, response: HTTPURLResponse?) -> NSError? {
        return nil
    }
    
    func parse(data: Data?, error: NSError?, response: HTTPURLResponse?) -> NSError? {
        return nil
    }
    
    
}

struct NetworkConfigurator : BWRoasterDeviceHTTPSServicesFactoryNetworkConfigurationProvider {
    
    func networkAuthenticator() -> BWNetworkAuthDelegate? {
        let authenticator = BWRoasterDeviceHTTPsAuthenticator()
        authenticator.login = NetworkConfigurator.username
        authenticator.password = NetworkConfigurator.creds
        return authenticator
    }
    
    static var username: String {return Date().timeIntervalSinceReferenceDate.description.prefix(8).description}
    static var creds: String {
        var code: UInt32 = 2;
        username.forEach{char in code += (char.ascii ?? 0)}
        return (7919 * code).description.suffix(4).description
    }
    
    static var headers: HTTPHeaders {
        var headers: HTTPHeaders = [:]
        
        if let authorizationHeader = Request.authorizationHeader(user: NetworkConfigurator.username, password: NetworkConfigurator.creds) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        return headers
    }
    

    
    var hostname: String?
    var password: String?
    
    func serverInfo(for deviceInfo: BWRoasterDeviceInfo, port:Int) -> BWServerInfo {
        return  ServerInfo(hostName: hostname ?? "localhost", port:port)
        
    }
    
    func networkAuthenticator(for deviceInfo: BWRoasterDeviceInfo) -> BWNetworkAuthDelegate? {
        return networkAuthenticator()
    }
    
    func responseErrorParser(for deviceInfo: BWRoasterDeviceInfo) -> BWResponseErrorParser {
        return BWRoasterDeviceHTTPsErrorParser()
    }
    
    func requestRetrier(for deviceInfo: BWRoasterDeviceInfo) -> BWRoasterHTTPRequestRetrier? {
        return nil
    }
    
    
}

extension BWRoastProfile {
    var mockMeasurements: [BWRoastLogMeasurement] {
        return self.steps.map{$0.asMockMeasurement}
    }
}

extension BWRoastProfileStep {
    var asMockMeasurement: BWRoastLogMeasurement {
        return BWRoastLogMeasurement(time: self.time, temperature: self.temperature, skinTemp: self.temperature, humidity: nil)
    }
}

class Shared {
    static let bean = BWGreenBeanInfo(id: "", icoCode: "", processes: nil, variety: nil, title: "A Coffee", roastsTypes: [], certifications: [], originInfo: nil, cuppingNotes: nil, whyLoveIt: nil, socialImpactDescription: nil)

    static let roastProfile: BWRoastProfile = {
        let preheat = BWRoastProfilePreheat(type: .Automatic, temperature: BWTemperature.init(178))// this is, in fact, ignored by code
        var roastProfile = BWRoastProfile(preheat: preheat, steps: [
            BWRoastProfileStep.init(temperature: BWTemperature(218.0), time: 0.0),
            BWRoastProfileStep.init(temperature: BWTemperature(84.0), time: 50.0),
            BWRoastProfileStep.init(temperature: BWTemperature(92.0), time: 95.0),
            BWRoastProfileStep.init(temperature: BWTemperature(114.0), time: 135),
            BWRoastProfileStep.init(temperature: BWTemperature(135.0), time: 176),
            BWRoastProfileStep.init(temperature: BWTemperature(151.0), time: 216),
            BWRoastProfileStep.init(temperature: BWTemperature(168.0), time: 273),
            BWRoastProfileStep.init(temperature: BWTemperature(181.0), time: 335),
            BWRoastProfileStep.init(temperature: BWTemperature(190.0), time: 395),
            BWRoastProfileStep.init(temperature: BWTemperature(198.0), time: 455),
            BWRoastProfileStep.init(temperature: BWTemperature(204.0), time: 516),
            BWRoastProfileStep.init(temperature: BWTemperature(210.0), time: 579),
            BWRoastProfileStep.init(temperature: BWTemperature(213.0), time: 660)
            ])

        roastProfile.metadata = BWRoastProfileMetadata(id: "",
                                                       beanID: "6",
                                                       name: "+ Create new profile",
                                                       style: .Light,
                                                       updated: Date(timeIntervalSince1970: 1475852958),
                                                       isPublic: false)

        return roastProfile
    }()
}

