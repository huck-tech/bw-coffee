//
//  User.swift
//  api-playground
//
//  Created by Gabriel Pierannunzi on 2/28/18.
//  Copyright © 2018 Gabriel Pierannunzi. All rights reserved.
//

import Foundation

struct User: Codable {
    let id: String?
    let name: String?
    let email: String?
    let password: String?
    let cafe: String?
}
