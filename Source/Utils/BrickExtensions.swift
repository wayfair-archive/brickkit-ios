//
//  BrickExtensions.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/1/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import Foundation

extension Dictionary where Value : Equatable {
    func allKeysForValue(_ val : Value) -> [Key] {
        return self.filter { pair in pair.1 == val }.map { $0.0 }
    }
}
