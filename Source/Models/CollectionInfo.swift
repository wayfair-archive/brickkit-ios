//
//  CollectionInfo.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/7/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import Foundation

/// Internal object to refer to a Collection Index + Identifier
struct CollectionInfo: Hashable {
    var index: Int
    var identifier: String

    var hashValue: Int {
        return index + identifier.hashValue
    }
}

extension CollectionInfo: Equatable {}

func ==(lhs: CollectionInfo, rhs: CollectionInfo) -> Bool {
    return lhs.index == rhs.index && lhs.identifier == rhs.identifier
}

