//
//  Lbs.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/24/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

extension Double {
    
    func formattedLbs(fractionDigits: Int = 0) -> String {
        let lbsFormatter = NumberFormatter()
        lbsFormatter.numberStyle = .decimal
        lbsFormatter.minimumFractionDigits = fractionDigits
        lbsFormatter.maximumFractionDigits = fractionDigits
        return lbsFormatter.string(for: self) ?? ""
    }
    
}
