//
//  Dictionary+BWUtils.swift
//  Bellwether-iOS
//
//  Created by Iurii Mozharovskyi on 4/7/16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation

func bw_dictionaryWithContentsOfFile(_ filePath: String) -> [String : AnyObject]? {
    return NSDictionary(contentsOfFile: filePath) as? [String : AnyObject]
}


extension Dictionary {
    
    static func bw_dictWithoutOptionalValues(dict: [Key : Value?]) -> Dictionary<Key, Value> {
        var result = Dictionary<Key, Value>()
        
        for (key, value) in dict {
            if let notOptionalValue = value {
                result[key] = notOptionalValue
            }
        }
        
        return result
    }
}
