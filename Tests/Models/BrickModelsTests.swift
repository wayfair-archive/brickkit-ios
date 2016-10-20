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
        XCTAssertEqual(brick.description, "<DummyBrick -Brick1- width: Ratio(1.0) - height: Auto(BrickKit.BrickDimension.Fixed(50.0))>")
    }

    func testSectionDescription() {
        let section = BrickSection("Section1", bricks: [
            DummyBrick("Brick1"),
            BrickSection("Section2", bricks: [
                DummyBrick("Brick2", width: .Fixed(size: 20)),
                BrickSection("Section3", bricks: [
                    DummyBrick("Brick3", height: .Ratio(ratio: 1))
                    ])
                ]),
            DummyBrick("Brick4")
            ])

        let expectedResult: String = "" +
            "<BrickSection -Section1- width: Ratio(1.0) - height: Auto(BrickKit.BrickDimension.Fixed(0.0))> inset: 0.0 edgeInsets: UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)\n" +
            "    <DummyBrick -Brick1- width: Ratio(1.0) - height: Auto(BrickKit.BrickDimension.Fixed(50.0))>\n" +
            "    <BrickSection -Section2- width: Ratio(1.0) - height: Auto(BrickKit.BrickDimension.Fixed(0.0))> inset: 0.0 edgeInsets: UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)\n" +
            "        <DummyBrick -Brick2- width: Fixed(20.0) - height: Auto(BrickKit.BrickDimension.Fixed(50.0))>\n" +
            "        <BrickSection -Section3- width: Ratio(1.0) - height: Auto(BrickKit.BrickDimension.Fixed(0.0))> inset: 0.0 edgeInsets: UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)\n" +
            "            <DummyBrick -Brick3- width: Ratio(1.0) - height: Ratio(1.0)>\n" +
            "    <DummyBrick -Brick4- width: Ratio(1.0) - height: Auto(BrickKit.BrickDimension.Fixed(50.0))>"

        XCTAssertEqual(section.description, expectedResult)
    }
}
