//
//  BrickFlowLayoutSectionTests.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/24/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest

class BrickFlowLayoutSectionTests: BrickFlowLayoutBaseTests {

    func testCreateLayoutWithTwoSectionsWithOneItem() {
        setDataSources(SectionsCollectionViewDataSource(sections: [2,1]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1, 1], [1]], heights: [[100, 0], [100]], types: [[.Brick, .Section(sectionIndex: 1)], [.Brick]]))

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 320, height: 100),
                CGRect(x: 0, y: 100, width: 320, height: 100),
            ],
            1 : [
                CGRect(x: 0, y: 100, width: 320, height: 100)
            ]
        ]

        let attributes = layout.layoutAttributesForElementsInRect(collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 320, height: 200))
    }

    func testCreateLayoutWithTwoSectionsWithTwoItemsBelow() {
        setDataSources(SectionsCollectionViewDataSource(sections: [2,2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1, 1], [1, 1]], heights: [[100, 0], [100, 100]], types: [[.Brick, .Section(sectionIndex: 1)], [.Brick, .Brick]]))

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

        let attributes = layout.layoutAttributesForElementsInRect(collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 320, height: 300))
    }

    func testCreateLayoutWithTwoSectionsWithTwoItemsNextToEachother() {
        setDataSources(SectionsCollectionViewDataSource(sections: [2,2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1, 1], [0.5, 0.5]], heights: [[100, 0], [100, 100]], types: [[.Brick, .Section(sectionIndex: 1)], [.Brick, .Brick]]))

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

        let attributes = layout.layoutAttributesForElementsInRect(collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 320, height: 200))
    }

    func testCreateLayoutWithThreeSections() {
        setDataSources(SectionsCollectionViewDataSource(sections: [3, 2, 2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1, 0.5, 0.5], [1, 1], [1, 1]], heights: [[100, 0, 0], [100, 100], [100, 100]], types: [[.Brick, .Section(sectionIndex: 1), .Section(sectionIndex: 2)], [.Brick, .Brick], [.Brick, .Brick]]))

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

        let attributes = layout.layoutAttributesForElementsInRect(collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 320, height: 300))
    }

    func testCreateLayoutWithThreeSectionsNested() {
        setDataSources(SectionsCollectionViewDataSource(sections: [2, 2, 2, 2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1/4, 3/4], [0.5, 0.5], [1,1], [1,1]], heights: [[100, 0], [0, 0], [100, 100], [100, 100]], types: [[.Brick, .Section(sectionIndex: 1)], [.Section(sectionIndex: 2), .Section(sectionIndex: 3)], [.Brick, .Brick], [.Brick, .Brick]]))

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

        let attributes = layout.layoutAttributesForElementsInRect(collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 320, height: 200))
    }
    
    func testCreateLayoutWithThreeSectionsNestedWithEdgeInsets() {
        let customEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        setDataSources(SectionsCollectionViewDataSource(sections: [2, 2, 2, 2]), brickLayoutDataSource: SectionsLayoutDataSource(widthRatios: [[1/4, 3/4], [0.5, 0.5], [1,1], [1,1]], heights: [[100, 0], [0, 0], [100, 100], [100, 100]], edgeInsets: [UIEdgeInsetsZero, customEdgeInsets, customEdgeInsets, customEdgeInsets], types: [[.Brick, .Section(sectionIndex: 1)], [.Section(sectionIndex: 2), .Section(sectionIndex: 3)], [.Brick, .Brick], [.Brick, .Brick]]))

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

        let attributes = layout.layoutAttributesForElementsInRect(collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 320, height: 280))
    }

    func testNestedSections() {
        /*
         //SECTION 0
        let section = BrickSection("Test", bricks: [

            ExampleLabelBrick("Label Brick", widthRatio: 0.5, backgroundColor: .orangeColor(), text: "In label"),

            // Section 1
            BrickSection("Section", widthRatio: 0.5 , backgroundColor: .redColor(), bricks: [

                ExampleLabelBrick("Label Brick", widthRatio: 1, backgroundColor: .purpleColor(), text: "In section\nIn section"),
                ExampleLabelBrick("Label Brick", widthRatio: 1, backgroundColor: .brownColor(), text: "In section"),
                ]),

            // Section 2
            BrickSection("Section", widthRatio: 1 , backgroundColor: .redColor(), bricks: [
            
                // Section 3
                BrickSection("Section", widthRatio: 1 / 3 , backgroundColor: .redColor(), bricks: [

                    ExampleLabelBrick("Label Brick", widthRatio: 1, backgroundColor: .purpleColor(), text: "In section"),
                    ExampleLabelBrick("Label Brick", widthRatio: 1, backgroundColor: .brownColor(), text: "In section"),

                    ]),
         
                // Section 4
                BrickSection("Section", widthRatio: 2 / 3 , backgroundColor: .redColor(), bricks: [

                    // Section 5
                    ExampleLabelBrick("Label Brick", backgroundColor: .purpleColor(), text: "In section"),
                    ExampleLabelBrick("Label Brick", backgroundColor: .brownColor(), text: "In section"),
                    ExampleLabelBrick("Label Brick", backgroundColor: .grayColor(), text: "In section"),

                    ], inset: 15),
                ], inset: 5, edgeInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)),
         
            // Section 6
            BrickSection("Section", widthRatio: 0.5 , backgroundColor: .redColor(), bricks: [
         
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
                [1.0/5.0, 4.0/5.0],
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
                UIEdgeInsetsZero, //UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
                UIEdgeInsetsZero,
                UIEdgeInsetsZero,
                UIEdgeInsetsZero,
                UIEdgeInsetsZero,
                UIEdgeInsetsZero, //UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5),
                UIEdgeInsetsZero,
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
                [.Section(sectionIndex: 1)],
                [.Brick, .Section(sectionIndex: 2), .Section(sectionIndex: 3), .Section(sectionIndex: 6), .Brick, .Brick],
                [.Brick, .Brick],
                [.Section(sectionIndex: 4), .Section(sectionIndex: 5)],
                [.Brick, .Brick],
                [.Brick, .Brick, .Brick],
                [.Brick, .Brick]
            ]))

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 320, height: 800),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: 160, height: 100),
                CGRect(x: 160, y: 0, width: 160, height: 200),
                CGRect(x: 0, y: 200, width: 320, height: 300),
                CGRect(x: 0, y: 500, width: 160, height: 200),
                CGRect(x: 160, y: 500, width: 160, height: 100),
                CGRect(x: 0, y: 700, width: 320, height: 100),
            ],
            2 : [
                CGRect(x: 160, y: 0, width: 160, height: 100),
                CGRect(x: 160, y: 100, width: 160, height: 100),
            ],
            3 : [
                CGRect(x: 0, y: 200, width: 320.0 / 5.0, height: 200),
                CGRect(x: 320.0 / 5.0, y: 200, width: 320.0 * 4.0 / 5.0, height: 300),
            ],
            4 : [
                CGRect(x: 0, y: 200, width: 320.0 / 5.0, height: 100),
                CGRect(x: 0, y: 300, width: 320.0 / 5.0, height: 100),
            ],
            5 : [
                CGRect(x: 320.0 / 5.0, y: 200, width: 320.0 * 4 / 5.0, height: 100),
                CGRect(x: 320.0 / 5.0, y: 300, width: 320.0 * 4 / 5.0, height: 100),
                CGRect(x: 320.0 / 5.0, y: 400, width: 320.0 * 4 / 5.0, height: 100),
            ],
            6 : [
                CGRect(x: 0, y: 500, width: 160, height: 100),
                CGRect(x: 0, y: 600, width: 160, height: 100),
            ]
        ]

        let attributes = layout.layoutAttributesForElementsInRect(collectionViewFrame)
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 320, height: 800))

    }
    

}
