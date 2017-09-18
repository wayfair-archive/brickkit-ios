//
//  StickyLayoutBehavior.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/30/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import Foundation

private let stickyZIndex = 1000

public protocol StickyLayoutBehaviorDataSource: class {
    func stickyLayoutBehavior(_ behavior: StickyLayoutBehavior, shouldStickItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> Bool
}

public protocol StickyLayoutBehaviorDelegate: class {
    func stickyLayoutBehavior(_ behavior: StickyLayoutBehavior, brickIsStickingWithPercentage percentage: CGFloat, forItemAtIndexPath indexPath: IndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout)
}

/// A StickyLayoutBehavior will stick certain bricks (based on the dataSource) on the top of its section
open class StickyLayoutBehavior: BrickLayoutBehavior {
    weak var dataSource: StickyLayoutBehaviorDataSource?
    weak var delegate: StickyLayoutBehaviorDelegate?
    open var contentOffset: CGFloat
    var stickyAttributes: [BrickLayoutAttributes] = []

    fileprivate(set) var stickyZIndex = 1

    open var canStackWithOtherSections = false

    public init(dataSource: StickyLayoutBehaviorDataSource, delegate: StickyLayoutBehaviorDelegate? = nil, contentOffset: CGFloat = 0) {
        self.dataSource = dataSource
        self.delegate = delegate
        self.contentOffset = contentOffset
    }
    
    open override func hasInvalidatableAttributes() -> Bool {
        // Only return true if there is at least one attribute that's not hidden
        return stickyAttributes.contains { !$0.isHidden }
    }

    open override func resetRegisteredAttributes(_ collectionViewLayout: UICollectionViewLayout) {
        super.resetRegisteredAttributes(collectionViewLayout)
        stickyAttributes = []
    }

    open override func registerAttributes(_ attributes: BrickLayoutAttributes, for collectionViewLayout: UICollectionViewLayout) {
        if dataSource?.stickyLayoutBehavior(self, shouldStickItemAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier, inCollectionViewLayout: collectionViewLayout) == true {
            stickyAttributes.append(attributes)
        }
    }

    open override func invalidateInCollectionViewLayout(_ collectionViewLayout: UICollectionViewLayout, contentSize: inout CGSize, attributesDidUpdate: (_ attributes: BrickLayoutAttributes, _ oldFrame: CGRect?) -> Void) {
        updateStickyAttributesInCollectionView(collectionViewLayout, attributesDidUpdate: attributesDidUpdate)
    }

    func updateStickyAttributesInCollectionView(_ collectionViewLayout: UICollectionViewLayout, attributesDidUpdate: (_ attributes: BrickLayoutAttributes, _ oldFrame: CGRect?) -> Void) {
        var lastStickyFrame = CGRect()
        var section: Int = 0
        for (index, brickAttribute) in stickyAttributes.enumerated() {
            guard !brickAttribute.isHidden else {
                continue
            }
            let secAttributes: BrickLayoutAttributes? = sectionAttributes(for: brickAttribute.indexPath, in: collectionViewLayout)

            if !canStackWithOtherSections && section != brickAttribute.indexPath.section {
                section = brickAttribute.indexPath.section
                lastStickyFrame.origin = secAttributes?.frame.origin ?? CGPoint.zero
                lastStickyFrame.size = CGSize.zero
            }

            var brickAttributes = brickAttribute
            let oldFrame = brickAttributes.frame
            lastStickyFrame = self.updateStickyAttribute(&brickAttributes, sectionAttributes: secAttributes, inCollectionViewLayout: collectionViewLayout, withStickyIndex: index, withLastStickyFrame: lastStickyFrame)

            if oldFrame != brickAttributes.frame {
                attributesDidUpdate(brickAttributes, oldFrame)
            }
        }
    }

    fileprivate func updateStickyAttribute(_ attributes: inout BrickLayoutAttributes, sectionAttributes: BrickLayoutAttributes?, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout, withStickyIndex stickyIndex:Int, withLastStickyFrame lastStickyFrame: CGRect) -> CGRect {
        let collectionView = collectionViewLayout.collectionView!

        let shouldConstrain = updateFrameForAttribute(&attributes, sectionAttributes: sectionAttributes, lastStickyFrame: lastStickyFrame, contentBounds: collectionView.bounds, collectionViewLayout: collectionViewLayout)
        let containedInFrame = sectionAttributes.map({ $0.frame }) ?? CGRect(origin: CGPoint.zero, size: collectionViewLayout.collectionViewContentSize)
        if shouldConstrain && !containedInFrame.contains(attributes.frame) {
            //constain to top
            var originY = max(containedInFrame.origin.y, attributes.frame.origin.y)
            //constain to bottom
            originY = min(containedInFrame.maxY - attributes.frame.height, originY)

            //set origin
            attributes.frame.origin.y = originY
        }

        let stickingPercentage: CGFloat
        if lastStickyFrame == .zero || lastStickyFrame.origin.y > collectionView.contentOffset.y {
            stickingPercentage = (attributes.frame.origin.y - collectionView.contentOffset.y - collectionView.contentInset.top) / attributes.frame.height
        } else {
            stickingPercentage = (attributes.frame.origin.y - lastStickyFrame.maxY) / attributes.frame.height
        }
        self.delegate?.stickyLayoutBehavior(self, brickIsStickingWithPercentage: min(max(0, stickingPercentage), 1), forItemAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier, inCollectionViewLayout: collectionViewLayout)

        return attributes.frame
    }

    /// - returns: True is the attribute should be constrainted
    func updateFrameForAttribute(_ attributes:inout BrickLayoutAttributes, sectionAttributes: BrickLayoutAttributes?, lastStickyFrame: CGRect, contentBounds: CGRect, collectionViewLayout: UICollectionViewLayout) -> Bool {

        let topInset = collectionViewLayout.collectionView!.contentInset.top

        let stickyY: CGFloat = max(contentBounds.origin.y + topInset + contentOffset, lastStickyFrame.maxY)

        let minY = attributes.originalFrame.origin.y
        let y = max(minY, stickyY)

        attributes.frame.origin.y = y

        return true
    }

}
