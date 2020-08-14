//
//  RoastLogs.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/12/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class RoastLogs {
    
    func getLogs(timestamp: String, completion: @escaping ([RoastLogRecord]?) -> Void) {
        
    }
    
    func createLog(record: RoastLogRecord, session: ManagingSession, completion: @escaping (Bool) -> Void) {
        let params: [String: Any] = [
            "activeCafe": session.cafe ?? "",
            "activeStore": session.store ?? ""
        ]
        
        SpeedyNetworking.post(route: "/roast-logs/create", model: record, data: params) { response in
            completion(response.success)
        }
    }
    
}
