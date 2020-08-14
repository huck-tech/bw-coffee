//
//  Maintenance.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 10/27/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import Parse
import UserNotifications

class AppConfiguration: PFObject {
    @NSManaged var key:         String?
    @NSManaged var value:      String?
    
    enum Keys: String {
        case cleanGlassPoundLimit = "cleanGlassPoundLimit"
        case emptyChaffPoundsLimit = "emptyChaffPoundsLimit"
        case roastChatAssignee = "roastChatAssignee"
        
        static var all: [Keys] = [.cleanGlassPoundLimit,
                                  .emptyChaffPoundsLimit,
                                  .roastChatAssignee]
    }
    
    // default values if there is nothing different in the server
    static var settings: [Keys:String] = [
            .cleanGlassPoundLimit : "125.0",
            .emptyChaffPoundsLimit : "50.0",
                .roastChatAssignee : Asana.ricardo
    ]

    override init() {
        super.init()
    }
    
    
    static func value(for key: Keys, cached: Bool = false, completion: @escaping DoubleHandler) {
        
        //if the caller is fine with cached results, return what we have
        if cached, let result = settings[key]?.asDouble {return completion(result)}
        
        //if the query fails, return the cached values
        guard let query = AppConfiguration.query() else {return completion(settings[key]!.asDouble)}
        query.whereKey("key", equalTo: key.rawValue)
        query.findObjectsInBackground {results, error in
            let configEntry = results?.first as? AppConfiguration
            let result = configEntry?.value?.asDouble
            
            //if we have a result, store it in settings for next time
            if let _ = result {
                settings[key] = configEntry?.value
            }
            
            //return the result or the cached value if there is any error
            completion (result ?? settings[key]!.asDouble)
        }
    }
}

extension AppConfiguration: PFSubclassing {static func parseClassName() -> String {return "AppConfiguration"}}

typealias MaintenanceActionHandler = (MaintenanceAction?) -> Void

class MaintenanceEvent: PFObject {
    
    //cached past results, indexed by serial number -> action -> (result & date of retrieval)
    static var cache = [String:[MaintenanceAction:(Double, Date)]]()
    
    @NSManaged var serialNumber:   String?
    @NSManaged var userId:          String?
    @NSManaged var actionId:        NSNumber?

    enum Fields: String {
        case serialNumber =    "serialNumber"
        case userId =       "userId"
        case actionId =     "actionId"
        
        static var all: [Fields] = [.serialNumber, .userId, .actionId]
    }
    
    
    override init() {
        super.init()
    }
    
    init(userId: String, serialNumber:String, action: MaintenanceAction) {
        super.init()
        
        self.userId = userId
        self.serialNumber = serialNumber
        self.actionId = action.rawValue.asNumber
    }
    
    static func actionRequired(completion: @escaping MaintenanceActionHandler) {
        
        getRatio(action: .cleanGlass, configuration: .cleanGlassPoundLimit){glassRatio in
            getRatio(action: .emptyChaff, configuration: .emptyChaffPoundsLimit){chaffRatio in
                guard let glassRatio = glassRatio, let chaffRatio = chaffRatio else {return completion(nil)}
                
                //if the chaff has not been emptied, that is the priority
                if chaffRatio > 1 {return completion(.emptyChaff)}
                
                //if glass is not clean, that is the priority
                if glassRatio > 1 {return completion(.cleanGlass)}

                //nothing to do
                completion(.none)
            }
        }
    }
    
    static private func getRatio(action: MaintenanceAction, configuration: AppConfiguration.Keys, completion: @escaping DoubleHandler){
        MaintenanceEvent.poundsSinceLast(action, cached:true) {pounds, error in
            guard error == nil, let pounds = pounds else {return completion(nil)}
            
            AppConfiguration.value(for: configuration, completion: {limit in
                guard let limit = limit else {return completion(nil)} // should never happen, because limit is never nil
                
                //return the pounds divided by the limit, as an indication of whether an action is required or not
                completion(pounds / limit)
            })
        }
    }
    
    
    static func poundsSinceLast(_ action: MaintenanceAction) -> (Double, Date)? {
        guard let serialNumber = Roaster.shared.serialNumber else {return nil}
    
        return cache[serialNumber]?[action]
    }
    
    static func loadRoasterInfo(){
        guard let serialNumber = Roaster.shared.serialNumber else {return}
        
        //go through each maintenance action
        MaintenanceAction.all.forEach{action in
            
            //query the number of pounds since the action was taken for the roaster
            self.poundsSinceLast(action) {result, error in
                
                //and cache the result if it exists
                if let result = result {
                    self.cache(serialNumber: serialNumber, action: action, value: result)
                }
            }
        }
    }
    
    static func cache(serialNumber: String, action: MaintenanceAction, value: Double){
        if cache[serialNumber] == nil {
            cache[serialNumber] = [:]
        }
        
        cache[serialNumber]?[action] = (value, Date())
    }
    
    static func poundsSinceLast(_ action: MaintenanceAction, cached:Bool = false, completion: @escaping (Double?, NSError?) -> Void) {
        guard let serialNumber = Roaster.shared.serialNumber else {return completion(nil, NSError.init())}
        
        //if we have cached the results and the caller is happy with that, send it back
        if cached, let retrieval = self.poundsSinceLast(action) {
            return completion(retrieval.0, nil)
        }
        
        self.last(action, for: serialNumber) {event, error in
            guard error == nil else {return completion(nil, error)}
            //we have a valid response
            
            //now we need to query the roast logs since the date of that event
            guard let query = RoastLog.query() else {return completion(nil, NSError.init())}
            
            
            query.whereKey("serialNumber", equalTo: serialNumber)
            if let lastEventDate =  event?.createdAt {
                query.whereKey("createdAt", greaterThan: lastEventDate)
            }
            
            query.findObjectsInBackground {results, error in
                guard let roasts = results as? [RoastLog] else {return completion(nil, NSError.init())}
                
                //we have roast since the last maintenance event, so now sum the data
                let pounds = roasts.reduce(0, {prev, next in prev + (next.inputWeight?.doubleValue ?? 0.0)})
                
                //cache the data
                self.cache(serialNumber: serialNumber, action: action, value: pounds)
                completion(pounds, nil)
            }
        }
    }
    
    /*  Identify the lsat date when the given action was delivered to the given machine
     */
    static private func last(_ action: MaintenanceAction, for serialNumber: String, completion: @escaping MaintenanceEventHandler){
        guard let query = MaintenanceEvent.query() else {return completion(nil, NSError())}
        
        //only query for the given machine for the given action
        query.whereKey(Fields.serialNumber.rawValue, equalTo: serialNumber)
        query.whereKey(Fields.actionId.rawValue, equalTo: action.rawValue.asNumber)
        
        //grab the last one
        query.order(byDescending: "createdAt")
        query.limit = 1
        
        query.findObjectsInBackground {results, error in
            guard let events = results as? [MaintenanceEvent] else {return completion(nil, NSError())}
            
            //return the first result, which will be the most recent. If it has not happened, it will be nil
            completion(events.first, nil)
        }
    }
    
    static func take(_ action: MaintenanceAction, completion: @escaping BoolHandler) {
        guard let email = BellwetherAPI.auth.currentProfileInfo?.subtitle, //track by user's email address
            let serialNumber = Roaster.shared.serialNumber else {return completion(false)}
        
        let event = MaintenanceEvent.init(userId: email, serialNumber: serialNumber, action: action)
        event.saveInBackground {success, error in
                completion(success)
        }
    }
}

extension MaintenanceEvent: PFSubclassing {static func parseClassName() -> String {return "MaintenanceEvent"}}

enum MaintenanceAction: Int {
    case none = 0
    case cleanGlass = 1
    case emptyChaff = 2
    
    var stringValue: String {
        switch (self){
        case .none:     return "None"
        case .cleanGlass: return "Clean Glass"
        case .emptyChaff: return "Empty Chaff Can"
        }
    }
    
    static var all: [MaintenanceAction] = [.cleanGlass, .emptyChaff]
}

typealias MaintenanceEventHandler = (MaintenanceEvent?, NSError?) -> Void

