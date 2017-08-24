//
//  BrickLogger.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 8/23/17.
//  Copyright © 2017 Wayfair. All rights reserved.
//

import UIKit

public protocol BrickLoggable {
    func logError(message: @escaping @autoclosure() -> String, file: String, lineNumber: Int, function: String)
    func logVerbose(message: @escaping @autoclosure() -> String, file: String, lineNumber: Int, function: String)
    func logWarning(message: @escaping @autoclosure() -> String, file: String, lineNumber: Int, function: String)
}

public class BrickLogger {
    public static var logger: BrickLoggable?

    internal static func logError(message: @escaping @autoclosure() -> String, file: String = #file, on lineNumber: Int = #line, function: String = #function) {
        BrickLogger.logger?.logError(message: message, file: file, lineNumber: lineNumber, function: function)
    }

    internal static func logVerbose(message: @escaping @autoclosure() -> String, file: String = #file, on lineNumber: Int = #line, function: String = #function) {
        BrickLogger.logger?.logVerbose(message: message, file: file, lineNumber: lineNumber, function: function)
    }

    internal static func logWarning(message: @escaping @autoclosure() -> String, file: String = #file, on lineNumber: Int = #line, function: String = #function) {
        BrickLogger.logger?.logWarning(message: message, file: file, lineNumber: lineNumber, function: function)
    }
}

public class BrickConsoleLogger: BrickLoggable {
    let logVerbose: Bool
    let loggingFunction: (String) -> Void

    public init(logVerbose: Bool = false, loggingFunction: @escaping (String) -> Void = { message in print(message)}) {
        self.logVerbose = logVerbose
        self.loggingFunction = loggingFunction
    }

    public func logError(message: @escaping @autoclosure() -> String, file: String, lineNumber: Int, function: String) {
        loggingFunction("ERROR [\((file as NSString).lastPathComponent):\(lineNumber)]: \(message())")
    }

    public func logVerbose(message: @escaping @autoclosure() -> String, file: String, lineNumber: Int, function: String) {
        if logVerbose {
            loggingFunction("VERBOSE [\((file as NSString).lastPathComponent):\(lineNumber)]: \(message())")
        }
    }

    public func logWarning(message: @escaping @autoclosure() -> String, file: String, lineNumber: Int, function: String) {
        loggingFunction("WARNING [\((file as NSString).lastPathComponent):\(lineNumber)]: \(message())")
    }
    
}
