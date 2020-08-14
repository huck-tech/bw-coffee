//
//  BWRoasterHTTPRequestRetrier.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 20.02.17.
//  Copyright © 2017 Bellwether. All rights reserved.
//

import Alamofire


protocol BWRoasterHTTPRequestRetrierDelegate: class {
    func prepareRequestToRetry(_ complation: @escaping (Bool) -> Void)
}


class BWRoasterHTTPRequestRetrier: Alamofire.RequestRetrier {
    
    var delegate: BWRoasterHTTPRequestRetrierDelegate? = nil

    var totalRetryCount: UInt = 3
    
    // MARK: - Alamofire.RequestRetrier
    
    func should(_ manager: SessionManager,
                retry request: Request,
                with error: Error,
                completion: @escaping RequestRetryCompletion) {
        guard request.retryCount < totalRetryCount else {
            completion(false, 0.0)
            return
        }
        
        delegate?.prepareRequestToRetry() { (prepared) in
            completion(prepared, 0.0)
        }
    }
}
