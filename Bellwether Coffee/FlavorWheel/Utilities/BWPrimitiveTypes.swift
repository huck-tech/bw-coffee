//
//  BWPrimitiveTypes.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 18.04.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation


typealias BWIdentifier = String


extension BWIdentifier {
    var bw_intIdentifierValue: Int {
        return Int(self)!
    }
}


extension Int {
    var identifierValue: BWIdentifier {
        return String(self)
    }
}


typealias BWCurrency = NSDecimalNumber


extension BWCurrency {
    class func setupCurrencyBehavior() {
        let handler = NSDecimalNumberHandler(roundingMode: .plain,
                                             scale: 2,
                                             raiseOnExactness: false,
                                             raiseOnOverflow: false,
                                             raiseOnUnderflow: false,
                                             raiseOnDivideByZero: true)
        NSDecimalNumber.defaultBehavior = handler
    }
}


extension Double {
    var currencyValue: BWCurrency {
        return BWCurrency(value: self as Double)
    }
}


class BWCurrencyTransform: BWJSONValueTransformer {
    
    func transformFromJSON(_ value: Double) throws -> BWCurrency {
        return value.currencyValue
    }
    
    func transformToJSON(_ value: BWCurrency) -> Double {
        return value.doubleValue
    }
}


func + (a: BWCurrency, b: BWCurrency) -> BWCurrency {
    return a.adding(b)
}

func - (a: BWCurrency, b: BWCurrency) -> BWCurrency {
    return a.subtracting(b)
}

func * (a: BWCurrency, b: BWCurrency) -> BWCurrency {
    return a.multiplying(by: b)
}

func / (a: BWCurrency, b: BWCurrency) -> BWCurrency {
    return a.dividing(by: b)
}

func <= (a: BWCurrency, b: BWCurrency) -> Bool {
    let result = a.compare(b)
    return result == .orderedAscending || result == .orderedSame
}

func < (a: BWCurrency, b: BWCurrency) -> Bool {
    return a.compare(b) == .orderedAscending
}

func * (a: Double, b: BWCurrency) -> BWCurrency {
    let aNumber = BWCurrency(value: a as Double)
    return aNumber * b
}

func * (a: Int, b: BWCurrency) -> BWCurrency {
    let aNumber = BWCurrency(value: a as Int)
    return aNumber * b
}


typealias BWTemperature = Double
typealias BWHumidity = Double
typealias BWWeight = Double


extension TimeInterval {
    static var bw_minRoastProfileDuration: TimeInterval { return 0.5 * 60.0 }
    static var bw_maxRoastProfileDuration: TimeInterval { return 15 * 60.0 }
}


extension BWTemperature {
    static var bw_minRoastTemperature: BWTemperature { return Roaster.AMBIENT_TEMPERATURE }
    static var bw_maxRoastTemperature: BWTemperature { return 450.0 }
}
