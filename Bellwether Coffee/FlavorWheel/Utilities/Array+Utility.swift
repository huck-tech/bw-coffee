//
//  Array+Utility.swift
//  Bellwether-iOS
//
//  Created by Iurii Mozharovskyi on 4/4/16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation

func bw_isEqualArrays<Element: Equatable>(lhs: [Element]?, rhs: [Element]?) -> Bool {
    var result = false
    
    if let lhs = lhs, let rhs = rhs {
        result = lhs == rhs
    }
    
    return result
}

func bw_isEqualArraysOrNil<Element: Equatable>(lhs: [Element]?, rhs: [Element]?) -> Bool {
    var result = false
    
    if lhs == nil && rhs == nil {
        result = true
    } else {
        result = bw_isEqualArrays(lhs: lhs, rhs: rhs)
    }
    
    return result
}


extension Array {
    func bw_findFirst(_ isIncluded: (Element) throws -> Bool) rethrows -> Element? {
        let filteredArray = try filter(isIncluded)
        return filteredArray.first
    }
}


extension Array {
    func bw_insertionIndexOf(_ element: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
        var low = 0
        var high = count - 1
        while low <= high {
            let middle = (low + high) / 2
            if isOrderedBefore(self[middle], element) {
                low = middle + 1
            } else if isOrderedBefore(element, self[middle]) {
                high = middle - 1
            } else {
                return middle
            }
        }
        return low
    }
}


extension Array where Element: Hashable {
    func bw_contains(_ otherArray: Array<Element>) -> Bool {
        let selfSet = Set<Element>(self)
        let otherSet = Set<Element>(otherArray)
        return otherSet.isSubset(of: selfSet)
    }
}
