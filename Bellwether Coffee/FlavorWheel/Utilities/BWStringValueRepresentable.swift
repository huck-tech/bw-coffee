//
//  BWStringValueRepresentable.swift
//  Bellwether-iOS
//
//  Created by Iurii Mozharovskyi on 3/16/16.
//  Copyright © 2016 Bellwether. All rights reserved.
//


protocol BWStringValueRepresentable {
    var stringValue: String { get }
}


extension BWStringValueRepresentable where Self: BWStringValueRepresentable & RawRepresentable & Hashable {
    static var stringValues: [String] {
        var result = [String]()
        
        for value in bw_iterateEnum(Self.self) {
            result.append(value.stringValue)
        }
        
        return result
    }
    
    static var allStringValueRepresentableValues: [BWStringValueRepresentable] {
        return bw_enumAllValues(Self.self).map { $0 as BWStringValueRepresentable }
    }
}


extension Sequence where Iterator.Element: BWStringValueRepresentable {
    func joinStringValuesWithSeparator(_ separator: String) -> String {
        return map { $0.stringValue }.joined(separator: separator)
    }
}

extension String: BWStringValueRepresentable {
    var stringValue: String {
        return self
    }
}
