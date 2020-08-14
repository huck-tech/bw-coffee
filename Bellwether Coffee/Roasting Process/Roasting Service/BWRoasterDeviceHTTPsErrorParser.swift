//
//  BWRoasterDeviceHTTPsErrorParser.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 14.09.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import UIKit

class BWRoasterDeviceHTTPsErrorParser: BWResponseErrorParser {
    
    // MARK: - BWResponseErrorParser

    func parse(json: AnyObject?, error: NSError?, response: HTTPURLResponse?) -> NSError? {
        if let error = checkAuthError(error) {
            return error
        }
        
        return nil
    }
    
    func parse(data: Data?, error: NSError?, response: HTTPURLResponse?) -> NSError? {
        if let error = checkAuthError(error) {
            return error
        }
        
        return nil
    }
    
    // MARK: - Private
    
    fileprivate func checkAuthError(_ error: NSError?) -> NSError? {
        if let error = error
            , error.code == BWRoasterDeviceErrorCode.authenticationFailed.rawValue {
            return error
        } else {
            return nil
        }
    }
}
