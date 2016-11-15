//
//  SetZIndexLayoutBehavior.swift
//  BrickKit
//
//  Created by Anthony Gallo on 9/9/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit

/// An object that adopts the SetZIndexLayoutBehaviorDataSource protocol is responsible for providing the index offset that should be used for a brick with a given identifier or indexPath
public protocol SetZIndexLayoutBehaviorDataSource: class {
    func setZIndexLayoutBehavior(behavior: SetZIndexLayoutBehavior, shouldHaveMaxZIndexAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Int?
}

/// Allows a brick to have a different zIndex then the one assigned by the layout
public class SetZIndexLayoutBehavior: BrickLayoutBehavior {
    weak var dataSource: SetZIndexLayoutBehaviorDataSource?
    
    var maxZIndex: Int = 0
    
    public init(dataSource: SetZIndexLayoutBehaviorDataSource) {
        self.dataSource = dataSource
    }
    
    public override func resetRegisteredAttributes(collectionViewLayout: UICollectionViewLayout) {
        super.resetRegisteredAttributes(collectionViewLayout)
        if let flow = collectionViewLayout as? BrickFlowLayout {
            maxZIndex = flow.maxZIndex + 1
        }
    }

    public override func registerAttributes(attributes: BrickLayoutAttributes, forCollectionViewLayout collectionViewLayout: UICollectionViewLayout) {
        guard let offset = dataSource?.setZIndexLayoutBehavior(self, shouldHaveMaxZIndexAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier, inCollectionViewLayout: collectionViewLayout) else {
            return
        }
        attributes.zIndex = maxZIndex + offset
    }
}
