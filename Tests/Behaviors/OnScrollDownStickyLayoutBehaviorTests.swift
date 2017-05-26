//
//  OnScrollDownStickyLayoutBehaviorTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/3/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

class OnScrollDownStickyLayoutBehaviorTests: BrickFlowLayoutBaseTests {

    func testOnScrollDownStickingBehavior() {
        let indexPath = IndexPath(item: 0, section: 0)

        let fixedStickyLayout = FixedStickyLayoutBehaviorDataSource(indexPaths: [indexPath])
        let stickyBehavior = OnScrollDownStickyLayoutBehavior(dataSource: fixedStickyLayout)
        self.layout.behaviors.insert(stickyBehavior)

        let sectionCount = 20
        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))

        var frames = [CGRect]()
        let size = CGSize(width: 320, height: 100)
        for index in 0..<sectionCount {
            frames.append(CGRect(origin: CGPoint(x: 0, y: index * 100), size: size))
        }

        var firstAttributes: UICollectionViewLayoutAttributes!

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))

        firstAttributes = layout.layoutAttributesForItem(at: indexPath)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 0, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 450
        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))

        firstAttributes = layout.layoutAttributesForItem(at: indexPath)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 350, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 200
        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))

        firstAttributes = layout.layoutAttributesForItem(at: indexPath)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 200, width: 320, height: 100))
        
        layout.collectionView?.contentOffset.y = 200
        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))

        firstAttributes = layout.layoutAttributesForItem(at: indexPath)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 200, width: 320, height: 100))
    }

    func testOnScrollDownStickingSectionBehavior() {
        let fixedStickyLayout = FixedStickyLayoutBehaviorDataSource(indexPaths: [IndexPath(item: 0, section: 1), IndexPath(item: 0, section: 2)])
        let stickyBehavior = OnScrollDownStickyLayoutBehavior(dataSource: fixedStickyLayout)
        self.layout.behaviors.insert(stickyBehavior)


        setDataSources(SectionsCollectionViewDataSource(sections: [2, 2, 2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1, 1], [1, 1], [1, 1]], heights: [[0, 0], [100, 1000], [100, 1000]], types: [[.section(sectionIndex: 1), .section(sectionIndex: 2)], [.brick, .brick], [.brick, .brick]]))

        var firstSectionAttributes: UICollectionViewLayoutAttributes!
        var secondSectionAttributes: UICollectionViewLayoutAttributes!

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))

        firstSectionAttributes = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(firstSectionAttributes?.frame, CGRect(x: 0, y: 0, width: 320, height: 100))
        secondSectionAttributes = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 2))
        XCTAssertEqual(secondSectionAttributes?.frame, CGRect(x: 0, y: 1100, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 1100
        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))

        firstSectionAttributes = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(firstSectionAttributes?.frame, CGRect(x: 0, y: 0, width: 320, height: 100))
        secondSectionAttributes = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 2))
        XCTAssertEqual(secondSectionAttributes?.frame, CGRect(x: 0, y: 1100, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 1000
        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))

        firstSectionAttributes = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(firstSectionAttributes?.frame, CGRect(x: 0, y: 900, width: 320, height: 100))
        secondSectionAttributes = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 2))
        XCTAssertEqual(secondSectionAttributes?.frame, CGRect(x: 0, y: 1100, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 1600
        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))

        firstSectionAttributes = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 1))
        XCTAssertEqual(firstSectionAttributes?.frame, CGRect(x: 0, y: 900, width: 320, height: 100))
        secondSectionAttributes = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 2))
        XCTAssertEqual(secondSectionAttributes?.frame, CGRect(x: 0, y: 1100, width: 320, height: 100))
    }

    func testOnScrollDownStickingBehaviorStacked() {
        let indexPath = IndexPath(item: 0, section: 0)
        let indexPath2 = IndexPath(item: 1, section: 0)
        let fixedStickyLayout = FixedStickyLayoutBehaviorDataSource(indexPaths: [indexPath, indexPath2])
        let stickyBehavior = OnScrollDownStickyLayoutBehavior(dataSource: fixedStickyLayout)
        self.layout.behaviors.insert(stickyBehavior)

        let sectionCount = 20
        setDataSources(SectionsCollectionViewDataSource(sections: [sectionCount]), brickLayoutDataSource: FixedBrickLayoutDataSource(widthRatio: 1, height: 100))

        var frames = [CGRect]()
        let size = CGSize(width: 320, height: 100)
        for index in 0..<sectionCount {
            frames.append(CGRect(origin: CGPoint(x: 0, y: index * 100), size: size))
        }

        var firstAttributes: UICollectionViewLayoutAttributes!
        var secondAttributes: UICollectionViewLayoutAttributes!

        layout.collectionView?.contentOffset.y = 500
        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))

        firstAttributes = layout.layoutAttributesForItem(at: indexPath)
        secondAttributes = layout.layoutAttributesForItem(at: indexPath2)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 0, width: 320, height: 100))
        XCTAssertEqual(secondAttributes?.frame, CGRect(x: 0, y: 100, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 450
        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))

        firstAttributes = layout.layoutAttributesForItem(at: indexPath)
        secondAttributes = layout.layoutAttributesForItem(at: indexPath2)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 250, width: 320, height: 100))
        XCTAssertEqual(secondAttributes?.frame, CGRect(x: 0, y: 350, width: 320, height: 100))

        layout.collectionView?.contentOffset.y = 200
        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))

        firstAttributes = layout.layoutAttributesForItem(at: indexPath)
        secondAttributes = layout.layoutAttributesForItem(at: indexPath2)
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 200, width: 320, height: 100))
        XCTAssertEqual(firstAttributes?.frame, CGRect(x: 0, y: 200, width: 320, height: 100))
    }

    func testThatOnScrollDownWorksWithBrickViewSameContentHeight() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(height: .fixed(size: 50)),
            DummyBrick("BRICK", height: .fixed(size: 50))
            ])
        let indexPath = IndexPath(item: 0, section: 1)
        let scrollDownDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [indexPath])
        let stickyBehavior = OnScrollDownStickyLayoutBehavior(dataSource: scrollDownDataSource)
        self.layout.behaviors.insert(stickyBehavior)

        let repeatDataSource = FixedRepeatCountDataSource(repeatCountHash: ["BRICK" : 100])
        section.repeatCountDataSource = repeatDataSource

        collectionView.setSection(section)
        collectionView.layoutSubviews()

        collectionView.contentOffset.y += 100
        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))
        collectionView.layoutSubviews()
        collectionView.contentOffset.y -= 5
        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))
        collectionView.layoutSubviews()

        collectionView.contentOffset.y -= 5
        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))
        collectionView.layoutSubviews()

        layout.invalidateLayout(with: BrickLayoutInvalidationContext(type: .scrolling))
        collectionView.layoutSubviews()

        XCTAssertEqual(layout.layoutAttributesForItem(at: indexPath)?.frame, CGRect(x: 0, y: 45, width: 320, height: 50))

    }
    
}
