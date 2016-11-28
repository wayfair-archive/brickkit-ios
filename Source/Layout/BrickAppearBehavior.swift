//
//  BrickAppearBehavior.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/11/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import Foundation

public protocol BrickAppearBehavior: class {
    func configureAttributesForAppearing(attributes: UICollectionViewLayoutAttributes, in collectionView: UICollectionView)
    func configureAttributesForDisappearing(attributes: UICollectionViewLayoutAttributes, in collectionView: UICollectionView)
}

public class BrickAppearTopBehavior: BrickAppearBehavior {

    public init() {

    }

    public func configureAttributesForAppearing(attributes: UICollectionViewLayoutAttributes, in collectionView: UICollectionView) {
        attributes.frame.origin.y = -attributes.frame.height
    }

    public func configureAttributesForDisappearing(attributes: UICollectionViewLayoutAttributes, in collectionView: UICollectionView) {
        self.configureAttributesForAppearing(attributes, in: collectionView)
    }
    
}

public class BrickAppearBottomBehavior: BrickAppearBehavior {

    public init() {

    }
    
    public func configureAttributesForAppearing(attributes: UICollectionViewLayoutAttributes, in collectionView: UICollectionView) {
        attributes.frame.origin.y = max(collectionView.frame.height,  collectionView.contentSize.height)
    }

    public func configureAttributesForDisappearing(attributes: UICollectionViewLayoutAttributes, in collectionView: UICollectionView) {
        self.configureAttributesForAppearing(attributes, in: collectionView)
        attributes.alpha = 0
    }

}
