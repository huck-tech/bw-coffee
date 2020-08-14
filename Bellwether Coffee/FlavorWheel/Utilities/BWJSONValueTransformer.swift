//
//  BWJSONValueTransformer.swift
//  Bellwether-iOS
//
//  Created by Iurii Mozharovskyi on 6/9/16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation


protocol BWFromJSONValueTransformer {
    associatedtype Object
    associatedtype JSON
    func transformFromJSON(_ value: JSON) throws -> Object
}


protocol BWToJSONValueTransformer {
    associatedtype Object
    associatedtype JSON
    func transformToJSON(_ value: Object) -> JSON
}


protocol BWJSONValueTransformer: BWFromJSONValueTransformer, BWToJSONValueTransformer {}


extension BWFromJSONValueTransformer {
    func transformFromJSONOrNil(_ value: JSON?) throws -> Object? {
        guard let value = value else {
            return nil
        }
        
        return try transformFromJSON(value)
    }
    
    func transformArrayFromJSON(_ value: [JSON]) throws -> [Object] {
        return try value.map { json in
            return try transformFromJSON(json)
        }
    }
    
    func transformArrayFromJSONOrEmpty(_ value: [JSON]?) throws -> [Object] {
        guard let value = value else {
            return [Object]()
        }
        
        return try transformArrayFromJSON(value)
    }
}


extension BWToJSONValueTransformer {
    func transformToJSONOrNil(_ value: Object?) -> JSON? {
        guard let value = value else {
            return nil
        }
        
        return transformToJSON(value)
    }
    
    func transformArrayToJSON(_ array: [Object]) -> [JSON] {
        return array.map { object in self.transformToJSON(object) }
    }
}


class BWTransformOf<ObjectType, JSONType>: BWJSONValueTransformer {
    typealias Object = ObjectType
    typealias JSON = JSONType
    
    typealias FromJSON = (JSONType) throws -> ObjectType
    typealias ToJSON = (ObjectType) -> JSONType
    fileprivate let fromJSON: FromJSON
    fileprivate let toJSON: ToJSON
    
    init(fromJSON: @escaping FromJSON, toJSON: @escaping ToJSON) {
        self.fromJSON = fromJSON
        self.toJSON = toJSON
    }
    
    // MARK: BWJSONValueTransformer
    
    func transformFromJSON(_ value: JSONType) throws -> ObjectType {
        return try fromJSON(value)
    }
    
    func transformToJSON(_ value: ObjectType) -> JSONType {
        return toJSON(value)
    }
}


class BWEnumRawTransformer<EnumType: RawRepresentable>: BWJSONValueTransformer {
    func transformFromJSON(_ value: EnumType.RawValue) throws -> EnumType {
        guard let result = EnumType(rawValue: value) else {
            throw BWJSONMappableError.incorrectJSON
        }
        
        return result
    }
    
    func transformToJSON(_ value: EnumType) -> EnumType.RawValue {
        return value.rawValue
    }
}


class BWURLTransformer: BWJSONValueTransformer {
    func transformFromJSON(_ value: String) throws -> URL {
        guard let url = URL(string: value) else {
            throw BWJSONMappableError.incorrectJSON
        }
        
        return url
    }
    
    func transformToJSON(_ value: URL) -> String {
        return value.absoluteString
    }
}
