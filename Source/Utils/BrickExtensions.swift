//
//  BrickExtensions.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/1/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import Foundation

#if swift(>=4.2)
//TODO: Remove this, hack for Xcode 10
import UIKit.UIGeometry
extension UIEdgeInsets {
    internal static let zero = UIEdgeInsets()
}
#endif

extension Dictionary where Value : Equatable {
    func allKeysForValue(_ val : Value) -> [Key] {
        return self.filter { pair in pair.1 == val }.map { $0.0 }
    }
}
