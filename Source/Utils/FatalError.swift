//
//  FatalError.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/1/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import Foundation

// overrides Swift global `fatalError`
//func fatalError(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> Never  {
//    FatalErrorUtil.fatalErrorClosure(message(), file, line)
//    unreachable()
//}
//
//// This is a `noreturn` function that pauses forever
//func unreachable() -> Never  {
//    repeat {
//        RunLoop.current.run()
//    } while (true)
//}
//
///// Utility functions that can replace and restore the `fatalError` global function.
//struct FatalErrorUtil {
//
//    // Called by the custom implementation of `fatalError`.
//    fileprivate static var fatalErrorClosure: (String, StaticString, UInt) -> Never = defaultFatalErrorClosure
//
//    // backup of the original Swift `fatalError`
//    fileprivate static let defaultFatalErrorClosure = { Swift.fatalError($0, file: $1, line: $2) }
//
//    /// Replace the `fatalError` global function with something else.
//    static func replaceFatalError(_ closure: @escaping (String, StaticString, UInt) -> Never) {
//        fatalErrorClosure = closure
//    }
//
//    /// Restore the `fatalError` global function back to the original Swift implementation
//    static func restoreFatalError() {
//        fatalErrorClosure = defaultFatalErrorClosure
//    }
//}
