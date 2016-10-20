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
    var indexPaths: [NSIndexPath]

    init(indexPaths: [NSIndexPath]) {
        self.indexPaths = indexPaths
    }

    func hideBehaviorDataSource(shouldHideItemAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        return indexPaths.contains(indexPath)
    }
}

class FixedStickyLayoutBehaviorDataSource: StickyLayoutBehaviorDataSource {
    let indexPaths: [NSIndexPath]

    init(indexPaths: [NSIndexPath]) {
        self.indexPaths = indexPaths
    }

    func stickyLayoutBehavior(stickyLayoutBehavior: StickyLayoutBehavior, shouldStickItemAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        return indexPaths.contains(indexPath)
    }
}

class FixedStickyWithMinimumLayoutBehaviorDataSource: MinimumStickyLayoutBehaviorDataSource {
    let indexPaths: [NSIndexPath]
    let minStickingHeight: CGFloat?

    init(indexPaths: [NSIndexPath], minStickingHeight: CGFloat? = nil) {
        self.indexPaths = indexPaths
        self.minStickingHeight = minStickingHeight
    }

    func stickyLayoutBehavior(stickyLayoutBehavior: StickyLayoutBehavior, shouldStickItemAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        return indexPaths.contains(indexPath)
    }

    func stickyLayoutBehavior(stickyLayoutBehavior: StickyLayoutBehavior, minimumStickingHeightForItemAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGFloat? {
        return minStickingHeight
    }
}

class FixedStickyLayoutBehaviorDelegate: StickyLayoutBehaviorDelegate {
    var percentages: [NSIndexPath: CGFloat] = [:]

    func stickyLayoutBehavior(stickyLayoutBehavior: StickyLayoutBehavior, brickIsStickingWithPercentage percentage: CGFloat, forItemAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) {
        percentages[indexPath] = percentage
    }
}

class FixedMaxZIndexLayoutBehaviorDataSource: MaxZIndexLayoutBehaviorDataSource {
    let indexPaths: [NSIndexPath]

    init(indexPaths: [NSIndexPath]) {
        self.indexPaths = indexPaths
    }

    func maxZIndexLayoutBehavior(behavior: MaxZIndexLayoutBehavior, shouldHaveMaxZIndexAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool {
        return indexPaths.contains(indexPath)
    }
}

class FixedSetZIndexLayoutBehaviorDataSource: SetZIndexLayoutBehaviorDataSource {
    let indexPaths: [NSIndexPath: Int]

    init(indexPaths: [NSIndexPath: Int]) {
        self.indexPaths = indexPaths
    }

    func setZIndexLayoutBehavior(behavior: SetZIndexLayoutBehavior, shouldHaveMaxZIndexAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Int? {
        return indexPaths[indexPath]
    }
}


