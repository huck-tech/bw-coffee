//
//  CreditCard.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 7/6/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

struct CreditCard {
    let number: String
    let cvc: String
    let expirationMonth: String
    let expirationYear: String
    let billingInfo: [String: Any]
}
