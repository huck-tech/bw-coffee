//
//  BWRoasterDeviceHTTPsAuthenticator.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 14.09.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation


class BWRoasterDeviceHTTPsAuthenticator: BWNetworkAuthDelegate {
    
    // MARK: - DI
    
    var login: String?
    var password: String?
    
    // MARK: - 
    
    internal struct AuthenticationHeaderFields {
        static let Authorization = "Authorization"
        static let Basic = "Basic "
    }
    
    //X9DfISlKFt
    
    fileprivate class func authStringForLogin(_ login: String, password: String) -> String? {
        let basicAuthString = String(format: "%@:%@", login, password)
        
        guard let basicAuthEncodedString = basicAuthString.bw_base64Encodeded() else {
            return nil
        }
        
        return String(format: "%@%@", AuthenticationHeaderFields.Basic, basicAuthEncodedString)
    }
    
    fileprivate class func checkAuthError(_ response: HTTPURLResponse?) -> NSError? {
        if let httpResponse = response
            , httpResponse.statusCode == Int.HTTPStatusCode401Unauthorised {
            return NSError.bw_roasterError(.authenticationFailed)
        } else {
            return nil
        }
    }
    
    // MARK: - BWNetworkAuthDelegate
    
    func authenticateRequest(_ request: URLRequest) -> URLRequest {
        guard let mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
            return request
        }
        
        guard let login = self.login,
            let password = self.password,
            let authString = type(of: self).authStringForLogin(login, password: password) else {
                return request
        }
        
        mutableRequest.setValue(authString, forHTTPHeaderField: AuthenticationHeaderFields.Authorization)
        return mutableRequest as URLRequest
    }
    
    
    func checkAuthenticationError(_ request: URLRequest?,
                                  response: HTTPURLResponse?,
                                  json: AnyObject?,
                                  error: NSError?) -> NSError? {
        return type(of: self).checkAuthError(response)
    }
    
    func checkAuthenticationError(_ request: URLRequest?,
                                  response: HTTPURLResponse?,
                                  data: Data?,
                                  error: NSError?) -> NSError? {
        return type(of: self).checkAuthError(response)
    }
    
    func recoverRequestFromAuthenticationError(_ request: URLRequest,
                                               completion: @escaping BWNetworkAuthDelegateRecoveryCompletion) {
        completion(nil)
    }
}
