//
//  BWEnumUtils.swift
//  Bellwether-iOS
//
//  Created by Anna Yefremova on 16/03/2016.
//  Copyright © 2016 Bellwether. All rights reserved.
//


func bw_iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
    var i = 0
    return AnyIterator {
        let next = withUnsafePointer(to: &i) {
            $0.withMemoryRebound(to: T.self, capacity: 1) { $0.pointee }
        }
        
        let nextValue: T? = (next.hashValue == i) ? next : nil
        i += 1
        return nextValue
    }
}

func bw_enumAllValues<T: Hashable>(_: T.Type) -> [T] {
    var values = [T]()
    
    for value in bw_iterateEnum(T.self) {
        values.append(value)
    }
    
    return values
}
