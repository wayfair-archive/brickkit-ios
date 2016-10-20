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

class BrickLayoutSectionTests: XCTestCase {
    let layout = BrickFlowLayout()

    var dataSource:FixedBrickLayoutSectionDataSource!
    override func setUp() {
        super.setUp()

        dataSource = nil
        continueAfterFailure = false
    }

    private func createSection(widthRatios: [CGFloat], heights: [CGFloat], edgeInsets: UIEdgeInsets, inset: CGFloat, sectionWidth: CGFloat, updatedAttributes: OnAttributesUpdatedHandler? = nil) -> BrickLayoutSection {
        dataSource = FixedBrickLayoutSectionDataSource(widthRatios: widthRatios, heights: heights, edgeInsets: edgeInsets, inset: inset)
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

    func testNoDataSource() {
        let section = createSection([], heights: [], edgeInsets: UIEdgeInsetsZero, inset: 0, sectionWidth: 320)

        section.dataSource = nil
        section.invalidateAttributes(nil)

        XCTAssertTrue(section.attributes.isEmpty)
    }

    func testNoInvalidateWithoutDataSource() {
        let section = createSection([], heights: [], edgeInsets: UIEdgeInsetsZero, inset: 0, sectionWidth: 320)

        section.dataSource = nil

        expectFatalError { 
            section.invalidate(at: 0, updatedAttributes: nil)
        }
    }

    func testSimpleRows() {
        let section = createSection([1, half, half, 1], heights: [50, 50, 50, 50], edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), inset: 5, sectionWidth: 320)

        XCTAssertEqual(section.frame, CGRect(x: 0, y: 0, width: 320, height: 180))

        let frames = section.attributes.map { $0.frame }
        XCTAssertEqual(frames.count, 4)
        XCTAssertEqual(frames[0], CGRect(x: 10, y: 10, width: 300, height: 50))
        XCTAssertEqual(frames[1], CGRect(x: 10, y: 65, width: 147.5, height: 50))
        XCTAssertEqual(frames[2], CGRect(x: 162.5, y: 65, width: 147.5, height: 50))
        XCTAssertEqual(frames[3], CGRect(x: 10, y: 120, width: 300, height: 50))
    }
    
    func testThreeBy() {
        let section = createSection([1, third, third, third, 1], heights: [50, 50, 50, 50, 50], edgeInsets: UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5), inset: 5, sectionWidth: 320)

        XCTAssertEqual(section.frame, CGRect(x: 0, y: 0, width: 320, height: 180))

        let frames = section.attributes.map { $0.frame }
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

        let frames = section.attributes.map { $0.frame }
        XCTAssertEqual(frames.count, 5)
        XCTAssertEqual(frames[0], CGRect(x: 5, y: 10, width: 100, height: 50))
        XCTAssertEqual(frames[1], CGRect(x: 110, y: 10, width: 100, height: 50))
        XCTAssertEqual(frames[2], CGRect(x: 215, y: 10, width: 100, height: 50))
        XCTAssertEqual(frames[3], CGRect(x: 5, y: 65, width: 100, height: 50))
        XCTAssertEqual(frames[4], CGRect(x: 110, y: 65, width: 100, height: 50))
    }

    func testUpdateHeightAtIndexZero() {
        var createdIndexPaths = [NSIndexPath]()
        var updatedIndexPaths: [NSIndexPath] = []

        let section = createSection([1, half, half, 1], heights: [50, 50, 50, 50], edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), inset: 5, sectionWidth: 320) { attributes, oldFrame in
            createdIndexPaths.append(attributes.indexPath)
        }

        XCTAssertEqual(createdIndexPaths.count, 4)

        section.update(height: 20, at: 0, updatedAttributes: { attributes, _ in
            updatedIndexPaths.append(attributes.indexPath)
        })

        XCTAssertEqual(createdIndexPaths.count, 4)
        XCTAssertEqual(updatedIndexPaths.count, 4)

        let frames = section.attributes.map { $0.frame }

        XCTAssertEqual(section.frame, CGRect(x: 0, y: 0, width: 320, height: 150))
        XCTAssertEqual(frames.count, 4)
        XCTAssertEqual(frames[0], CGRect(x: 10, y: 10, width: 300, height: 20))
        XCTAssertEqual(frames[1], CGRect(x: 10, y: 35, width: 147.5, height: 50))
        XCTAssertEqual(frames[2], CGRect(x: 162.5, y: 35, width: 147.5, height: 50))
        XCTAssertEqual(frames[3], CGRect(x: 10, y: 90, width: 300, height: 50))
    }

    func testUpdateSmallerHeightInMiddle() {
        let section = createSection([third, third, third, third, third], heights: [50, 50, 50, 50, 50], edgeInsets: UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5), inset: 5, sectionWidth: 320)

        var updatedIndexPaths: [NSIndexPath] = []
        section.update(height: 20, at: 2, updatedAttributes: { attributes, _ in
            updatedIndexPaths.append(attributes.indexPath)
        })
        XCTAssertEqual(updatedIndexPaths.count, 3)

        XCTAssertEqual(section.frame, CGRect(x: 0, y: 0, width: 320, height: 125))

        let frames = section.attributes.map { $0.frame }
        XCTAssertEqual(frames.count, 5)
        XCTAssertEqual(frames[0], CGRect(x: 5, y: 10, width: 100, height: 50))
        XCTAssertEqual(frames[1], CGRect(x: 110, y: 10, width: 100, height: 50))
        XCTAssertEqual(frames[2], CGRect(x: 215, y: 10, width: 100, height: 20))
        XCTAssertEqual(frames[3], CGRect(x: 5, y: 65, width: 100, height: 50))
        XCTAssertEqual(frames[4], CGRect(x: 110, y: 65, width: 100, height: 50))
    }

    func testUpdateLargerHeightInMiddle() {
        let section = createSection([third, third, third, third, third], heights: [50, 50, 50, 50, 50], edgeInsets: UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5), inset: 5, sectionWidth: 320)

        var updatedIndexPaths: [NSIndexPath] = []
        section.update(height: 80, at: 2, updatedAttributes: { attributes, _ in
            updatedIndexPaths.append(attributes.indexPath)
        })
        XCTAssertEqual(updatedIndexPaths.count, 3)

        XCTAssertEqual(section.frame, CGRect(x: 0, y: 0, width: 320, height: 155))

        let frames = section.attributes.map { $0.frame }
        XCTAssertEqual(frames.count, 5)
        XCTAssertEqual(frames[0], CGRect(x: 5, y: 10, width: 100, height: 50))
        XCTAssertEqual(frames[1], CGRect(x: 110, y: 10, width: 100, height: 50))
        XCTAssertEqual(frames[2], CGRect(x: 215, y: 10, width: 100, height: 80))
        XCTAssertEqual(frames[3], CGRect(x: 5, y: 95, width: 100, height: 50))
        XCTAssertEqual(frames[4], CGRect(x: 110, y: 95, width: 100, height: 50))
    }

    func testAppendItem() {

        let section = createSection([1, 1, 1, 1, 1], heights: [50, 50, 50, 50, 50], edgeInsets: UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5), inset: 5, sectionWidth: 320)

        let dataSource = section.dataSource as! FixedBrickLayoutSectionDataSource
        dataSource.widthRatios.append(1)
        dataSource.heights.append(50)

        section.appendItem { (attributes, oldFrame) in
            XCTAssertNil(oldFrame)
            XCTAssertEqual(attributes.indexPath, NSIndexPath(forItem: 5, inSection: 0))
        }

        let frames = section.attributes.map { $0.frame }
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

        var addedAttributes = [BrickLayoutAttributes]()
        section.setNumberOfItems(6, addedAttributes: { (attributes, oldFrame) in
            addedAttributes.append(attributes)
            }, removedAttributes: nil)
        XCTAssertEqual(addedAttributes.count, 6)

        let frames = section.attributes.map { $0.frame }
        XCTAssertEqual(frames.count, 6)
        XCTAssertEqual(frames[0], CGRect(x: 5, y: 10, width: 310, height: 50))
        XCTAssertEqual(frames[1], CGRect(x: 5, y: 65, width: 310, height: 50))
        XCTAssertEqual(frames[2], CGRect(x: 5, y: 120, width: 310, height: 50))
        XCTAssertEqual(frames[3], CGRect(x: 5, y: 175, width: 310, height: 50))
        XCTAssertEqual(frames[4], CGRect(x: 5, y: 230, width: 310, height: 50))
        XCTAssertEqual(frames[5], CGRect(x: 5, y: 285, width: 310, height: 50))

        XCTAssertEqual(section.frame, CGRect(x: 0, y: 0, width: 320, height: 345))
    }

    func testNoItems() {
        let dataSource = FixedBrickLayoutSectionDataSource(widthRatios: [1, 1, 1, 1, 1, 1], heights: [50, 50, 50, 50, 50, 50], edgeInsets: UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5), inset: 5)
        let section = BrickLayoutSection(
            sectionIndex: 0,
            sectionAttributes: nil,
            numberOfItems: 6,
            origin: CGPoint.zero,
            sectionWidth: 320,
            dataSource: dataSource)
        section.invalidateAttributes(nil)

        var addedAttributes = [BrickLayoutAttributes]()
        section.setNumberOfItems(6, addedAttributes: { (attributes, oldFrame) in
            addedAttributes.append(attributes)
            }, removedAttributes: nil)
        XCTAssertEqual(addedAttributes.count, 0)

        let frames = section.attributes.map { $0.frame }
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
            XCTAssertEqual(attributes.indexPath, NSIndexPath(forItem: 4, inSection: 0))
        }

        let frames = section.attributes.map { $0.frame }
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

        let frames = section.attributes.map { $0.frame }
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

        var deletedAttributes = [BrickLayoutAttributes]()
        section.setNumberOfItems(3, addedAttributes: nil, removedAttributes: { (attributes, oldFrame) in
            deletedAttributes.append(attributes)
        })
        XCTAssertEqual(deletedAttributes.count, 2)

        let frames = section.attributes.map { $0.frame }
        XCTAssertEqual(frames.count, 3)
        XCTAssertEqual(frames[0], CGRect(x: 5, y: 10, width: 310, height: 50))
        XCTAssertEqual(frames[1], CGRect(x: 5, y: 65, width: 310, height: 50))
        XCTAssertEqual(frames[2], CGRect(x: 5, y: 120, width: 310, height: 50))

        XCTAssertEqual(section.frame, CGRect(x: 0, y: 0, width: 320, height: 180))
    }

}
