//
//  MaxZIndexLayoutBehavior.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 7/8/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit

public protocol MaxZIndexLayoutBehaviorDataSource: class {
    func maxZIndexLayoutBehavior(_ behavior: MaxZIndexLayoutBehavior, shouldHaveMaxZIndexAt indexPath: IndexPath, with identifier: String, in collectionViewLayout: UICollectionViewLayout) -> Bool
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

    open override func registerAttributes(_ attributes: BrickLayoutAttributes, for collectionViewLayout: UICollectionViewLayout) {
        let maxZIndex: Int

        if let layout = collectionViewLayout as? BrickLayout {
            maxZIndex = layout.maxZIndex + 1
        } else {
           maxZIndex = 0
        }
        
        if dataSource?.maxZIndexLayoutBehavior(self, shouldHaveMaxZIndexAt: attributes.indexPath, with: attributes.identifier, in: collectionViewLayout) == true {
            attributes.zIndex = maxZIndex + currentZIndex
            currentZIndex += 1
        }
    }
}
