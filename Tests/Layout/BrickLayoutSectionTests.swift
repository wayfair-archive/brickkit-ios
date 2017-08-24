//
//  BrickLayoutSectionTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 8/29/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

private let half = CGFloat(1.0/2.0)
private let third = CGFloat(1.0/3.0)

extension BrickLayoutSection {

    var orderedAttributes: [BrickLayoutAttributes] {
        let orderedKeys = Array(self.attributes.keys).sorted(by: <)
        var orderedAttributes = [BrickLayoutAttributes]()
        for key in orderedKeys {
            orderedAttributes.append(attributes[key]!)
        }
        return orderedAttributes
    }

    var orderedAttributeFrames: [CGRect] {
        return orderedAttributes.map({$0.frame})
    }

}

class BrickLayoutSectionTests: XCTestCase {
    let layout = BrickFlowLayout()

    var dataSource:FixedBrickLayoutSectionDataSource!
    override func setUp() {
        super.setUp()

        dataSource = nil
        continueAfterFailure = false
    }

    fileprivate func createSection(_ widthRatios: [CGFloat], heights: [CGFloat], edgeInsets: UIEdgeInsets, inset: CGFloat, sectionWidth: CGFloat, invalidate: Bool = true, updatedAttributes: OnAttributesUpdatedHandler? = nil) -> BrickLayoutSection {
        dataSource = FixedBrickLayoutSectionDataSource(widthRatios: widthRatios, heights: heights, edgeInsets: edgeInsets, inset: inset)
        let section = BrickLayoutSection(
            sectionIndex: 0,
            sectionAttributes: nil,
            numberOfItems: widthRatios.count,
            origin: CGPoint.zero,
            sectionWidth: sectionWidth,
            dataSource: dataSource)
        if invalidate {
            section.invalidateAttributes(updatedAttributes)
        }
        return section
    }

    func testNoDataSource() {
        let section = createSection([], heights: [], edgeInsets: UIEdgeInsets.zero, inset: 0, sectionWidth: 320)

        section.dataSource = nil
        section.invalidateAttributes(nil)

        XCTAssertTrue(section.attributes.isEmpty)
    }

    func testNoInvalidateWithoutDataSource() {
        let section = createSection([1, half, half, 1], heights: [50, 50, 50, 50], edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), inset: 5, sectionWidth: 320)

        section.dataSource = nil

        expectFatalError { 
            section.invalidate(at: 0, updatedAttributes: nil)
        }
    }

    func testSimpleRows() {
        let section = createSection([1, half, half, 1], heights: [50, 50, 50, 50], edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), inset: 5, sectionWidth: 320)

        XCTAssertEqual(section.frame, CGRect(x: 0, y: 0, width: 320, height: 180))

        let frames = section.orderedAttributeFrames
        XCTAssertEqual(frames.count, 4)
        XCTAssertEqual(frames[0], CGRect(x: 10, y: 10, width: 300, height: 50))
        XCTAssertEqual(frames[1], CGRect(x: 10, y: 65, width: 147.5, height: 50))
        XCTAssertEqual(frames[2], CGRect(x: 162.5, y: 65, width: 147.5, height: 50))
        XCTAssertEqual(frames[3], CGRect(x: 10, y: 120, width: 300, height: 50))
    }
    
    func testThreeBy() {
        let section = createSection([1, third, third, third, 1], heights: [50, 50, 50, 50, 50], edgeInsets: UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5), inset: 5, sectionWidth: 320)

        XCTAssertEqual(section.frame, CGRect(x: 0, y: 0, width: 320, height: 180))

        let frames = section.orderedAttributeFrames
        XCTAssertEqual(frames.count, 5)
        XCTAssertEqual(frames[0], CGRect(x: 5, y: 10, width: 310, height: 50))
        XCTAssertEqual(frames[1], CGRect(x: 5, y: 65, width: 100, height: 50))
        XCTAssertEqual(frames[2], CGRect(x: 110, y: 65, width: 100, height: 50))
        XCTAssertEqual(frames[3], CGRect(x: 215, y: 65, width: 100, height: 50))
        XCTAssertEqual(frames[4], CGRect(x: 5, y: 120, width: 310, height: 50))
    }

    func testDoubleThreeBy() {
        let section = createSection([third, third, third, third, third], heights: [50, 50, 50, 50, 50], edgeInsets: UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5), inset: 5, sectionWidth: 320)

        XCTAssertEqual(section.frame, CGRect(x: 0, y: 0, width: 320, height: 125))

        let frames = section.orderedAttributeFrames
        XCTAssertEqual(frames.count, 5)
        XCTAssertEqual(frames[0], CGRect(x: 5, y: 10, width: 100, height: 50))
        XCTAssertEqual(frames[1], CGRect(x: 110, y: 10, width: 100, height: 50))
        XCTAssertEqual(frames[2], CGRect(x: 215, y: 10, width: 100, height: 50))
        XCTAssertEqual(frames[3], CGRect(x: 5, y: 65, width: 100, height: 50))
        XCTAssertEqual(frames[4], CGRect(x: 110, y: 65, width: 100, height: 50))
    }

    func testUpdateHeightAtIndexZero() {
        var createdIndexPaths = [IndexPath]()
        var updatedIndexPaths: [IndexPath] = []

        let section = createSection([1, half, half, 1], heights: [50, 50, 50, 50], edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), inset: 5, sectionWidth: 320) { attributes, oldFrame in
            createdIndexPaths.append(attributes.indexPath)
        }

        XCTAssertEqual(createdIndexPaths.count, 4)

        section.update(height: 20, at: 0, continueCalculation: true, updatedAttributes: { attributes, _ in
            updatedIndexPaths.append(attributes.indexPath)
        })

        XCTAssertEqual(createdIndexPaths.count, 4)
        XCTAssertEqual(updatedIndexPaths.count, 4)

        let frames = section.orderedAttributeFrames

        XCTAssertEqual(section.frame, CGRect(x: 0, y: 0, width: 320, height: 150))
        XCTAssertEqual(frames.count, 4)
        XCTAssertEqual(frames[0], CGRect(x: 10, y: 10, width: 300, height: 20))
        XCTAssertEqual(frames[1], CGRect(x: 10, y: 35, width: 147.5, height: 50))
        XCTAssertEqual(frames[2], CGRect(x: 162.5, y: 35, width: 147.5, height: 50))
        XCTAssertEqual(frames[3], CGRect(x: 10, y: 90, width: 300, height: 50))
    }

    func testUpdateSmallerHeightInMiddle() {
        let section = createSection([third, third, third, third, third], heights: [50, 50, 50, 50, 50], edgeInsets: UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5), inset: 5, sectionWidth: 320)

        var updatedIndexPaths: [IndexPath] = []
        section.update(height: 20, at: 2, continueCalculation: true, updatedAttributes: { attributes, _ in
            updatedIndexPaths.append(attributes.indexPath)
        })
        XCTAssertEqual(updatedIndexPaths.count, 3)

        XCTAssertEqual(section.frame, CGRect(x: 0, y: 0, width: 320, height: 125))

        let frames = section.orderedAttributeFrames
        XCTAssertEqual(frames.count, 5)
        XCTAssertEqual(frames[0], CGRect(x: 5, y: 10, width: 100, height: 50))
        XCTAssertEqual(frames[1], CGRect(x: 110, y: 10, width: 100, height: 50))
        XCTAssertEqual(frames[2], CGRect(x: 215, y: 10, width: 100, height: 20))
        XCTAssertEqual(frames[3], CGRect(x: 5, y: 65, width: 100, height: 50))
        XCTAssertEqual(frames[4], CGRect(x: 110, y: 65, width: 100, height: 50))
    }

    func testUpdateLargerHeightInMiddle() {
        let section = createSection([third, third, third, third, third], heights: [50, 50, 50, 50, 50], edgeInsets: UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5), inset: 5, sectionWidth: 320)

        var updatedIndexPaths: [IndexPath] = []
        section.update(height: 80, at: 2, continueCalculation: true, updatedAttributes: { attributes, _ in
            updatedIndexPaths.append(attributes.indexPath)
        })
        XCTAssertEqual(updatedIndexPaths.count, 3)

        XCTAssertEqual(section.frame, CGRect(x: 0, y: 0, width: 320, height: 155))

        let frames = section.orderedAttributeFrames
        XCTAssertEqual(frames.count, 5)
        XCTAssertEqual(frames[0], CGRect(x: 5, y: 10, width: 100, height: 50))
        XCTAssertEqual(frames[1], CGRect(x: 110, y: 10, width: 100, height: 50))
        XCTAssertEqual(frames[2], CGRect(x: 215, y: 10, width: 100, height: 80))
        XCTAssertEqual(frames[3], CGRect(x: 5, y: 95, width: 100, height: 50))
        XCTAssertEqual(frames[4], CGRect(x: 110, y: 95, width: 100, height: 50))
    }

    func testUpdateHeightOfAttributeThatDoesntExist() {
        let section = createSection([third, third, third, third, third], heights: [50, 50, 50, 50, 50], edgeInsets: UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5), inset: 5, sectionWidth: 320)

        var updatedIndexPaths: [IndexPath] = []
        section.update(height: 80, at: 5, continueCalculation: true, updatedAttributes: { attributes, _ in
            updatedIndexPaths.append(attributes.indexPath)
        })
        XCTAssertEqual(updatedIndexPaths.count, 0)
    }

    func testAppendItem() {

        let section = createSection([1, 1, 1, 1, 1], heights: [50, 50, 50, 50, 50], edgeInsets: UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5), inset: 5, sectionWidth: 320)

        let dataSource = section.dataSource as! FixedBrickLayoutSectionDataSource
        dataSource.widthRatios.append(1)
        dataSource.heights.append(50)

        section.appendItem { (attributes, oldFrame) in
            XCTAssertNil(oldFrame)
            XCTAssertEqual(attributes.indexPath, IndexPath(item: 5, section: 0))
        }

        let frames = section.orderedAttributeFrames
        XCTAssertEqual(frames.count, 6)
        XCTAssertEqual(frames[0], CGRect(x: 5, y: 10, width: 310, height: 50))
        XCTAssertEqual(frames[1], CGRect(x: 5, y: 65, width: 310, height: 50))
        XCTAssertEqual(frames[2], CGRect(x: 5, y: 120, width: 310, height: 50))
        XCTAssertEqual(frames[3], CGRect(x: 5, y: 175, width: 310, height: 50))
        XCTAssertEqual(frames[4], CGRect(x: 5, y: 230, width: 310, height: 50))
        XCTAssertEqual(frames[5], CGRect(x: 5, y: 285, width: 310, height: 50))

        XCTAssertEqual(section.frame, CGRect(x: 0, y: 0, width: 320, height: 345))
    }

    func testAppendItems() {
        let dataSource = FixedBrickLayoutSectionDataSource(widthRatios: [], heights: [], edgeInsets: UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5), inset: 5)
        let section = BrickLayoutSection(
            sectionIndex: 0,
            sectionAttributes: nil,
            numberOfItems: 0,
            origin: CGPoint.zero,
            sectionWidth: 320,
            dataSource: dataSource)
        section.invalidateAttributes(nil)

        dataSource.widthRatios = [1, 1, 1, 1, 1, 1]
        dataSource.heights = [50, 50, 50, 50, 50, 50]

        section.updateNumberOfItems(inserted: [0,1,2,3,4,5], deleted: [])


        section.invalidateAttributes(nil)

        let frames = section.orderedAttributeFrames
        XCTAssertEqual(frames.count, 6)
        XCTAssertEqual(frames[0], CGRect(x: 5, y: 10, width: 310, height: 50))
        XCTAssertEqual(frames[1], CGRect(x: 5, y: 65, width: 310, height: 50))
        XCTAssertEqual(frames[2], CGRect(x: 5, y: 120, width: 310, height: 50))
        XCTAssertEqual(frames[3], CGRect(x: 5, y: 175, width: 310, height: 50))
        XCTAssertEqual(frames[4], CGRect(x: 5, y: 230, width: 310, height: 50))
        XCTAssertEqual(frames[5], CGRect(x: 5, y: 285, width: 310, height: 50))

        XCTAssertEqual(section.frame, CGRect(x: 0, y: 0, width: 320, height: 345))
    }

    func testDeleteLastItem() {

        let section = createSection([1, 1, 1, 1, 1], heights: [50, 50, 50, 50, 50], edgeInsets: UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5), inset: 5, sectionWidth: 320)

        let dataSource = section.dataSource as! FixedBrickLayoutSectionDataSource
        dataSource.widthRatios.removeLast()
        dataSource.heights.removeLast()

        section.deleteLastItem { (attributes, oldFrame) in
            XCTAssertEqual(attributes.indexPath, IndexPath(item: 4, section: 0))
        }

        let frames = section.orderedAttributeFrames
        XCTAssertEqual(frames.count, 4)
        XCTAssertEqual(frames[0], CGRect(x: 5, y: 10, width: 310, height: 50))
        XCTAssertEqual(frames[1], CGRect(x: 5, y: 65, width: 310, height: 50))
        XCTAssertEqual(frames[2], CGRect(x: 5, y: 120, width: 310, height: 50))
        XCTAssertEqual(frames[3], CGRect(x: 5, y: 175, width: 310, height: 50))

        XCTAssertEqual(section.frame, CGRect(x: 0, y: 0, width: 320, height: 235))
    }

    func testDeleteLastItemEmpty() {
        let section = createSection([], heights: [], edgeInsets: UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5), inset: 5, sectionWidth: 320)

        section.deleteLastItem(nil)

        let frames = section.orderedAttributeFrames
        XCTAssertEqual(frames.count, 0)
    }

    func testDeleteLastItems() {
        let dataSource = FixedBrickLayoutSectionDataSource(widthRatios: [1, 1, 1, 1, 1], heights: [50, 50, 50, 50, 50], edgeInsets: UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5), inset: 5)
        let section = BrickLayoutSection(
            sectionIndex: 0,
            sectionAttributes: nil,
            numberOfItems: 5,
            origin: CGPoint.zero,
            sectionWidth: 320,
            dataSource: dataSource)
        section.invalidateAttributes(nil)

        dataSource.widthRatios.removeLast()
        dataSource.widthRatios.removeLast()
        dataSource.heights.removeLast()
        dataSource.heights.removeLast()

        section.updateNumberOfItems(inserted: [], deleted: [3, 4])
        section.invalidateAttributes(nil)

        let frames = section.orderedAttributeFrames
        XCTAssertEqual(frames.count, 3)
        XCTAssertEqual(frames[0], CGRect(x: 5, y: 10, width: 310, height: 50))
        XCTAssertEqual(frames[1], CGRect(x: 5, y: 65, width: 310, height: 50))
        XCTAssertEqual(frames[2], CGRect(x: 5, y: 120, width: 310, height: 50))

        XCTAssertEqual(section.frame, CGRect(x: 0, y: 0, width: 320, height: 180))
    }

    func testThatContinueCalculatingReturnsRightValue() {
        let totalNumber = 20
        let section = createSection(Array<CGFloat>(repeating: 1, count: totalNumber), heights: Array<CGFloat>(repeating: 50, count: totalNumber), edgeInsets: UIEdgeInsets.zero, inset: 0, sectionWidth: 320, invalidate: false)
        dataSource.frameOfInterest = CGRect(x: 0, y: 0, width: 320, height: 200)

        XCTAssertTrue(section.continueCalculatingCells())
        XCTAssertEqual(section.attributes.count, 4)
        XCTAssertTrue(section.continueCalculatingCells())

        dataSource.frameOfInterest = CGRect(x: 0, y: 0, width: 320, height: CGFloat(50 * totalNumber))
        XCTAssertTrue(section.continueCalculatingCells())
        XCTAssertEqual(section.attributes.count, totalNumber)
        XCTAssertFalse(section.continueCalculatingCells())
    }

    func testThatContinueCalculatingReturnsRightValueWithDownstreamIndexPaths() {
        let totalNumber = 20
        let section = createSection(Array<CGFloat>(repeating: 1, count: totalNumber), heights: Array<CGFloat>(repeating: 50, count: totalNumber), edgeInsets: UIEdgeInsets.zero, inset: 0, sectionWidth: 320, invalidate: false)
        dataSource.frameOfInterest = CGRect(x: 0, y: 0, width: 320, height: 200)
        dataSource.downStreamIndexPaths = [IndexPath(item: totalNumber-1, section: 0)]

        XCTAssertTrue(section.continueCalculatingCells())
        XCTAssertEqual(section.attributes.count, 5)
        XCTAssertTrue(section.continueCalculatingCells())
    }

    func testThatInvalidatingAnAttributeThatIsNotYetCalculatedDoesNotCrashApp() {
        let totalNumber = 20
        let section = createSection(Array<CGFloat>(repeating: 1, count: totalNumber), heights: Array<CGFloat>(repeating: 50, count: totalNumber), edgeInsets: UIEdgeInsets.zero, inset: 0, sectionWidth: 320, invalidate: false)
        dataSource.frameOfInterest = CGRect(x: 0, y: 0, width: 320, height: 200)
        dataSource.downStreamIndexPaths = [IndexPath(item: totalNumber-1, section: 0)]

        section.invalidate(at: 0, updatedAttributes: nil)
    }
    
    func testThatSetOriginUpdatesAttributesOrigin() {
        // setup ipad sized collection view
        let brickView: BrickCollectionView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 768, height: 968))
        
        // setup brick section
        let topLeftHalf = BrickSection(width: .ratio(ratio: 0.5), bricks: [
            DummyBrick("BrickLeft", height: .fixed(size: 300)),
            ])
        topLeftHalf.isHidden = true
        
        // Fixed width section
        let fixedWidthSection: Brick = BrickSection("fixedWidthSection", bricks: [
            DummyBrick("BrickFixed1", width: .fixed(size: 89), height: .fixed(size: 40)),
            DummyBrick("BrickFixed2", width: .fixed(size: 200), height: .fixed(size: 40))
            ])
        
        let nonFixedWidthSection: Brick = BrickSection("nonFixedWidthSection", bricks: [
            DummyBrick("BrickNonFixed1", height: .fixed(size: 41)),
            ])
        
        let topRightHalf = BrickSection("topRightHalf", width: .ratio(ratio: 0.5), bricks: [
            fixedWidthSection,
            nonFixedWidthSection,
            ])
        
        let brickSection = BrickSection("topSection", bricks: [
            topLeftHalf,
            topRightHalf
            ], edgeInsets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
        
        // hide left half and layout brick section
        brickView.setupSectionAndLayout(brickSection)
        
        let topRightHalfIndexPath = brickView.indexPathsForBricksWithIdentifier(topRightHalf.identifier).first!
        let topRightHalfCell = brickView.cellForItem(at: topRightHalfIndexPath)
        XCTAssertEqual(topRightHalfCell?.frame.width, 376)
        
        // show left half
        topLeftHalf.isHidden = false
        brickView.invalidateVisibility()
        brickView.layoutIfNeeded()
        
        let fixedWidthSectionIndexPath = brickView.indexPathsForBricksWithIdentifier(fixedWidthSection.identifier).first!
        let fixedWidthSectionCell = brickView.cellForItem(at: fixedWidthSectionIndexPath)
        XCTAssertEqual(fixedWidthSectionCell?.frame.origin.x, 384)
        
        let nonFixedWidthSectionIndexPath = brickView.indexPathsForBricksWithIdentifier(nonFixedWidthSection.identifier).first!
        let nonFixedWidthSectionCell = brickView.cellForItem(at: nonFixedWidthSectionIndexPath)
        XCTAssertEqual(nonFixedWidthSectionCell?.frame.origin.x, 384)
    }
}
