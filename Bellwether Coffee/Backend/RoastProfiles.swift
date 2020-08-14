//
//  RoastProfiles.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

class RoastProfiles {
    
    func getRoastProfiles(bean: String, completion: @escaping ([RoastProfile]?) -> Void) {
//        if let cached = RoastLogDatabase.shared.beanProfiles[bean] {
//            return completion(cached)
//        }
//        
        SpeedyNetworking.get(route: "/roast-profiles/list/\(bean)") { response in
            var roastProfiles = response.result(model: [RoastProfile].self)
            
            //we have the roast profiles, but now we need to filter them by version and cafe.

            if BellwetherAPI.auth.isHive {roastProfiles = roastProfiles?.filter {$0.version == 1}}
            if BellwetherAPI.auth.isSweetBar {roastProfiles = roastProfiles?.filter {$0.version == 2}}
            if BellwetherAPI.auth.isFirebrand {roastProfiles = roastProfiles?.filter {$0.version == 3}}
            
            //bellwether is editing v3 profiles when in production
            if BellwetherAPI.auth.isBellwetherUser && AppDelegate.isProduction {roastProfiles = roastProfiles?.filter {$0.version == 3}}

            completion(roastProfiles)
        }
    }
    
    func getRoastProfile(profile: String, completion: @escaping (RoastProfile?) -> Void) {
        SpeedyNetworking.get(route: "/roast-profiles/fetch/\(profile)") { response in
            let roastProfile = response.result(model: RoastProfile.self)
            completion(roastProfile)
        }
    }
    
    func create(profile: RoastProfile, completion: @escaping (Bool) -> Void) {
        SpeedyNetworking.post(route: "/roast-profiles/create", model: profile) { response in
            completion(response.success)
        }
    }
    
    func update(profile: String, update: RoastProfile, completion: @escaping (Bool) -> Void) {
        SpeedyNetworking.post(route: "/roast-profiles/update/\(profile)", model: update) { response in
            completion(response.success)
        }
    }
    
    func delete(profile: String, completion: @escaping (Bool) -> Void) {
        SpeedyNetworking.post(route: "/roast-profiles/delete/\(profile)", model: NullParams()) { response in
            completion(response.success)
        }
    }
}
