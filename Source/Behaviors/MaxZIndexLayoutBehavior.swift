//
//  MaxZIndexLayoutBehavior.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 7/8/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit

public protocol MaxZIndexLayoutBehaviorDataSource: class {
    func maxZIndexLayoutBehavior(behavior: MaxZIndexLayoutBehavior, shouldHaveMaxZIndexAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool
}

public class MaxZIndexLayoutBehavior: BrickLayoutBehavior {
    weak var dataSource: MaxZIndexLayoutBehaviorDataSource?

    var currentZIndex: Int = 0

    public init(dataSource: MaxZIndexLayoutBehaviorDataSource) {
        self.dataSource = dataSource
    }

    public override func resetRegisteredAttributes(collectionViewLayout: UICollectionViewLayout) {
        super.resetRegisteredAttributes(collectionViewLayout)
        currentZIndex = 0
    }

    public override func registerAttributes(attributes: BrickLayoutAttributes, forCollectionViewLayout collectionViewLayout: UICollectionViewLayout) {
        let maxZIndex: Int

        if let layout = collectionViewLayout as? BrickLayout {
            maxZIndex = layout.maxZIndex + 1
        } else {
           maxZIndex = 0
        }
        
        if dataSource?.maxZIndexLayoutBehavior(self, shouldHaveMaxZIndexAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier, inCollectionViewLayout: collectionViewLayout) == true {
            attributes.zIndex = maxZIndex + currentZIndex
            currentZIndex += 1
        }
    }
}
