//
//  BrickLayoutSectionBinarySearchTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 10/27/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

private let mapAttributesToItemIndex: (UICollectionViewLayoutAttributes) -> Int = {$0.indexPath.item}
private let sortByNumber: (Int, Int) -> Bool = {$0 < $1}


class BrickLayoutSectionBinarySearchTests: XCTestCase {

    var layout: BrickFlowLayout {
        return brickView.layout
    }

    var brickView: BrickCollectionView!

    var dataSource:FixedBrickLayoutSectionDataSource!
    override func setUp() {
        super.setUp()

        brickView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        dataSource = nil
        continueAfterFailure = false
    }

    fileprivate func createSection(_ widthRatios: [CGFloat], heights: [CGFloat], edgeInsets: UIEdgeInsets, inset: CGFloat, sectionWidth: CGFloat, scrollDirection: UICollectionViewScrollDirection = .vertical, updatedAttributes: OnAttributesUpdatedHandler? = nil) -> BrickLayoutSection {
        dataSource = FixedBrickLayoutSectionDataSource(widthRatios: widthRatios, heights: heights, edgeInsets: edgeInsets, inset: inset)
        dataSource.scrollDirection = scrollDirection
        let section = BrickLayoutSection(
            sectionIndex: 0,
            sectionAttributes: nil,
            numberOfItems: widthRatios.count,
            origin: CGPoint.zero,
            sectionWidth: sectionWidth,
            dataSource: dataSource)
        section.invalidateAttributes(updatedAttributes)
        return section
    }
    
    func testThatSectionReturnsAttributesForRect() {
        let totalNumber = 20
        let section = createSection(Array<CGFloat>(repeating: 1, count: totalNumber), heights: Array<CGFloat>(repeating: 50, count: totalNumber), edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), inset: 0, sectionWidth: 320)

        var attributes: [Int]!

        attributes = section.layoutAttributesForElementsInRect(CGRect(x: 0, y: 0, width: 320, height: 480), with: BrickZIndexer()).map(mapAttributesToItemIndex).sorted(by: sortByNumber)
        XCTAssertEqual(attributes.count, 10)
        XCTAssertEqual(attributes,Array<Int>(0...9))

        attributes = section.layoutAttributesForElementsInRect(CGRect(x: 0, y: 25, width: 320, height: 480), with: BrickZIndexer()).map(mapAttributesToItemIndex).sorted(by: sortByNumber)
        XCTAssertEqual(attributes.count, 11)
        XCTAssertEqual(attributes,Array<Int>(0...10))

        attributes = section.layoutAttributesForElementsInRect(CGRect(x: 0, y: 480, width: 320, height: 480), with: BrickZIndexer()).map(mapAttributesToItemIndex).sorted(by: sortByNumber)
        XCTAssertEqual(attributes.count, 11)
        XCTAssertEqual(attributes,Array<Int>(9...19))

    }

    func testThatSectionReturnsAttributesForRectWithInset() {
        let totalNumber = 20
        let section = createSection(Array<CGFloat>(repeating: 1, count: totalNumber), heights: Array<CGFloat>(repeating: 50, count: totalNumber), edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), inset: 10, sectionWidth: 320)

        var attributes: [Int]!

        attributes = section.layoutAttributesForElementsInRect(CGRect(x: 0, y: 55, width: 320, height: 480), with: BrickZIndexer()).map(mapAttributesToItemIndex).sorted(by: sortByNumber)
        XCTAssertEqual(attributes.count, 8)
        XCTAssertEqual(attributes,Array<Int>(1...8))

    }

    func testThatSectionReturnsAttributesForRectWith2By() {
        let totalNumber = 50
        let section = createSection(Array<CGFloat>(repeating: 1/2, count: totalNumber), heights: Array<CGFloat>(repeating: 50, count: totalNumber), edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), inset: 0, sectionWidth: 320)

        var attributes: [Int]!

        attributes = section.layoutAttributesForElementsInRect(CGRect(x: 0, y: 55, width: 320, height: 480), with: BrickZIndexer()).map(mapAttributesToItemIndex).sorted(by: sortByNumber)
        XCTAssertEqual(attributes.count, 20)
        XCTAssertEqual(attributes,Array<Int>(2...21))
        
    }

    func testThatSectionReturnsAttributesForRectWith2ByHuge() {
        let totalNumber = 50000
        let section = createSection(Array<CGFloat>(repeating: 1/2, count: totalNumber), heights: Array<CGFloat>(repeating: 50, count: totalNumber), edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), inset: 0, sectionWidth: 320)

        var attributes: [Int]!

        attributes = section.layoutAttributesForElementsInRect(CGRect(x: 0, y: 55, width: 320, height: 480), with: BrickZIndexer()).map(mapAttributesToItemIndex).sorted(by: sortByNumber)
        XCTAssertEqual(attributes.count, 20)
        XCTAssertEqual(attributes,Array<Int>(2...21))
    }

    func testThatSectionReturnsAttributesForRectWithHorizontalScrollDirection() {
        brickView.layout.scrollDirection = .horizontal

        let totalNumber = 20
        let section = createSection(Array<CGFloat>(repeating: 1/4, count: totalNumber), heights: Array<CGFloat>(repeating: 50, count: totalNumber), edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), inset: 0, sectionWidth: 320, scrollDirection: .horizontal)
        var attributes: [Int]!

        attributes = section.layoutAttributesForElementsInRect(CGRect(x: 0, y: 0, width: 320, height: 480), with: BrickZIndexer()).map(mapAttributesToItemIndex).sorted(by: sortByNumber)
        XCTAssertEqual(attributes.count, 4)
        XCTAssertEqual(attributes,Array<Int>(0...3))

        attributes = section.layoutAttributesForElementsInRect(CGRect(x: 25, y: 0, width: 320, height: 480), with: BrickZIndexer()).map(mapAttributesToItemIndex).sorted(by: sortByNumber)
        XCTAssertEqual(attributes.count, 5)
        XCTAssertEqual(attributes,Array<Int>(0...4))

        attributes = section.layoutAttributesForElementsInRect(CGRect(x: 320, y: 0, width: 320, height: 480), with: BrickZIndexer()).map(mapAttributesToItemIndex).sorted(by: sortByNumber)
        XCTAssertEqual(attributes.count, 4)
        XCTAssertEqual(attributes,Array<Int>(4...7))
        
    }

    func testThatBinarySearchWithDownstreamIndexPaths() {
        let totalNumber = 20
        let widthRatios = Array<CGFloat>(repeating: 1, count: totalNumber)
        let heights = Array<CGFloat>(repeating: 50, count: totalNumber)
        let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let inset: CGFloat = 0
        let sectionWidth:CGFloat = 320

        dataSource = FixedBrickLayoutSectionDataSource(widthRatios: widthRatios, heights: heights, edgeInsets: edgeInsets, inset: inset)
        dataSource.downStreamIndexPaths = [IndexPath(item: 0, section: 0)]

        let section = BrickLayoutSection(
            sectionIndex: 0,
            sectionAttributes: nil,
            numberOfItems: widthRatios.count,
            origin: CGPoint.zero,
            sectionWidth: sectionWidth,
            dataSource: dataSource)
        section.invalidateAttributes(nil)
        section.attributes[0]!.frame.origin.y = 100000

        let attributes = section.layoutAttributesForElementsInRect(CGRect(x: 0, y: 0, width: 320, height: 500), with: BrickZIndexer()).map(mapAttributesToItemIndex).sorted(by: sortByNumber)
        XCTAssertEqual(attributes.count, 9)
        XCTAssertEqual(attributes,Array<Int>(1...9))

    }

    func testThatABrickOnTheSameRowIsAlsoTakenIntoAccount() {
        let totalNumber = 3
        let widthRatios = Array<CGFloat>(repeating: 1/2, count: totalNumber)
        let heights: [CGFloat] = [150, 100, 150]
        let edgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let inset: CGFloat = 0
        let sectionWidth:CGFloat = 320

        dataSource = FixedBrickLayoutSectionDataSource(widthRatios: widthRatios, heights: heights, edgeInsets: edgeInsets, inset: inset)
        let section = BrickLayoutSection(
            sectionIndex: 0,
            sectionAttributes: nil,
            numberOfItems: widthRatios.count,
            origin: CGPoint.zero,
            sectionWidth: sectionWidth,
            dataSource: dataSource)
        section.invalidateAttributes(nil)

        let attributes = section.layoutAttributesForElementsInRect(CGRect(x: 0, y: 120, width: 320, height: 100), with: BrickZIndexer()).map(mapAttributesToItemIndex).sorted(by: sortByNumber)
        XCTAssertEqual(attributes.count, 2)
        XCTAssertEqual(attributes,[0, 2])

    }

}
