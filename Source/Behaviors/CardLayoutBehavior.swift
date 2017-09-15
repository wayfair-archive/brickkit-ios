//
//  CardLayoutBehavior.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/5/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

/// DataSource for the CardLayoutBehavior
public protocol CardLayoutBehaviorDataSource: class {

    /// If not nil, the small height is used to scroll the card layout
    ///
    /// - returns: small height for the brick
    func cardLayoutBehavior(_ behavior: CardLayoutBehavior, smallHeightForItemAt indexPath: IndexPath, with identifier: String, in collectionViewLayout: UICollectionViewLayout) -> CGFloat?
}

/// A CardLayoutBehavior organizes bricks on top of eachother, with the top one full height and the other ones are staggered behind
/// - see CardLayoutBehaviorDataSource: The way to determine which bricks need to show
open class CardLayoutBehavior: BrickLayoutBehavior {
    weak var dataSource: CardLayoutBehaviorDataSource?
    var scrollLastBrickToTop = true
    var scrollAttributes: [BrickLayoutAttributes] = []

    public init(dataSource: CardLayoutBehaviorDataSource) {
        self.dataSource = dataSource
    }
    
    open override func hasInvalidatableAttributes() -> Bool {
        // Only return true if there is at least one attribute that's not hidden
        return scrollAttributes.contains { !$0.isHidden }
    }

    open override func resetRegisteredAttributes(_ collectionViewLayout: UICollectionViewLayout) {
        super.resetRegisteredAttributes(collectionViewLayout)
        scrollAttributes = []
    }

    open override func registerAttributes(_ attributes: BrickLayoutAttributes, for collectionViewLayout: UICollectionViewLayout) {
        if let _ = dataSource?.cardLayoutBehavior(self, smallHeightForItemAt: attributes.indexPath, with: attributes.identifier, in: collectionViewLayout) {
            scrollAttributes.append(attributes) // Only use the attributes that have a small-height
        }
    }
    
    open override func invalidateInCollectionViewLayout(_ collectionViewLayout: UICollectionViewLayout, contentSize: inout CGSize, attributesDidUpdate: (_ attributes: BrickLayoutAttributes, _ oldFrame: CGRect?) -> Void) {

        guard let collectionView = collectionViewLayout.collectionView , !scrollAttributes.isEmpty else {
            return
        }

        let offsetY = collectionView.contentOffset.y
        var previousAttributeWasInSpotlight = false
        var currentY: CGFloat = 0

        var currentScrollOffset: CGFloat = 0

        for (index, attributes) in scrollAttributes.enumerated() {
            let isAbove = attributes.originalFrame.maxY <= offsetY
            let isBelow = attributes.originalFrame.minY > offsetY
            let isInSpotlight = !isAbove && !isBelow

            guard let height = dataSource?.cardLayoutBehavior(self, smallHeightForItemAt: attributes.indexPath, with: attributes.identifier, in: collectionViewLayout) else {
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

            if offsetY > (scrollAttributes.last?.originalFrame.origin.y)! {
                frame.origin.y = min(offsetY, attributes.originalFrame.minY)
            }

            attributes.frame = frame
            attributesDidUpdate(attributes, attributesOldFrame)

            previousAttributeWasInSpotlight = isInSpotlight && offsetY >= 0
        }

        if scrollLastBrickToTop {
            let lastAttribute = scrollAttributes.last! // Safe to force unwrap because the function has a `guard` on top that prevents to get into this code if the scrollAttributes are empty
            contentSize.height = lastAttribute.originalFrame.minY + collectionView.frame.height
        }
    }


}
