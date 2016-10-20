//
//  CardLayoutBehavior.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/5/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

/// DataSource for the CardLayoutBehavior
public protocol CardLayoutBehaviorDataSource {

    /// If not nil, the small height is used to scroll the card layout
    ///
    /// - returns: small height for the brick
    func cardLayoutBehavior(behavior: CardLayoutBehavior, smallHeightForItemAtIndexPath indexPath: NSIndexPath, withIdentifier identifier: String, inCollectionViewLayout collectionViewLayout: UICollectionViewLayout) -> CGFloat?
}

/// A CardLayoutBehavior organizes bricks on top of eachother, with the top one full height and the other ones are staggered behind
/// - see CardLayoutBehaviorDataSource: The way to determine which bricks need to show
public class CardLayoutBehavior: BrickLayoutBehavior {
    let dataSource: CardLayoutBehaviorDataSource
    var scrollLastBrickToTop = true
    var scrollAttributes: [BrickLayoutAttributes] = []

    public init(dataSource: CardLayoutBehaviorDataSource) {
        self.dataSource = dataSource
    }

    public override func resetRegisteredAttributes(collectionViewLayout: UICollectionViewLayout) {
        super.resetRegisteredAttributes(collectionViewLayout)
        scrollAttributes = []
    }

    public override func registerAttributes(attributes: BrickLayoutAttributes, forCollectionViewLayout collectionViewLayout: UICollectionViewLayout) {
        if let _ = dataSource.cardLayoutBehavior(self, smallHeightForItemAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier, inCollectionViewLayout: collectionViewLayout) {
            scrollAttributes.append(attributes) // Only use the attributes that have a small-height
        }
    }
    
    public override func invalidateInCollectionViewLayout(collectionViewLayout: UICollectionViewLayout, inout contentSize: CGSize, attributesDidUpdate: (attributes: BrickLayoutAttributes, oldFrame: CGRect?) -> Void) {

        guard let collectionView = collectionViewLayout.collectionView where !scrollAttributes.isEmpty else {
            return
        }

        let offsetY = collectionView.contentOffset.y
        var previousAttributeWasInSpotlight = false
        var currentY: CGFloat = 0

        var currentScrollOffset: CGFloat = 0

        for (index, attributes) in scrollAttributes.enumerate() {
            let isAbove = attributes.originalFrame.maxY <= offsetY
            let isBelow = attributes.originalFrame.minY > offsetY
            let isInSpotlight = !isAbove && !isBelow

            guard let height = dataSource.cardLayoutBehavior(self, smallHeightForItemAtIndexPath: attributes.indexPath, withIdentifier: attributes.identifier, inCollectionViewLayout: collectionViewLayout) else {
                continue // Only use the attributes that have a small-height
            }

            let attributesOldFrame = attributes.frame
            var frame = attributesOldFrame
            if isInSpotlight {
                frame.origin.y = offsetY
                currentScrollOffset =  offsetY - attributes.originalFrame.origin.y
            } else if previousAttributeWasInSpotlight {
                frame.origin.y = attributes.originalFrame.origin.y
                currentY = min(attributes.originalFrame.maxY, attributes.frame.origin.y + currentScrollOffset + height)
            } else if isAbove {
                frame.origin.y = offsetY
            } else if isBelow {
                frame.origin.y = currentY
                if offsetY < 0 && index == 0 {
                    // If scolling is negative, take the max of the first one
                    currentY = frame.maxY
                } else {
                    currentY = frame.minY + height
                }
            }

            if offsetY > scrollAttributes.last?.originalFrame.origin.y {
                frame.origin.y = min(offsetY, attributes.originalFrame.minY)
            }

            attributes.frame = frame
            attributesDidUpdate(attributes: attributes, oldFrame: attributesOldFrame)

            previousAttributeWasInSpotlight = isInSpotlight && offsetY >= 0
        }

        if scrollLastBrickToTop {
            let lastAttribute = scrollAttributes.last! // Safe to force unwrap because the function has a `guard` on top that prevents to get into this code if the scrollAttributes are empty
            contentSize.height = lastAttribute.originalFrame.minY + collectionView.frame.height
        }
    }


}
