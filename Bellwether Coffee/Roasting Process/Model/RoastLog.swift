//
//  RoastLog.swift
//  Bellwether Coffee
//
//  Created by Marcos Polanco on 10/4/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation
import Parse
import SwiftyJSON

class RoastData: PFObject {
    @NSManaged var log: RoastLog?    //json
    @NSManaged var measurements: String?    //json
}

class RoastLog: PFObject {
    
    private static let MAX_DAYS = 60               //default number of days to back in the thread
    
    @NSManaged var serialNumber:     String?
    @NSManaged var machine: String?
    @NSManaged var date: Date?
    @NSManaged var roaster: String?         //full name, not their id!
    @NSManaged var bean: String?            //bean id
    @NSManaged var profile: String?         //profile id
    @NSManaged var inputWeight: NSNumber?
    @NSManaged var dropTime: NSNumber?      //length of roast?
    @NSManaged var outputWeight: NSNumber?
    @NSManaged var measurements: String?    //json
    @NSManaged var firmware: String?        //firmware version
    @NSManaged var comments: [RoastLogComment]?      //comments associated with the the
    @NSManaged var favorite: NSNumber?      //boolean
    @NSManaged var state: NSNumber?      //BWRoasterDeviceRoastState
    @NSManaged var cafe: String?      //BWRoasterDeviceRoastState
    @NSManaged var data: RoastData?      //BWRoasterDeviceRoastState
    
    static var maxDays: Int {
        return AppDelegate.isProduction ? 365 : MAX_DAYS
    }
    
    //cache of the roast loags which have been loaded
    static var roastLogs =     [RoastLog]() {
        didSet {
            delegate?.roastLogDidChange()
        }
    }
    
    /*  BeandId: ProfileId: [RoastLog]
     */
    static var rawRoastLogs = [String:[String:[RoastLog]]]()
    
    static var delegate: RoastLogDatabaseDelegate?
    
    //these are numeric because they are being used to index into the roast log table for sorting purposes
    enum Fields: Int {
        case when       //date
        case who        //roaster
        case coffee     //bean
        case profile
        case green
        case charge     //profile.preheat
        case time
        case roast
        case loss
        case favorite
    }
    
    //track the last key and order for sorting
    static var lastSortKey: Fields = .when
    static var sortOrder: ComparisonResult = .orderedAscending
    
    static func sort(key: Fields) {
        
        if lastSortKey == key {
            //if we are sorting on the same key as before, toggle
            sortOrder = sortOrder == .orderedAscending ? .orderedDescending : .orderedAscending
        } else {
            //if not, then start with ascending
            sortOrder = .orderedAscending
        }
        
        //remember the last key by which we sorted
        lastSortKey = key
        
        switch key {
        case .when:
            self.roastLogs = self.roastLogs.sorted(by: {prev, next in
                guard let prev = prev.date, let next = next.date else {return false}
                return prev.compare(next) == sortOrder
            })
        case .who:
            self.roastLogs = self.roastLogs.sorted(by: {prev, next in
                guard let prev = prev.roaster, let next = next.roaster else {return false}
                return prev.compare(next) == sortOrder
            })
        case .coffee:
            self.roastLogs = self.roastLogs.sorted(by: {prev, next in
                
                //these are just the identifiers
                guard let prevId = prev.bean, let nextId = next.bean else {return false}
                
                //these are the actual bean names
                guard let prev = RoastLogDatabase.shared.beans[prevId]?.name,
                    let next = RoastLogDatabase.shared.beans[nextId]?.name else {return false}
                return prev.compare(next) == sortOrder
            })
        case .profile:
            self.roastLogs = self.roastLogs.sorted(by: {prev, next in
                
                //these are just the identifiers
                guard let prevId = prev.profile, let nextId = next.profile else {return false}
                
                //these are the actual bean names
                guard let prev = RoastLogDatabase.shared.profiles[prevId]?.name,
                    let next = RoastLogDatabase.shared.profiles[nextId]?.name else {return false}
                return prev.compare(next) == sortOrder
            })
        case .green:
            self.roastLogs = self.roastLogs.sorted(by: {prev, next in
                guard let prev = prev.inputWeight?.doubleValue, let next = next.inputWeight?.doubleValue else {return false}
                return sortOrder == .orderedAscending ? (prev < next) : (prev > next)
            })
        case .charge:
            self.roastLogs = self.roastLogs.sorted(by: {prev, next in
                
                //these are just the identifiers
                guard let prevId = prev.profile, let nextId = next.profile else {return false}
                
                //these are the preheat temperatures //@fixme - asBWRoastProfile makes this incredibly expensive operation
                guard let prev = RoastLogDatabase.shared.profiles[prevId]?.asBWRoastProfile?.actualPreheat,
                    let next = RoastLogDatabase.shared.profiles[nextId]?.asBWRoastProfile?.actualPreheat else {return false}
                
                return sortOrder == .orderedAscending ? (prev < next) : (prev > next)
            })
        case .time:
            self.roastLogs = self.roastLogs.sorted(by: {prev, next in
                
                //these are just the identifiers
                guard let prevId = prev.profile, let nextId = next.profile else {return false}
                
                //these are the preheat temperatures //@fixme - asBWRoastProfile makes this incredibly expensive operation
                guard let prev = RoastLogDatabase.shared.profiles[prevId]?.asBWRoastProfile?.duration,
                    let next = RoastLogDatabase.shared.profiles[nextId]?.asBWRoastProfile?.duration else {return false}
                
                return sortOrder == .orderedAscending ? (prev < next) : (prev > next)
            })
        case .roast:
            self.roastLogs = self.roastLogs.sorted(by: {prev, next in
                guard let prev = prev.outputWeight?.doubleValue, let next = next.outputWeight?.doubleValue else {return false}
                return sortOrder == .orderedAscending ? (prev < next) : (prev > next)
            })
        case .loss: break //it is all fixed right now, so take no action
        case .favorite:
            self.roastLogs = self.roastLogs.sorted(by: {prev, next in
                return sortOrder == .orderedAscending ? (prev.isFavorite && !next.isFavorite) : (!prev.isFavorite && next.isFavorite)
            })
        }
    }
    
    var isFavorite: Bool {
        return self.favorite?.boolValue ?? false
    }
    
    
    func bwMeasurements() -> [BWRoastLogMeasurement]? {
        guard let measurements = measurements ?? data?.measurements else {return nil}
        return JSON(parseJSON: measurements).array?.map{$0.dictionary}.flatMap{$0}.map{try? BWRoastLogMeasurement.mapFromJSON($0)}.flatMap{$0}.sorted {prev, next in prev.time < next.time}
    }
}
