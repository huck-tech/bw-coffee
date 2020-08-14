//
//  RoastProfile.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/7/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

struct RoastProfile: Codable {
    let _id: String?       //the id of the roast profile    //NOT required as new ones do not have one
    let bean: String?       //the id of the bean            //required
    let name: String?       //name of the profile           //required
    let profile: String?    //the json of the profile       //required
    let privacy: String?    //"public" or "private"         //required
    let version: Int?       //the version number of the roast profile
}

enum Privacy: String {
    case isPublic = "public"
    case isPrivate = "private"
}
