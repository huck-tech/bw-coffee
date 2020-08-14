//
//  ProfileUpdateHandler.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 12/27/17.
//  Copyright © 2017 Bellwether Coffee. All rights reserved.
//

import Foundation

class ProfileUpdateHandler {
    
    private var profileUpdateCallbacks = [((SidebarProfileInfo) -> Void)?]()
    
    func listen(callback: ((SidebarProfileInfo) -> Void)?) {
        profileUpdateCallbacks.append(callback)
    }
    
    func update(profile: SidebarProfileInfo) {
        profileUpdateCallbacks.forEach { $0?(profile) }
    }
    
}
