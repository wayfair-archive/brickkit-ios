//
//  MaxZIndexLayoutBehavior.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 7/8/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit

public protocol MaxZIndexLayoutBehaviorDataSource {
    func maxZIndexLayoutBehavior(behavior: MaxZIndexLayoutBehavior, shouldHaveMaxZIndexAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool
}

public class MaxZIndexLayoutBehavior: BrickLayoutBehavior {
    let dataSource: MaxZIndexLayoutBehaviorDataSource

    var maxZIndex: Int = 0
    var currentZIndex: Int = 0

    public init(dataSource: MaxZIndexLayoutBehaviorDataSource) {
        self.dataSource = dataSource
    }

    public override func resetRegisteredAttributes(collectionViewLayout: UICollectionViewLayout) {
        super.resetRegisteredAttributes(collectionViewLayout)
        currentZIndex = 0
        if let layout = collectionViewLayout as? BrickLayout {
            maxZIndex = layout.maxZIndex + 1
        }
    }

    public override func registerAttributes(attributes: BrickLayoutAttributes, forCollectionViewLayout collectionViewLayout: UICollectionViewLayout) {
        if dataSource.maxZIndexLayoutBehavior(self, shouldHaveMaxZIndexAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier, inCollectionViewLayout: collectionViewLayout) {
            attributes.zIndex = maxZIndex + currentZIndex
            currentZIndex += 1
        }
    }
}
