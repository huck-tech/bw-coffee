//
//  String+BWUtils.swift
//  Bellwether-iOS
//
//  Created by Iurii Mozharovskyi on 4/8/16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation

extension String {
    
    // MARK: - Path Utils
    
    func bw_stringByDeletingPathExtension() -> String {
        
        return (self as NSString).deletingPathExtension
    }
    
    // MARK: - Base 64
    
    func bw_base64Encodeded() -> String? {
        let data = self.data(using: String.Encoding.utf8)
        return data?.base64EncodedString(options: [])
    }
    
    func bw_base64Decoded() -> String? {
        if let data = Data(base64Encoded: self, options: []) {
            return String(data: data, encoding: String.Encoding.utf8)
        } else {
            return nil
        }
    }
    
    //shorthand for localized strings
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
