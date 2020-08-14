//
//  BWAbstractLogger.swift
//  Bellwether-iOS
//
//  Created by Iurii Mozharovskyi on 3/9/16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

// BWLogger isn't implemented as protocol, because logging functions need parameters with default values.
// Path, function, line are inserted at compile time

class BWLogger {
    func verbose(_ message: Any, _ path: String = #file, _ function: String = #function, _ line: Int = #line) {
        assertionFailure("Should be implemented in subclasses")
    }
    
    func debug(_ message: Any, _ path: String = #file, _ function: String = #function, _ line: Int = #line) {
        assertionFailure("Should be implemented in subclasses")
    }
    
    func info(_ message: Any, _ path: String = #file, _ function: String = #function, _ line: Int = #line) {
        assertionFailure("Should be implemented in subclasses")
    }
    
    func warning(_ message: Any, _ path: String = #file, _ function: String = #function, _ line: Int = #line) {
        assertionFailure("Should be implemented in subclasses")
    }
    
    func error(_ message: Any, _ path: String = #file, _ function: String = #function, _ line: Int = #line) {
        assertionFailure("Should be implemented in subclasses")
    }
    
    func flushLog() {
        assertionFailure("Should be implemented in subclasses")
    }
}

protocol BWLoggerContainer {
    var logger: BWLogger? { get set }
}
