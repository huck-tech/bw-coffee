//
//  DateFormatter+Utility.swift
//  Bellwether-iOS
//
//  Created by Vjacheslav Volodko on 04.11.16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation


extension DateFormatter {
    
    // MARK: - "01:01"
    
    static var bw_timeFormatterMinSec: DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .none
        dateformatter.dateFormat = "mm:ss"
        return dateformatter
    }
    
    static func bw_formattedMinSec(from seconds: TimeInterval) -> String {
        return bw_timeFormatterMinSec.string(from: bw_date(from: seconds))
    }
    
    static func bw_date(from seconds: TimeInterval) -> Date {
        return Date(timeIntervalSince1970: seconds)
    }
    
    // MARK: - 01/01/16 for 01 jan 2016 11:44 PM
    
    static var bw_dateFormatter: DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.timeStyle = .none
        dateformatter.dateStyle = .short
        
        return dateformatter
    }
    
    static func bw_formattedDate(_ date: Date) -> String {
        return bw_dateFormatter.string(from: date)
    }
    
    // MARK: - 11:44 PM for 01 jan 2016 11:44 PM
    
    static var bw_timeFormatter: DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.timeStyle = .short
        dateformatter.dateStyle = .none
        return dateformatter
    }
    
    static func bw_formattedTime(_ time: Date) -> String {
        return bw_timeFormatter.string(from: time)
    }
}

extension Date {
    var bw_formattedDate: String {
        return DateFormatter.bw_formattedDate(self)
    }
}

class BWTimeFormatter: Formatter {
    
    private let dateComponenetsFormatter: DateComponentsFormatter
    
    init(dateComponenetsFormatter formatter: DateComponentsFormatter) {
        dateComponenetsFormatter = formatter
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let formatter = DateComponentsFormatter(coder: aDecoder) {
            dateComponenetsFormatter = formatter
        } else {
            return nil
        }
        super.init(coder: aDecoder)
    }
    
    override func string(for obj: Any?) -> String? {
        if let seconds = obj as? NSNumber {
            if seconds == 0 {return "0:00"}
            return dateComponenetsFormatter.string(from: seconds.doubleValue)
        } else if let dateComponents = obj as? DateComponents {
            return dateComponenetsFormatter.string(from: dateComponents)
        } else {
            return nil
        }
    }
}
