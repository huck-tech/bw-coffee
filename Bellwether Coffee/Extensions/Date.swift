//
//  Date.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/24/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

extension String {
    
    var defaultDateFormat: String {
        get { return dateString(format: "MMMM d, yyyy") }
    }
    
    private var stringDate: Date? {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            return formatter.date(from: self)
        }
    }
    
    private func dateString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        guard let formatDate = stringDate else { return "" }
        return formatter.string(from: formatDate)
    }
    
}
