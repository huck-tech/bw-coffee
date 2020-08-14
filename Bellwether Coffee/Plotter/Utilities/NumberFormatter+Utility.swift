//
//  NSNumberFormatter+Utility.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 11.04.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation


extension NumberFormatter {
    
    // MARK: - Weight
    
    static var bw_weightNumberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter
    }
    
    static func bw_formattedWeight(with format: String, value: NSNumber) -> String {
        return bw_formattedStringWithFormatter(bw_weightNumberFormatter, format: format, value: value)
    }
    
    static func bw_formattedWeight(_ value: BWWeight) -> String {
        return bw_formattedStringWithFormatter(bw_weightNumberFormatter,
                                               format: NSLocalizedString("DEFAULT_WEIGHT_FORMAT", comment: ""),
                                               value: NSNumber(value: value))
    }
    
    // MARK: - Currency
    
    static var bw_currencyNumberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }
    
    static func bw_formattedCurrecy(with format: String, value: BWCurrency) -> String {
        return bw_formattedStringWithFormatter(bw_currencyNumberFormatter, format: format, value: value)
    }
    
    static func bw_formattedCurrecy(_ value: BWCurrency) -> String {
        return bw_formattedCurrecy(with: NSLocalizedString("DEFAULT_COST_FORMAT", comment: ""),
                                   value: value)
    }
    
    // MARK: - Temperature
    
    static var bw_temperatureNumberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.positiveSuffix = "°"
        formatter.negativeSuffix = "°"
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }
    
    static func bw_formattedTemperature(_ value: BWTemperature) -> String {
        let fValue = (value * 9/5) + 32
        return bw_temperatureNumberFormatter.string(from: NSNumber(value: fValue)) ?? ""
    }
    
    static func bw_formattedTemperatureNoConversion(_ value: BWTemperature) -> String {
        return bw_temperatureNumberFormatter.string(from: NSNumber(value: value)) ?? ""
    }
    
    // MARK: - Seconds
    
    static var bw_secondsNumberFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .dropLeading
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        return formatter
    }
    
    static func bw_formattedSeconds(_ value: TimeInterval) -> String {
        return bw_secondsNumberFormatter.string(from: value) ?? ""
    }
    
    // MARK: - Minutes in seconds
    
    static var bw_minutesInSecondsNumberFormatter: Formatter {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .dropLeading
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        return BWTimeFormatter(dateComponenetsFormatter: formatter)
    }
    
    static func bw_formattedMinutesInSeconds(_ value: TimeInterval) -> String {
        return bw_minutesInSecondsNumberFormatter.string(for: value) ?? ""
    }
    
    // MARK: - Humidity
    
    static var bw_humidityNumberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }
    
    static func bw_formattedHumidity(_ value: BWHumidity) -> String {
        return bw_humidityNumberFormatter.string(for: value) ?? ""
    }
    
    
    // MARK: - Common
    
    fileprivate static func bw_formattedStringWithFormatter(_ formatter: NumberFormatter,
                                                        format: String,
                                                        value: NSNumber) -> String {
        if let formattedString = formatter.string(from: value) {
            return String(format: format, formattedString)
        } else {
            return String(format: format, value)
        }
    }
    
    fileprivate static var bw_decimalNumberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }
    
}
