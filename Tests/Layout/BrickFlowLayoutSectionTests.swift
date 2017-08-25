//
//  BrickFlowLayoutSectionTests.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/24/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

class BrickFlowLayoutSectionTests: BrickFlowLayoutBaseTests {

    func testCreateLayoutWithTwoSectionsWithOneItem() {
        setDataSources(SectionsCollectionViewDataSource(sections: [2,1]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1, 1], [1]], heights: [[100, 0], [100]], types: [[.brick, .section(sectionIndex: 1)], [.brick]]))

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 320, height: 100),
                CGRect(x: 0, y: 100, width: 320, height: 100),
            ],
            1 : [
                CGRect(x: 0, y: 100, width: 320, height: 100)
            ]
        ]

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 200))
    }

    func testCreateLayoutWithTwoSectionsWithTwoItemsBelow() {
        setDataSources(SectionsCollectionViewDataSource(sections: [2,2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1, 1], [1, 1]], heights: [[100, 0], [100, 100]], types: [[.brick, .section(sectionIndex: 1)], [.brick, .brick]]))

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 320, height: 100),
                CGRect(x: 0, y: 100, width: 320, height: 200),
            ],
            1 : [
                CGRect(x: 0, y: 100, width: 320, height: 100),
                CGRect(x: 0, y: 200, width: 320, height: 100)
            ]
        ]

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 300))
    }

    func testCreateLayoutWithTwoSectionsWithTwoItemsNextToEachother() {
        setDataSources(SectionsCollectionViewDataSource(sections: [2,2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1, 1], [0.5, 0.5]], heights: [[100, 0], [100, 100]], types: [[.brick, .section(sectionIndex: 1)], [.brick, .brick]]))

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 320, height: 100),
                CGRect(x: 0, y: 100, width: 320, height: 100),
            ],
            1 : [
                CGRect(x: 0, y: 100, width: 160, height: 100),
                CGRect(x: 160, y: 100, width: 160, height: 100)
            ]
        ]

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 200))
    }

    func testCreateLayoutWithThreeSections() {
        setDataSources(SectionsCollectionViewDataSource(sections: [3, 2, 2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1, 0.5, 0.5], [1, 1], [1, 1]], heights: [[100, 0, 0], [100, 100], [100, 100]], types: [[.brick, .section(sectionIndex: 1), .section(sectionIndex: 2)], [.brick, .brick], [.brick, .brick]]))

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 320, height: 100),
                CGRect(x: 0, y: 100, width: 160, height: 200),
                CGRect(x: 160, y: 100, width: 160, height: 200),
            ],
            1 : [
                CGRect(x: 0, y: 100, width: 160, height: 100),
                CGRect(x: 0, y: 200, width: 160, height: 100)
            ],
            2 : [
                CGRect(x: 160, y: 100, width: 160, height: 100),
                CGRect(x: 160, y: 200, width: 160, height: 100)
            ]
        ]

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 300))
    }

    func testCreateLayoutWithThreeSectionsNested() {
        setDataSources(SectionsCollectionViewDataSource(sections: [2, 2, 2, 2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[CGFloat(1.0/4.0), CGFloat(3.0/4.0)], [0.5, 0.5], [1,1], [1,1]], heights: [[100, 0], [0, 0], [100, 100], [100, 100]], types: [[.brick, .section(sectionIndex: 1)], [.section(sectionIndex: 2), .section(sectionIndex: 3)], [.brick, .brick], [.brick, .brick]]))

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 80, height: 100),
                CGRect(x: 80, y: 0, width: 240, height: 200),
            ],
            1 : [
                CGRect(x: 80, y: 0, width: 120, height: 200),
                CGRect(x: 200, y: 0, width: 120, height: 200),
            ],
            2 : [
                CGRect(x: 80, y: 0, width: 120, height: 100),
                CGRect(x: 80, y: 100, width: 120, height: 100),
            ],
            3 : [
                CGRect(x: 200, y: 0, width: 120, height: 100),
                CGRect(x: 200, y: 100, width: 120, height: 100),
            ]
        ]

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 200))
    }
    
    func testCreateLayoutWithThreeSectionsNestedWithEdgeInsets() {
        let customEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        setDataSources(SectionsCollectionViewDataSource(sections: [2, 2, 2, 2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[CGFloat(1.0/4.0), CGFloat(3.0/4.0)], [0.5, 0.5], [1,1], [1,1]], heights: [[100, 0], [0, 0], [100, 100], [100, 100]], edgeInsets: [UIEdgeInsets.zero, customEdgeInsets, customEdgeInsets, customEdgeInsets], types: [[.brick, .section(sectionIndex: 1)], [.section(sectionIndex: 2), .section(sectionIndex: 3)], [.brick, .brick], [.brick, .brick]]))

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 80, height: 100),
                CGRect(x: 80, y: 0, width: 240, height: 280),
            ],
            1 : [
                CGRect(x: 100, y: 20, width: 100, height: 240),
                CGRect(x: 200, y: 20, width: 100, height: 240),
            ],
            2 : [
                CGRect(x: 120, y: 40, width: 60, height: 100),
                CGRect(x: 120, y: 140, width: 60, height: 100),
            ],
            3 : [
                CGRect(x: 220, y: 40, width: 60, height: 100),
                CGRect(x: 220, y: 140, width: 60, height: 100),
            ]
        ]

        let attributes = layout.layoutAttributesForElements(in: collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 280))
    }

    func testNestedSections() {
        /*
         //SECTION 0
         let section = BrickSection("Test", bricks: [

         ExampleLabelBrick("Label Brick", widthRatio: 0.5, backgroundColor: .orangeColor(), text: "In label"),

         // Section 1
         BrickSection("Section", widthRatio: 0.5 , backgroundColor: UIColor.red, bricks: [

         ExampleLabelBrick("Label Brick", widthRatio: 1, backgroundColor: .purpleColor(), text: "In section\nIn section"),
         ExampleLabelBrick("Label Brick", widthRatio: 1, backgroundColor: .brownColor(), text: "In section"),
         ]),

         // Section 2
         BrickSection("Section", widthRatio: 1 , backgroundColor: UIColor.red, bricks: [

         // Section 3
         BrickSection("Section", widthRatio: 1 / 3 , backgroundColor: UIColor.red, bricks: [

         ExampleLabelBrick("Label Brick", widthRatio: 1, backgroundColor: .purpleColor(), text: "In section"),
         ExampleLabelBrick("Label Brick", widthRatio: 1, backgroundColor: .brownColor(), text: "In section"),

         ]),

         // Section 4
         BrickSection("Section", widthRatio: 2 / 3 , backgroundColor: UIColor.red, bricks: [

         // Section 5
         ExampleLabelBrick("Label Brick", backgroundColor: .purpleColor(), text: "In section"),
         ExampleLabelBrick("Label Brick", backgroundColor: .brownColor(), text: "In section"),
         ExampleLabelBrick("Label Brick", backgroundColor: .grayColor(), text: "In section"),

         ], inset: 15),
         ], inset: 5, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)),

         // Section 6
         BrickSection("Section", widthRatio: 0.5 , backgroundColor: UIColor.red, bricks: [

         ExampleLabelBrick("Label Brick", widthRatio: 1, backgroundColor: .purpleColor(), text: "In section"),
         ExampleLabelBrick("Label Brick", widthRatio: 1, backgroundColor: .brownColor(), text: "In section"),
         ]),


         ExampleLabelBrick("Label Brick", widthRatio: 0.5, backgroundColor: .orangeColor(), text: "In label"),
         ExampleLabelBrick("Label Brick", widthRatio: 1, backgroundColor: .orangeColor(), text: "In label"),
         ], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))

         SECTION: 0: 1
         SECTION: 1: 6
         SECTION: 2: 2
         SECTION: 3: 2
         SECTION: 4: 2
         SECTION: 5: 3
         SECTION: 6: 2

         */
        collectionView.frame.size.width = 320
        setDataSources(SectionsCollectionViewDataSource(sections: [1, 6, 2, 2, 2, 3, 2]), brickLayoutDataSource: SectionsLayoutDataSource(
            widthRatios: [
                [1],
                [0.5, 0.5, 1, 0.5, 0.5, 1],
                [1,1],
                [CGFloat(1.0/5.0), CGFloat(4.0/5.0)],
                [1,1],
                [1,1,1],
                [1,1],
            ],
            heights: [
                [0],
                [100, 0, 0, 0, 100, 100],
                [100,100],
                [0, 0],
                [100,100],
                [100,100,100],
                [100,100],
            ],
            edgeInsets: [
                UIEdgeInsets.zero, //UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
                UIEdgeInsets.zero,
                UIEdgeInsets.zero,
                UIEdgeInsets.zero,
                UIEdgeInsets.zero,
                UIEdgeInsets.zero, //UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
                UIEdgeInsets.zero,
            ],
            insets: [
                0, // 10,
                0,
                0,
                0,
                0,
                0,  // 5,
                0
            ],
            types: [
                [.section(sectionIndex: 1)],
                [.brick, .section(sectionIndex: 2), .section(sectionIndex: 3), .section(sectionIndex: 6), .brick, .brick],
                [.brick, .brick],
                [.section(sectionIndex: 4), .section(sectionIndex: 5)],
                [.brick, .brick],
                [.brick, .brick, .brick],
                [.brick, .brick]
            ]))

        
//        let expectedResult = [
//            0 : [
//                CGRect(x: 0, y: 0, width: 320, height: 800),
//            ],
//            1 : [
//                CGRect(x: 0, y: 0, width: 160, height: 100),
//                CGRect(x: 160, y: 0, width: 160, height: 200),
//                CGRect(x: 0, y: 200, width: 320, height: 300),
//                CGRect(x: 0, y: 500, width: 160, height: 200),
//                CGRect(x: 160, y: 500, width: 160, height: 100),
//                CGRect(x: 0, y: 700, width: 320, height: 100),
//            ],
//            2 : [
//                CGRect(x: 160, y: 0, width: 160, height: 100),
//                CGRect(x: 160, y: 100, width: 160, height: 100),
//            ],
//            3 : [
//                CGRect(x: 0, y: 200, width: 320.0 / 5.0, height: 200),
//                CGRect(x: 320.0 / 5.0, y: 200, width: 320.0 * 4.0 / 5.0, height: 300),
//            ],
//            4 : [
//                CGRect(x: 0, y: 200, width: 320.0 / 5.0, height: 100),
//                CGRect(x: 0, y: 300, width: 320.0 / 5.0, height: 100),
//            ],
//            5 : [
//                CGRect(x: 320.0 / 5.0, y: 200, width: 320.0 * 4 / 5.0, height: 100),
//                CGRect(x: 320.0 / 5.0, y: 300, width: 320.0 * 4 / 5.0, height: 100),
//                CGRect(x: 320.0 / 5.0, y: 400, width: 320.0 * 4 / 5.0, height: 100),
//            ],
//            6 : [
//                CGRect(x: 0, y: 500, width: 160, height: 100),
//                CGRect(x: 0, y: 600, width: 160, height: 100),
//            ]
//        ]
//
//        let attributes = layout.layoutAttributesForElements(in: CGRect(x: 0, y: 0, width: collectionViewFrame.width, height: CGFloat.infinity))
//        XCTAssertNotNil(attributes)
//        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize, CGSize(width: 320, height: 800))
    }

    func testThatMultiSectionsAreCalculatedCorrectly() {
        collectionView.registerBrickClass(LabelBrick.self)

        let section = BrickSection(bricks: [
            LabelBrick(width: .ratio(ratio: 0.5), text: "BRICK"),
            BrickSection(width: .ratio(ratio: 0.5), bricks: [
                LabelBrick(text: "BRICK\nBRICK"),
                LabelBrick(text: "BRICK"),
                LabelBrick(text: "BRICK"),
                ], inset: 10),
            BrickSection(bricks: [
                BrickSection(width: .ratio(ratio: 1/3), bricks: [
                    LabelBrick(text: "BRICK"),
                    LabelBrick(text: "BRICK"),
                    ], inset: 5),
                BrickSection(width: .ratio(ratio: 2/3), bricks: [
                    LabelBrick(text: "BRICK"),
                    LabelBrick(text: "BRICK"),
                    LabelBrick(text: "BRICK"),
                    ], inset: 15),
                ], inset: 5, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)),
            BrickSection(width: .ratio(ratio: 0.5), bricks: [
                LabelBrick(text: "BRICK"),
                LabelBrick(text: "BRICK"),
                ], inset: 10),
            LabelBrick(width: .ratio(ratio: 0.5), text: "BRICK"),
            LabelBrick("THIS ONE", text: "BRICK"),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        collectionView.setupSectionAndLayout(section)

        XCTAssertEqual(layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 1))?.frame, CGRect(x: 20, y: 20, width: 135, height: 17))

        let previousToLastFrame = layout.layoutAttributesForItem(at: IndexPath(item: 3, section: 1))!.frame
        XCTAssertEqual(layout.layoutAttributesForItem(at: IndexPath(item: 5, section: 1))?.frame, CGRect(x: 20, y: previousToLastFrame.maxY + 10, width: 280, height: 17))
    }

    func testThatMultiSectionsAreCalculatedCorrectlyOnRotation() {
        collectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection(bricks: [
            DummyBrick(height: .fixed(size: 50)),
            BrickSection(bricks: [
                BrickSection(bricks: [
                    DummyBrick(height: .fixed(size: 50)),
                    ]),
                ]),
            ])

        collectionView.setSection(section)
        collectionView.layoutSubviews()

        var attributes: UICollectionViewLayoutAttributes!

        attributes = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 3))
        XCTAssertEqual(attributes.frame, CGRect(x: 0, y: 50, width: 320, height: 50))

        collectionView.frame.size = CGSize(width: 480, height: 320)
        collectionView.layoutSubviews()

        attributes = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 3))
        XCTAssertEqual(attributes.frame, CGRect(x: 0, y: 50, width: 480, height: 50))

    }

}
