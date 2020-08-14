//
//  Price.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/23/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

extension Double {
    
    func formattedPrice() -> String {
        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency
        return priceFormatter.string(for: self) ?? ""
    }
    
}
