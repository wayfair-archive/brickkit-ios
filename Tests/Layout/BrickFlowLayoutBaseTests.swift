//
//  BrickFlowLayoutBaseTests.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/23/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

class BrickFlowLayoutBaseTests: XCTestCase {

    let collectionViewFrame = CGRect(x: 0, y: 0, width: 320, height: 480)
    let hugeFrame = CGRect(x: 0, y: 0, width: 320, height: CGFloat.infinity)

    var layout: BrickFlowLayout!
    var collectionView: BrickCollectionView!
    var dataSource: UICollectionViewDataSource!
    var brickLayoutDataSource: BrickLayoutDataSource?

    override func setUp() {
        super.setUp()

        continueAfterFailure = false

        layout = BrickFlowLayout()

        collectionView = BrickCollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        layout.dataSource = collectionView
    }

    override func tearDown() {
        super.tearDown()

        layout = nil
        collectionView = nil
    }

    func setDataSources(_ collectionViewDataSource: UICollectionViewDataSource?, brickLayoutDataSource: BrickLayoutDataSource?) {
        self.brickLayoutDataSource = brickLayoutDataSource
        self.dataSource = collectionViewDataSource

        layout.dataSource = brickLayoutDataSource
        collectionView.dataSource = self.dataSource
        collectionView.reloadData()
        _ = layout.calculateSectionsIfNeeded(hugeFrame)
    }
}
