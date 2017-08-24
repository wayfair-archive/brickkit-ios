//
//  BrickLogger.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 8/23/17.
//  Copyright © 2017 Wayfair. All rights reserved.
//

import UIKit

public class BrickLogger {
    public static var logger: BrickLoggable?

    internal static func logError(message: @escaping @autoclosure() -> String, file: String = #file, on lineNumber: Int = #line) {
        BrickLogger.logger?.logError(message: message, file: file, lineNumber: lineNumber)
    }

    internal static func logVerbose(message: @escaping @autoclosure() -> String, file: String = #file, on lineNumber: Int = #line) {
        BrickLogger.logger?.logVerbose(message: message, file: file, lineNumber: lineNumber)
    }

    internal static func logWarning(message: @escaping @autoclosure() -> String, file: String = #file, on lineNumber: Int = #line) {
        BrickLogger.logger?.logWarning(message: message, file: file, lineNumber: lineNumber)
    }
}

public protocol BrickLoggable {
    func logError(message: @escaping @autoclosure() -> String, file: String, lineNumber: Int)
    func logVerbose(message: @escaping @autoclosure() -> String, file: String, lineNumber: Int)
    func logWarning(message: @escaping @autoclosure() -> String, file: String, lineNumber: Int)
}

public class BrickConsoleLogger: BrickLoggable {
    let logVerbose: Bool

    public init(logVerbose: Bool = false) {
        self.logVerbose = logVerbose
    }

    public func logError(message: @escaping @autoclosure() -> String, file: String, lineNumber: Int) {
        print("ERROR [\((file as NSString).lastPathComponent):\(lineNumber)]: \(message())")
    }

    public func logVerbose(message: @escaping @autoclosure() -> String, file: String, lineNumber: Int) {
        if logVerbose {
            print("VERBOSE [\((file as NSString).lastPathComponent):\(lineNumber)]: \(message())")
        }
    }

    public func logWarning(message: @escaping @autoclosure() -> String, file: String, lineNumber: Int) {
        print("WARNING [\((file as NSString).lastPathComponent):\(lineNumber)]: \(message())")
    }

}
