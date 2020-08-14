//
//  BWRoasterDeviceHTTPsService.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 03.08.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation


class BWRoasterDeviceHTTPsService: BWAbstractRemoteService, BWRoasterDeviceService {
    
    // MARK: - BWRoasterDeviceService
    
    class var name: String {
        return "HTTPs"
    }
    
    func requestRoastDeviceServiceResponse(requestInfo: RequestInfo,
                                           completion: @escaping (BWRoasterDeviceRoastServiceResponse?, NSError?) -> Void) {
        let jsonParsingClosure = { (JSON: AnyObject) -> BWRoasterDeviceRoastServiceResponse? in
            return try BWRoasterDeviceRoastServiceResponse.mapFromJSONOrNil(JSON)
        }
        
        requestItems(requestInfo, jsonParsingClosure: jsonParsingClosure) {
            (roasterResponse: BWRoasterDeviceRoastServiceResponse?, error: NSError?) in
            if let error = error {
                completion(nil, error)
            } else if let roasterResponse = roasterResponse {
                if roasterResponse.status != .ok {
                    completion(nil, NSError.bw_roasterError(for: roasterResponse.status))
                } else {
                    completion(roasterResponse, nil)
                }
            }
        }
    }
}
