//
//  CollectionViewDataSource.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import Foundation
@testable import BrickKit

class FixedRepeatCountDataSource: BrickRepeatCountDataSource {
    var repeatCountHash: [String: Int]

    init(repeatCountHash: [String: Int]) {
        self.repeatCountHash = repeatCountHash
    }

    func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
        return repeatCountHash[identifier] ?? 1
    }
}

#if os(tvOS)
    class MockCollectionViewFocusUpdateContext: UICollectionViewFocusUpdateContext {
        private var internalNextFocusedIndexPath: IndexPath = IndexPath(item: 0, section: 0)
        
        override var nextFocusedIndexPath: IndexPath {
            set(newIndex) {
                internalNextFocusedIndexPath = newIndex
            }
            get {
                return internalNextFocusedIndexPath
            }
        }
        
        private var internalPreviouslyFocusedIndexPath: IndexPath = IndexPath(item: 0, section: 0)
        
        override var previouslyFocusedIndexPath: IndexPath {
            set(newIndex) {
                internalPreviouslyFocusedIndexPath = newIndex
            }
            get {
                return internalPreviouslyFocusedIndexPath
            }
        }
    }

#endif
