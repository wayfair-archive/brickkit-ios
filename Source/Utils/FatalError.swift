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
    unreachable()
}

// This is a `noreturn` function that pauses forever
@noreturn func unreachable() {
    repeat {
        NSRunLoop.currentRunLoop().run()
    } while (true)
}

/// Utility functions that can replace and restore the `fatalError` global function.
struct FatalErrorUtil {

    // Called by the custom implementation of `fatalError`.
    private static var fatalErrorClosure: (String, StaticString, UInt) -> () = defaultFatalErrorClosure

    // backup of the original Swift `fatalError`
    private static let defaultFatalErrorClosure = { Swift.fatalError($0, file: $1, line: $2) }

    /// Replace the `fatalError` global function with something else.
    static func replaceFatalError(closure: (String, StaticString, UInt) -> ()) {
        fatalErrorClosure = closure
    }

    /// Restore the `fatalError` global function back to the original Swift implementation
    static func restoreFatalError() {
        fatalErrorClosure = defaultFatalErrorClosure
    }
}
