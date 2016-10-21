//
//  FatalError.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/1/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import Foundation

// overrides Swift global `fatalError`
@noreturn func fatalError(@autoclosure message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    FatalErrorUtil.fatalErrorClosure(message(), file, line)
}

@noreturn func swiftFatalError(message: String = "", file: StaticString = #file, line: UInt = #line) {
    Swift.fatalError(message, file: file, line: line)
}

/// Utility functions that can replace and restore the `fatalError` global function.
struct FatalErrorUtil {

    // Called by the custom implementation of `fatalError`.
    private static var fatalErrorClosure: @noreturn (String, StaticString, UInt) -> () = swiftFatalError

    /// Replace the `fatalError` global function with something else.
    static func replaceFatalError(closure: @noreturn (String, StaticString, UInt) -> ()) {
        fatalErrorClosure = closure
    }

    /// Restore the `fatalError` global function back to the original Swift implementation
    static func restoreFatalError() {
        fatalErrorClosure = swiftFatalError
    }
}
