//
//  ReadableSet.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 3/16/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import Foundation

extension String {
    
    func readableSet() -> String {
        return replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
    }
    
}
