//
//  Behaviors.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import Foundation
@testable import BrickKit

class DummyLayoutBehavior: BrickLayoutBehavior {

}

class FixedHideBehaviorDataSource: HideBehaviorDataSource {
    var indexPaths: [IndexPath]

    init(indexPaths: [IndexPath]) {
        self.indexPaths = indexPaths
    }

    func hideBehaviorDataSource(shouldHideItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        return indexPaths.contains(indexPath)
    }
}

class FixedStickyLayoutBehaviorDataSource: StickyLayoutBehaviorDataSource {
    let indexPaths: [IndexPath]

    init(indexPaths: [IndexPath]) {
        self.indexPaths = indexPaths
    }

    func stickyLayoutBehavior(_ stickyLayoutBehavior: StickyLayoutBehavior, shouldStickItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        return indexPaths.contains(indexPath)
    }
}

class FixedStickyWithMinimumLayoutBehaviorDataSource: MinimumStickyLayoutBehaviorDataSource {
    let indexPaths: [IndexPath]
    let minStickingHeights: [IndexPath: CGFloat?]

    convenience init(indexPaths: [IndexPath], minStickingHeight: CGFloat? = nil) {
        var heights = [IndexPath: CGFloat?]()
        for indexPath in indexPaths {
            heights[indexPath] = minStickingHeight
        }
        self.init(indexPaths: indexPaths, minStickingHeights: heights)
    }

    init(indexPaths: [IndexPath], minStickingHeights: [IndexPath: CGFloat?]) {
        self.indexPaths = indexPaths
        self.minStickingHeights = minStickingHeights
    }

    func stickyLayoutBehavior(_ stickyLayoutBehavior: StickyLayoutBehavior, shouldStickItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        return indexPaths.contains(indexPath)
    }

    func stickyLayoutBehavior(_ stickyLayoutBehavior: StickyLayoutBehavior, minimumStickingHeightForItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGFloat? {
        if let height = minStickingHeights[indexPath] {
            return height
        } else {
            return nil
        }
    }
}

class FixedStickyLayoutBehaviorDelegate: StickyLayoutBehaviorDelegate {
    var percentages: [IndexPath: CGFloat] = [:]

    func stickyLayoutBehavior(_ stickyLayoutBehavior: StickyLayoutBehavior, brickIsStickingWithPercentage percentage: CGFloat, forItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) {
        percentages[indexPath] = percentage
    }
}

class FixedMaxZIndexLayoutBehaviorDataSource: MaxZIndexLayoutBehaviorDataSource {
    let indexPaths: [IndexPath]

    init(indexPaths: [IndexPath]) {
        self.indexPaths = indexPaths
    }

    func maxZIndexLayoutBehavior(_ behavior: MaxZIndexLayoutBehavior, shouldHaveMaxZIndexAt indexPath: IndexPath, with identifier: String, in collectionViewLayout: UICollectionViewLayout) -> Bool {
        return indexPaths.contains(indexPath)
    }
}

class FixedSetZIndexLayoutBehaviorDataSource: SetZIndexLayoutBehaviorDataSource {
    let indexPaths: [IndexPath: Int]

    init(indexPaths: [IndexPath: Int]) {
        self.indexPaths = indexPaths
    }

    func setZIndexLayoutBehavior(_ behavior: SetZIndexLayoutBehavior, shouldHaveMaxZIndexAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Int? {
        return indexPaths[indexPath]
    }
}


