//
//  Users.swift
//  api-playground
//
//  Created by Gabriel Pierannunzi on 3/1/18.
//  Copyright © 2018 Gabriel Pierannunzi. All rights reserved.
//

import Foundation

class Users {
    
    var currentUser: User?
    
    func createCafeAdmin(user: User, completion: @escaping (Bool) -> Void) {
        SpeedyNetworking.post(route: "/users/create/cafeAdmin", model: user) { response in
            completion(response.success)
        }
    }
    
    func assignCafeAdminCafes(userId: String, cafes: [String], completion: @escaping (Bool) -> Void) {
        let cafeData = ["cafes": cafes]
        
        SpeedyNetworking.postData(route: "/users/assign/cafeAdmin/cafes/\(userId)", data: cafeData) { response in
            completion(response.success)
        }
    }
    
    func changePassword(newPassword: String, completion: @escaping (Bool) -> Void) {
        let cafeData = ["newPass": newPassword]
        
        SpeedyNetworking.postData(route: "/users/changePassword", data: cafeData) { response in
            completion(response.success)
        }
    }
    
    func createMember(user: User, completion: @escaping (Bool) -> Void) {
        SpeedyNetworking.post(route: "/users/create/member", model: user) { response in
            completion(response.success)
        }
    }
    
    func permitManager(userId: String, permissions: [Permission], completion: @escaping (Bool) -> Void) {
        let permissionValues = permissions.map { permission -> Int in
            return permission.rawValue
        }
        
        let permissionData = ["permissions": permissionValues]
        
        SpeedyNetworking.postData(route: "/users/permit/manager/\(userId)", data: permissionData) { response in
            completion(response.success)
        }
    }
    
    func assignManager(userId: String, cafes: [String], completion: @escaping (Bool) -> Void) {
        let assignData = ["cafes": cafes]
        
        SpeedyNetworking.postData(route: "/users/assign/manager/cafes/\(userId)", data: assignData) { response in
            completion(response.success)
        }
    }
    
    func assignManager(userId: String, stores: [String], completion: @escaping (Bool) -> Void) {
        let assignData = ["stores": stores]
        
        SpeedyNetworking.postData(route: "/users/assign/manager/stores/\(userId)", data: assignData) { response in
            completion(response.success)
        }
    }
    
    func permitRepresentative(userId: String, permissions: [Permission], completion: @escaping (Bool) -> Void) {
        let permissionValues = permissions.map { permission -> Int in
            return permission.rawValue
        }
        
        let permissionData = ["permissions": permissionValues]
        
        SpeedyNetworking.postData(route: "/users/permit/representative/\(userId)", data: permissionData) { response in
            completion(response.success)
        }
    }
    
    func assignRepresentative(userId: String, cafes: [String], completion: @escaping (Bool) -> Void) {
        let assignData = ["cafes": cafes]
        
        SpeedyNetworking.postData(route: "/users/assign/representative/cafes/\(userId)", data: assignData) { response in
            completion(response.success)
        }
    }
    
    func assignRepresentative(userId: String, stores: [String], completion: @escaping (Bool) -> Void) {
        let assignData = ["stores": stores]
        
        SpeedyNetworking.postData(route: "/users/assign/representative/stores/\(userId)", data: assignData) { response in
            completion(response.success)
        }
    }
    
}
