//
//  BrickAppearBehavior.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/11/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import Foundation

public protocol BrickAppearBehavior: class {
    func configureAttributesForAppearing(_ attributes: UICollectionViewLayoutAttributes, in collectionView: UICollectionView)
    func configureAttributesForDisappearing(_ attributes: UICollectionViewLayoutAttributes, in collectionView: UICollectionView)
}

open class BrickAppearTopBehavior: BrickAppearBehavior {

    public init() {

    }

    open func configureAttributesForAppearing(_ attributes: UICollectionViewLayoutAttributes, in collectionView: UICollectionView) {
        attributes.frame.origin.y = -attributes.frame.height
    }

    open func configureAttributesForDisappearing(_ attributes: UICollectionViewLayoutAttributes, in collectionView: UICollectionView) {
        self.configureAttributesForAppearing(attributes, in: collectionView)
    }
    
}

open class BrickAppearBottomBehavior: BrickAppearBehavior {

    public init() {

    }
    
    open func configureAttributesForAppearing(_ attributes: UICollectionViewLayoutAttributes, in collectionView: UICollectionView) {
        attributes.frame.origin.y = max(collectionView.frame.height,  collectionView.contentSize.height)
    }

    open func configureAttributesForDisappearing(_ attributes: UICollectionViewLayoutAttributes, in collectionView: UICollectionView) {
        self.configureAttributesForAppearing(attributes, in: collectionView)
        attributes.alpha = 0
    }

}

open class BrickAppearScaleBehavior: BrickAppearBehavior {

    public init() {

    }

    open func configureAttributesForAppearing(_ attributes: UICollectionViewLayoutAttributes, in collectionView: UICollectionView) {
        attributes.alpha = 0
        attributes.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
    }

    open func configureAttributesForDisappearing(_ attributes: UICollectionViewLayoutAttributes, in collectionView: UICollectionView) {
        self.configureAttributesForAppearing(attributes, in: collectionView)
    }
    
}
