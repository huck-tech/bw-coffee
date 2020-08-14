//
//  Auth.swift
//  api-playground
//
//  Created by Gabriel Pierannunzi on 3/2/18.
//  Copyright © 2018 Gabriel Pierannunzi. All rights reserved.
//

import Foundation
import OneSignal

enum AuthError {
    case none
    case noToken
    case wrongEmailOrPassword
}

struct AuthResponse {
    let token: String?
    let user: [String: Any]?
}

class Auth {
    
    var profileUpdateHandler = ProfileUpdateHandler()
    
    var authToken: String? {
        didSet { updateAuthToken() }
    }
    
    private var cafes: [String]?
    
    var cafe: String? {
        return self.cafes?.first
    }
    
    var currentProfileInfo: SidebarProfileInfo?
    
    var isBellwetherUser: Bool {
        let cafeId = AppDelegate.isProduction ? "5b79d2108ef3db4c4d9c5ce5" : "5a999dfdfc99afb44b40f86f"
        return self.cafe == cafeId
    }
    
    var isHive: Bool {
        return self.cafe == "5b79d2e58ef3db4c4d9c5ce7"
    }
    
    var isSweetBar: Bool {
        return self.cafe == "5bdf74c977c4771e5716295e"
    }
    
    var isFirebrand: Bool {
        return self.cafe == "5c0034953a991936109ed439"
    }
    
    func update(token: String, user: [String:Any]){
        self.authToken = token
        
        //also store the authToken in Keychain
        Defaults.shared.set(authToken: token)
        Defaults.shared.set(userInfo: user)
        
        self.cafes = user["cafes"] as? [String]
        
        let name = user["name"] as? String
        let email = user["email"] as? String
        let profilePhoto = user["profilePhoto"] as? String
        
        let profileInfo = SidebarProfileInfo(title: name, subtitle: email, profilePhoto: profilePhoto, action: nil)
        self.currentProfileInfo = profileInfo
        
        self.profileUpdateHandler.update(profile: profileInfo)
    }
    
    func signIn(email: String, password: String, completion: @escaping (AuthError) -> Void) {
        let signInData = ["email": email, "password": password]
        
        SpeedyNetworking.postData(route: "/auth/signIn", data: signInData) { response in
            guard response.success else {
                return completion(.wrongEmailOrPassword)
            }
            
            guard let result = response.jsonResults(model: [String: Any].self) else {
                return completion(.noToken)
            }
            
            guard let token = result["token"] as? String, let user = result["userInfo"] as? [String: Any] else {
                return completion(.noToken)
            }
            
            self.update(token: token, user: user)

            completion(.none)
        }
    }
    
    func updateAuthToken() {
        guard let updatedAuthToken = authToken else { return }
        SpeedyNetworking.setAuthHeader(authorization: updatedAuthToken)
    }
    
    var pushId: String {
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        return status.subscriptionStatus.userId
    }
    
}
