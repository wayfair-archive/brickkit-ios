//
//  Swizzle.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/26/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import Foundation

// Allow tests to `swizzle` methods to methods that are unreachable, so we can simulate device behaviors

extension NSObject {

    class func swizzleMethodSelector(_ origSelector: Selector, withSelector: Selector, forClass:AnyClass!) -> Bool {

        var originalMethod: Method?
        var swizzledMethod: Method?

        originalMethod = class_getInstanceMethod(forClass, origSelector)
        swizzledMethod = class_getInstanceMethod(forClass, withSelector)

        if (originalMethod != nil && swizzledMethod != nil) {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
            return true
        }
        return false
    }

    class func swizzleStaticMethodSelector(_ origSelector: Selector, withSelector: Selector, forClass:AnyClass!) -> Bool {

        var originalMethod: Method?
        var swizzledMethod: Method?

        originalMethod = class_getClassMethod(forClass, origSelector)
        swizzledMethod = class_getClassMethod(forClass, withSelector)

        if (originalMethod != nil && swizzledMethod != nil) {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
            return true
        }
        return false
    }

}
