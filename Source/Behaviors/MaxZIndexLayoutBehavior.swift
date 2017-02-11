//
//  MaxZIndexLayoutBehavior.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 7/8/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit

public protocol MaxZIndexLayoutBehaviorDataSource: class {
    func maxZIndexLayoutBehavior(_ behavior: MaxZIndexLayoutBehavior, shouldHaveMaxZIndexAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool
}

open class MaxZIndexLayoutBehavior: BrickLayoutBehavior {
    weak var dataSource: MaxZIndexLayoutBehaviorDataSource?

    var currentZIndex: Int = 0

    public init(dataSource: MaxZIndexLayoutBehaviorDataSource) {
        self.dataSource = dataSource
    }

    open override func resetRegisteredAttributes(_ collectionViewLayout: UICollectionViewLayout) {
        super.resetRegisteredAttributes(collectionViewLayout)
        currentZIndex = 0
    }

    open override func registerAttributes(_ attributes: BrickLayoutAttributes, forCollectionViewLayout collectionViewLayout: UICollectionViewLayout) {
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
