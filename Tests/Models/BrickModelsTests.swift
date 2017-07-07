//
//  BrickModelsTests.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

class BrickModelsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testBrickDescription() {
        let brick = DummyBrick("Brick1")
        XCTAssertEqual(brick.description, "<DummyBrick -Brick1- size: BrickSize(width: BrickKit.BrickDimension.ratio(1.0), height: BrickKit.BrickDimension.auto(BrickKit.BrickDimension.fixed(50.0)))>")
    }

    func testBrickIdentier() {
        let brickView = BrickCollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))

        let expect = expectation(description: "Wait for configure cell")
        let genericBrick = GenericBrick<UILabel>("Brick", size: BrickSize(width: .ratio(ratio: 1), height: .fixed(size: 50))) { label, cell in
            XCTAssertEqual(cell.identifier, "Brick")
            expect.fulfill()
        }
        brickView.setupSingleBrickAndLayout(genericBrick)

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testSectionDescription() {
        let section = BrickSection("Section1", bricks: [
            DummyBrick("Brick1"),
            BrickSection("Section2", bricks: [
                DummyBrick("Brick2", width: .fixed(size: 20)),
                BrickSection("Section3", bricks: [
                    DummyBrick("Brick3", height: .ratio(ratio: 1))
                    ])
                ]),
            DummyBrick("Brick4")
            ])

        let expectedResult: String = "" +
            "<BrickSection -Section1- size: BrickSize(width: BrickKit.BrickDimension.ratio(1.0), height: BrickKit.BrickDimension.auto(BrickKit.BrickDimension.fixed(0.0)))> inset: 0.0 edgeInsets: UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)\n" +
            "    <DummyBrick -Brick1- size: BrickSize(width: BrickKit.BrickDimension.ratio(1.0), height: BrickKit.BrickDimension.auto(BrickKit.BrickDimension.fixed(50.0)))>\n" +
            "    <BrickSection -Section2- size: BrickSize(width: BrickKit.BrickDimension.ratio(1.0), height: BrickKit.BrickDimension.auto(BrickKit.BrickDimension.fixed(0.0)))> inset: 0.0 edgeInsets: UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)\n" +
            "        <DummyBrick -Brick2- size: BrickSize(width: BrickKit.BrickDimension.fixed(20.0), height: BrickKit.BrickDimension.auto(BrickKit.BrickDimension.fixed(50.0)))>\n" +
            "        <BrickSection -Section3- size: BrickSize(width: BrickKit.BrickDimension.ratio(1.0), height: BrickKit.BrickDimension.auto(BrickKit.BrickDimension.fixed(0.0)))> inset: 0.0 edgeInsets: UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)\n" +
            "            <DummyBrick -Brick3- size: BrickSize(width: BrickKit.BrickDimension.ratio(1.0), height: BrickKit.BrickDimension.ratio(1.0))>\n" +
            "    <DummyBrick -Brick4- size: BrickSize(width: BrickKit.BrickDimension.ratio(1.0), height: BrickKit.BrickDimension.auto(BrickKit.BrickDimension.fixed(50.0)))>"

        XCTAssertEqual(section.description, expectedResult)
    }

    func testSettingAndGettingWidth() {
        let brick = Brick(size: BrickSize(width: .fixed(size: 50), height: .auto(estimate: .fixed(size: 50))))
        XCTAssertEqual(brick.width, .fixed(size: 50))
    }
}
