//
//  OffsetLayoutBehavior.swift
//  BrickKit
//
//  Created by Justin Shiiba on 6/8/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import UIKit

public protocol OffsetLayoutBehaviorDataSource: class {
    func offsetLayoutBehavior(behavior: OffsetLayoutBehavior, originOffsetForItemAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGSize?

    func offsetLayoutBehavior(behavior: OffsetLayoutBehavior, sizeOffsetForItemAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGSize?
}

public class OffsetLayoutBehavior: BrickLayoutBehavior {

    weak var dataSource: OffsetLayoutBehaviorDataSource?

    private(set) var offsetZIndex = 100

    var offsetAttributes: [BrickLayoutAttributes] = []

    public init(dataSource: OffsetLayoutBehaviorDataSource) {
        self.dataSource = dataSource
    }

    public override func resetRegisteredAttributes(collectionViewLayout: UICollectionViewLayout) {
        super.resetRegisteredAttributes(collectionViewLayout)
        offsetAttributes = []
    }

    public override func registerAttributes(attributes: BrickLayoutAttributes, forCollectionViewLayout collectionViewLayout: UICollectionViewLayout) {
        if let _ = dataSource?.offsetLayoutBehavior(self, originOffsetForItemAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier, inCollectionViewLayout: collectionViewLayout) {
            offsetAttributes.append(attributes)
        }

        if let _ = dataSource?.offsetLayoutBehavior(self, sizeOffsetForItemAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier, inCollectionViewLayout: collectionViewLayout) {
            offsetAttributes.append(attributes)
        }
    }

    public override func invalidateInCollectionViewLayout(collectionViewLayout: UICollectionViewLayout, inout contentSize: CGSize, attributesDidUpdate: (attributes: BrickLayoutAttributes, oldFrame: CGRect?) -> Void) {
        offsetAttributesInCollectionView(collectionViewLayout, attributesDidUpdate: attributesDidUpdate)
    }

    private func offsetAttributesInCollectionView(collectionViewLayout: UICollectionViewLayout, attributesDidUpdate: (attributes: BrickLayoutAttributes, oldFrame: CGRect?) -> Void) {
        guard let _ = collectionViewLayout.collectionView where !offsetAttributes.isEmpty else {
            return
        }

        for attributes in offsetAttributes {

            // Only set attribute's Offset once
            guard !attributes.hidden else {
                continue
            }

            let oldFrame = attributes.frame
            var currentFrame = attributes.originalFrame
            if let sizeOffset = dataSource?.offsetLayoutBehavior(self, sizeOffsetForItemAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier, inCollectionViewLayout: collectionViewLayout) {
                currentFrame.size = CGSize(width: currentFrame.size.width + sizeOffset.width, height: currentFrame.size.height + sizeOffset.height)
            }

            if let originOffset = dataSource?.offsetLayoutBehavior(self, originOffsetForItemAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier, inCollectionViewLayout: collectionViewLayout) {
                currentFrame.offsetInPlace(dx: originOffset.width, dy: originOffset.height)
            }

            if currentFrame != attributes.frame {
                attributes.frame = currentFrame
                attributesDidUpdate(attributes: attributes, oldFrame: oldFrame)
            }
        }
    }
}
