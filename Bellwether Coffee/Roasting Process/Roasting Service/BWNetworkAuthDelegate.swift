//
//  BWNetworkAuthDelegate.swift
//  Bellwether-iOS
//
//  Created by Anna Yefremova on 24/02/2016.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation



typealias BWNetworkAuthDelegateRecoveryCompletion = (_ recoveredRequest: URLRequest?) -> Void



protocol BWNetworkAuthDelegate {
    func authenticateRequest(_ request: URLRequest) -> URLRequest
    func checkAuthenticationError(_ request: URLRequest?,
                                  response: HTTPURLResponse?,
                                  json: AnyObject?,
                                  error: NSError?) -> NSError?
    func checkAuthenticationError(_ request: URLRequest?,
                                  response: HTTPURLResponse?,
                                  data: Data?,
                                  error: NSError?) -> NSError?
    
    func recoverRequestFromAuthenticationError(_ request: URLRequest,
                                               completion: @escaping BWNetworkAuthDelegateRecoveryCompletion)
}
