//
//  BrickFlowLayoutZIndexTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 6/17/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

private let zIndexMap: (_ attribute: UICollectionViewLayoutAttributes) -> Int = { $0.zIndex }
private let zIndexSort: (Int, Int) -> Bool = { $0 < $1 }

class BrickFlowLayoutZIndexTests: BrickFlowLayoutBaseTests {
    
    /*
    section a
    ----brick aa
    ----section ab
    --------brick ab1
    --------section ab2
    ------------brick ab21
    ------------brick ab22
    ------------brick ab23
    ----brick ac
    ----section ad
    --------brick ad1
    --------section ad2
    ------------brick ad21
    ------------brick ad22
    ------------brick ad23
    ----brick ae
     */

    override func setUp() {
        super.setUp()

        let section = BrickSection("a", bricks: [
            DummyBrick("aa"),
            BrickSection("ab", bricks: [
                DummyBrick("ab1"),
                BrickSection("ab2", bricks: [
                    DummyBrick("ab21"),
                    DummyBrick("ab22"),
                    DummyBrick("ab23"),
                    ]),
                ]),
            DummyBrick("ac"),
            BrickSection("ad", bricks: [
                DummyBrick("ad1"),
                BrickSection("ad2", bricks: [
                    DummyBrick("ad21"),
                    DummyBrick("ad22"),
                    DummyBrick("ad23"),
                    ]),
                ]),
            DummyBrick("ae"),
            ])
        collectionView.registerBrickClass(DummyBrick.self)
        collectionView.setSection(section)
    }

    func testThatResetWithNoDataSourceWorks() {
        let zIndexer = BrickZIndexer()
        zIndexer.reset(for: BrickFlowLayout())

        XCTAssertEqual(zIndexer.maxZIndex, 0)
        XCTAssertEqual(layout.zIndexer.zIndex(for: IndexPath(item: 0, section: 0)), 0)
    }

}

// MARK: - TopDown
extension BrickFlowLayoutZIndexTests {

    func testTopDownZIndex() {
        layout.invalidateLayout()
        layout.prepare()
        collectionView.layoutSubviews()

        let offset: Int = 15

        let expectedResult = [
            0 : [
                (0 - offset),
            ],
            1 : [
                (15 - offset), (9 - offset), (8 - offset), (2 - offset), (1 - offset)
            ],
            2 : [
                (14 - offset), (10 - offset)
            ],
            3 : [
                (13 - offset), (12 - offset), (11 - offset)
            ],
            4 : [
                (7 - offset), (3 - offset)
            ],
            5 : [
                (6 - offset), (5 - offset), (4 - offset)
            ],
            ]

        let attributes = layout.layoutAttributesForElements(in: CGRect(origin:CGPoint.zero, size: layout.collectionViewContentSize))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, map: zIndexMap, expectedResult: expectedResult, sort: zIndexSort))
    }

    func testThatIndexPathsAreCorrectForNestedSections() {
        /**
         S 0
         --B 5
         --S 1
         ----S 2
         ------B 4
         ------B 3
         */

        let section = BrickSection(bricks: [
            DummyBrick(width: .ratio(ratio: 0.5)),
            BrickSection(bricks: [
                BrickSection(width: .ratio(ratio: 1/2), bricks: [
                    DummyBrick(),
                    DummyBrick(),
                    ]),
                ]),
            ])
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let offset: Int = 5
        let expectedResult = [
            0 : [
                (0 - offset),
            ],
            1 : [
                (5 - offset), (1 - offset)
            ],
            2 : [
                (2 - offset)
            ],
            3 : [
                (3 - offset), (4 - offset)
            ]
        ]

        /*
         Optional(<BrickKit.BrickLayoutAttributes: 0x7f8cca525f60> index path: (<IndexPath: 0xc000000000000016> {length = 2, path = 0 - 0}); frame = (0 0; 320 114);  originalFrame: (0.0, 0.0, 320.0, 114.0); identifier: )
         Optional(<BrickKit.BrickLayoutAttributes: 0x7f8cca4249b0> index path: (<IndexPath: 0xc000000000000116> {length = 2, path = 1 - 0}); frame = (0 0; 160 38); zIndex = 5;  originalFrame: (0.0, 0.0, 160.0, 38.0); identifier: )
         Optional(<BrickKit.BrickLayoutAttributes: 0x7f8cca4249b0> index path: (<IndexPath: 0xc000000000200116> {length = 2, path = 1 - 1}); frame = (0 38; 320 76); zIndex = 1;  originalFrame: (0.0, 38.0, 320.0, 76.0); identifier: )
         Optional(<BrickKit.BrickLayoutAttributes: 0x7f8cca4249b0> index path: (<IndexPath: 0xc000000000000216> {length = 2, path = 2 - 0}); frame = (0 38; 160 76); zIndex = 4;  originalFrame: (0.0, 38.0, 160.0, 76.0); identifier: )
         Optional(<BrickKit.BrickLayoutAttributes: 0x7f8cca525f60> index path: (<IndexPath: 0xc000000000000316> {length = 2, path = 3 - 0}); frame = (0 38; 160 38); zIndex = 4;  originalFrame: (0.0, 38.0, 160.0, 38.0); identifier: )
         Optional(<BrickKit.BrickLayoutAttributes: 0x7f8cca4249b0> index path: (<IndexPath: 0xc000000000200316> {length = 2, path = 3 - 1}); frame = (0 76; 160 38); zIndex = 3;  originalFrame: (0.0, 76.0, 160.0, 38.0); identifier: )
         */

        let expectedRanges: [Int: [SectionRange]] = [
            0: [
                SectionRange(range: 0..<1,startIndex: 0)
            ],
            1: [
                SectionRange(range: 0..<1,startIndex: 5),
                SectionRange(range: 1..<2,startIndex: 1),
            ],
            2: [
                SectionRange(range: 0..<1,startIndex: 2),
            ],
            3: [
                SectionRange(range: 0..<2,startIndex: 4)
            ],
        ]

        XCTAssertEqual(layout.zIndexer.sectionRanges[0], expectedRanges[0]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[1], expectedRanges[1]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[2], expectedRanges[2]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[3], expectedRanges[3]!)


        let attributes = layout.layoutAttributesForElements(in: CGRect(origin:CGPoint.zero, size: layout.collectionViewContentSize))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, map: zIndexMap, expectedResult: expectedResult, sort: zIndexSort))
    }

    /*
     section a 0
     ----brick aa 15
     ----section ab 9
     --------brick ab1 14
     --------section ab2 10
     ------------brick ab21 13
     ------------brick ab22 12
     ------------brick ab23 11
     ----brick ac 8
     ----section ad 2
     --------brick ad1 7
     --------section ad2 3
     ------------brick ad21 6
     ------------brick ad22 5
     ------------brick ad23 4
     ----brick ae 1

     */
    func testTopDownZIndexer() {
        layout.invalidateLayout()
        layout.prepare()
        collectionView.layoutSubviews()

        let expectedRanges: [Int: [SectionRange]] = [
            0: [
                SectionRange(range: 0..<1,startIndex: 0)
            ],
            1: [
                SectionRange(range: 0..<1,startIndex: 15),
                SectionRange(range: 1..<3,startIndex: 9),
                SectionRange(range: 3..<5,startIndex: 2)
            ],
            2: [
                SectionRange(range: 0..<1,startIndex: 14),
                SectionRange(range: 1..<2,startIndex: 10)
            ],
            3: [
                SectionRange(range: 0..<3,startIndex: 13)
            ],
            4: [
                SectionRange(range: 0..<1,startIndex: 7),
                SectionRange(range: 1..<2,startIndex: 3)
            ],
            5: [
                SectionRange(range: 0..<3,startIndex: 6)
            ]
        ]

        XCTAssertEqual(layout.zIndexer.sectionRanges[0], expectedRanges[0]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[1], expectedRanges[1]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[2], expectedRanges[2]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[3], expectedRanges[3]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[4], expectedRanges[4]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[5], expectedRanges[5]!)
        
    }

    func testThatZIndexIsReturnedTopDown() {
        let ranges = [
            SectionRange(range: 0..<1,startIndex: 15),
            SectionRange(range: 1..<3,startIndex: 9),
            SectionRange(range: 3..<5,startIndex: 2)
        ]

        let zIndex: BrickLayoutZIndexBehavior = .topDown
        XCTAssertEqual(zIndex.zIndexFromRanges(ranges, index: 0), 15)
        XCTAssertEqual(zIndex.zIndexFromRanges(ranges, index: 1), 9)
        XCTAssertEqual(zIndex.zIndexFromRanges(ranges, index: 2), 8)
        XCTAssertEqual(zIndex.zIndexFromRanges(ranges, index: 3), 2)
        XCTAssertEqual(zIndex.zIndexFromRanges(ranges, index: 4), 1)
        XCTAssertEqual(zIndex.zIndexFromRanges(ranges, index: 5), 0)
        XCTAssertEqual(zIndex.zIndexFromRanges(ranges, index: -1), 0)
    }

    func testThatZIndexIsReturnedTopDown2() {
        let ranges = [
            SectionRange(range: 0..<3,startIndex: 3)
        ]

        let zIndex: BrickLayoutZIndexBehavior = .topDown
        XCTAssertEqual(zIndex.zIndexFromRanges(ranges, index: 0), 3)
        XCTAssertEqual(zIndex.zIndexFromRanges(ranges, index: 1), 2)
        XCTAssertEqual(zIndex.zIndexFromRanges(ranges, index: 2), 1)
    }

    func testVerySimpleTopDownIndexer() {
        /*
         section a 0
         ----brick aa 3
         ----brick ab 2
         ----brick ac 1
         */
        let section = BrickSection("a", bricks: [
            DummyBrick("aa"),
            DummyBrick("ab"),
            DummyBrick("ac")
            ])

        collectionView.registerBrickClass(DummyBrick.self)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let expectedRanges: [Int: [SectionRange]] = [
            0: [
                SectionRange(range: 0..<1,startIndex: 0)
            ],
            1: [
                SectionRange(range: 0..<3,startIndex: 3),
            ],
        ]


        XCTAssertEqual(layout.zIndexer.sectionRanges[0], expectedRanges[0]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[1], expectedRanges[1]!)
        
    }

    func testSimpleTopDownIndexer() {
        /*
         section a 0
         ----brick aa 5
         ----section ab 2
         --------brick ab1 4
         --------brick ab2 3
         ----brick ac 1


         */
        let section = BrickSection("a", bricks: [
            DummyBrick("aa"),
            BrickSection("ab", bricks: [
                DummyBrick("ab1"),
                DummyBrick("ab2"),
                ]),
            DummyBrick("ac")
            ])
        collectionView.registerBrickClass(DummyBrick.self)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let expectedRanges: [Int: [SectionRange]] = [
            0: [
                SectionRange(range: 0..<1,startIndex: 0)
            ],
            1: [
                SectionRange(range: 0..<1,startIndex: 5),
                SectionRange(range: 1..<3,startIndex: 2),
            ],
            2: [
                SectionRange(range: 0..<2,startIndex: 4)
            ]
        ]


        XCTAssertEqual(layout.zIndexer.sectionRanges[0], expectedRanges[0]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[1], expectedRanges[1]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[2], expectedRanges[2]!)
        
    }

    func testMultiSectionTopDownIndexer() {
        /*
         section a 0
         ----brick aa 9
         ----section ab 6
         --------brick ab1 8
         --------brick ab2 7
         ----brick ac 5
         ----section ad 2
         --------brick ad1 4
         --------brick ad2 3
         ----brick ae 1
         */
        let section = BrickSection("a", bricks: [
            DummyBrick("aa"),
            BrickSection("ab", bricks: [
                DummyBrick("ab1"),
                DummyBrick("ab2")
                ]),
            DummyBrick("ac"),
            BrickSection("ad", bricks: [
                DummyBrick("ad1"),
                DummyBrick("ad2")
                ]),
            DummyBrick("ae"),
            ])

        collectionView.registerBrickClass(DummyBrick.self)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let expectedRanges: [Int: [SectionRange]] = [
            0: [
                SectionRange(range: 0..<1,startIndex: 0)
            ],
            1: [
                SectionRange(range: 0..<1,startIndex: 9),
                SectionRange(range: 1..<3,startIndex: 6),
                SectionRange(range: 3..<5,startIndex: 2),
            ],
            2: [
                SectionRange(range: 0..<2,startIndex: 8)
            ],
            3: [
                SectionRange(range: 0..<2,startIndex: 4)
            ],
            ]


        XCTAssertEqual(layout.zIndexer.sectionRanges[0], expectedRanges[0]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[1], expectedRanges[1]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[2], expectedRanges[2]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[3], expectedRanges[3]!)
    }

    func testNestedIndexer() {
        /*

         section a 0
         ----brick aa 9
         ----section ab 2
         --------brick ab1 8
         --------section ab2 4
         ------------brick ab21 7
         ------------brick ab22 6
         ------------brick ab23 5
         --------brick ab3 3
         ----brick ac 1

         */
        let section = BrickSection("a", bricks: [
            DummyBrick("aa"),
            BrickSection("ab", bricks: [
                DummyBrick("ab1"),
                BrickSection("ab2", bricks: [
                    DummyBrick("ab21"),
                    DummyBrick("ab22"),
                    DummyBrick("ab23"),
                    ]),
                DummyBrick("ab3"),
                ]),
            DummyBrick("ac"),
            ])

        collectionView.registerBrickClass(DummyBrick.self)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let expectedRanges: [Int: [SectionRange]] = [
            0: [
                SectionRange(range: 0..<1,startIndex: 0)
            ],
            1: [
                SectionRange(range: 0..<1,startIndex: 9),
                SectionRange(range: 1..<3,startIndex: 2),
            ],
            2: [
                SectionRange(range: 0..<1,startIndex: 8),
                SectionRange(range: 1..<3,startIndex: 4)
            ],
            3: [
                SectionRange(range: 0..<3,startIndex: 7)
            ],
            ]


        XCTAssertEqual(layout.zIndexer.sectionRanges[0], expectedRanges[0]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[1], expectedRanges[1]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[2], expectedRanges[2]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[3], expectedRanges[3]!)
    }

    func testDeepNestedTopDownIndexer() {
        /*

         section a 0
         ----brick aa 12
         ----section ab 2
         --------brick ab1 11
         --------section ab2 4
         ------------brick ab21 10
         ------------section ab22 6
         ----------------brick ab221 9
         ----------------brick ab222 8
         ----------------brick ab223 7
         ------------brick ab23 5
         --------brick ab3 3
         ----brick ac 1

         */
        let section = BrickSection("a", bricks: [
            DummyBrick("aa"),
            BrickSection("ab", bricks: [
                DummyBrick("ab1"),
                BrickSection("ab2", bricks: [
                    DummyBrick("ab21"),
                    BrickSection("ab22", bricks: [
                        DummyBrick("ab221"),
                        DummyBrick("ab222"),
                        DummyBrick("ab223"),
                        ]),
                    DummyBrick("ab23"),
                    ]),
                DummyBrick("ab3"),
                ]),
            DummyBrick("ac"),
            ])

        collectionView.registerBrickClass(DummyBrick.self)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let expectedRanges: [Int: [SectionRange]] = [
            0: [
                SectionRange(range: 0..<1,startIndex: 0)
            ],
            1: [
                SectionRange(range: 0..<1,startIndex: 12),
                SectionRange(range: 1..<3,startIndex: 2),
            ],
            2: [
                SectionRange(range: 0..<1,startIndex: 11),
                SectionRange(range: 1..<3,startIndex: 4)
            ],
            3: [
                SectionRange(range: 0..<1,startIndex: 10),
                SectionRange(range: 1..<3,startIndex: 6)
            ],
            4: [
                SectionRange(range: 0..<3,startIndex: 9)
            ],
            ]


        XCTAssertEqual(layout.zIndexer.sectionRanges[0], expectedRanges[0]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[1], expectedRanges[1]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[2], expectedRanges[2]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[3], expectedRanges[3]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[4], expectedRanges[4]!)
    }


}

// MARK: - BottomUp
extension BrickFlowLayoutZIndexTests {
    /*
     section a 0
     ----brick aa 1
     ----section ab 2
     --------brick ab1 3
     --------section ab2 4
     ------------brick ab21 5
     ------------brick ab22 6
     ------------brick ab23 7
     ----brick ac 8
     ----section ad 9
     --------brick ad1 10
     --------section ad2 11
     ------------brick ad21 12
     ------------brick ad22 13
     ------------brick ad23 14
     ----brick ae 15
     */

    func testBottomUpZIndexer() {
        layout.zIndexBehavior = .bottomUp
        layout.invalidateLayout()
        layout.prepare()
        collectionView.layoutSubviews()

        let expectedRanges: [Int: [SectionRange]] = [
            0: [
                SectionRange(range: 0..<1,startIndex: 0)
            ],
            1: [
                SectionRange(range: 0..<2,startIndex: 1),
                SectionRange(range: 2..<4,startIndex: 8),
                SectionRange(range: 4..<5,startIndex: 15)
            ],
            2: [
                SectionRange(range: 0..<2,startIndex: 3)
            ],
            3: [
                SectionRange(range: 0..<3,startIndex: 5)
            ],
            4: [
                SectionRange(range: 0..<2,startIndex: 10)
            ],
            5: [
                SectionRange(range: 0..<3,startIndex: 12)
            ]
        ]


        XCTAssertEqual(layout.zIndexer.sectionRanges[0], expectedRanges[0]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[1], expectedRanges[1]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[2], expectedRanges[2]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[3], expectedRanges[3]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[4], expectedRanges[4]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[5], expectedRanges[5]!)
        
    }

    func testSimpleBottomUpIndexer() {
        /*

         section a 0
         ----brick aa 1
         ----section ab 2
         --------brick ab1 3
         --------brick ab2 4
         ----brick ac 5

         */
        layout.zIndexBehavior = .bottomUp

        let section = BrickSection("a", bricks: [
            DummyBrick("aa"),
            BrickSection("ab", bricks: [
                DummyBrick("ab1"),
                DummyBrick("ab2"),
                ]),
            DummyBrick("ac")
            ])
        collectionView.registerBrickClass(DummyBrick.self)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let expectedRanges: [Int: [SectionRange]] = [
            0: [
                SectionRange(range: 0..<1,startIndex: 0)
            ],
            1: [
                SectionRange(range: 0..<2,startIndex: 1),
                SectionRange(range: 2..<3,startIndex: 5),
            ],
            2: [
                SectionRange(range: 0..<2,startIndex: 3)
            ]
        ]


        XCTAssertEqual(layout.zIndexer.sectionRanges[0], expectedRanges[0]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[1], expectedRanges[1]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[2], expectedRanges[2]!)
        
    }

    func testMultiSectionButtomUpIndexer() {
        /*
         section a 0
         ----brick aa 1
         ----section ab 2
         --------brick ab1 3
         --------brick ab2 4
         ----brick ac 5
         ----section ad 6
         --------brick ad1 7
         --------brick ad2 8
         ----brick ae 9
         */
        let section = BrickSection("a", bricks: [
            DummyBrick("aa"),
            BrickSection("ab", bricks: [
                DummyBrick("ab1"),
                DummyBrick("ab2")
                ]),
            DummyBrick("ac"),
            BrickSection("ad", bricks: [
                DummyBrick("ad1"),
                DummyBrick("ad2")
                ]),
            DummyBrick("ae"),
            ])

        layout.zIndexBehavior = .bottomUp

        collectionView.registerBrickClass(DummyBrick.self)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let expectedRanges: [Int: [SectionRange]] = [
            0: [
                SectionRange(range: 0..<1,startIndex: 0)
            ],
            1: [
                SectionRange(range: 0..<2,startIndex: 1),
                SectionRange(range: 2..<4,startIndex: 5),
                SectionRange(range: 4..<5,startIndex: 9),
            ],
            2: [
                SectionRange(range: 0..<2,startIndex: 3)
            ],
            3: [
                SectionRange(range: 0..<2,startIndex: 7)
            ],
            ]


        XCTAssertEqual(layout.zIndexer.sectionRanges[0], expectedRanges[0]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[1], expectedRanges[1]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[2], expectedRanges[2]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[3], expectedRanges[3]!)
    }

    func testNestedBottomUpIndexer() {
        /*

         section a 0
         ----brick aa 1
         ----section ab 2
         --------brick ab1 3
         --------section ab2 4
         ------------brick ab21 5
         ------------brick ab22 6
         ------------brick ab23 7
         --------brick ab3 8
         ----brick ac 9

         */
        let section = BrickSection("a", bricks: [
            DummyBrick("aa"),
            BrickSection("ab", bricks: [
                DummyBrick("ab1"),
                BrickSection("ab2", bricks: [
                    DummyBrick("ab21"),
                    DummyBrick("ab22"),
                    DummyBrick("ab23"),
                    ]),
                DummyBrick("ab3"),
                ]),
            DummyBrick("ac"),
            ])

        layout.zIndexBehavior = .bottomUp

        collectionView.registerBrickClass(DummyBrick.self)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let expectedRanges: [Int: [SectionRange]] = [
            0: [
                SectionRange(range: 0..<1,startIndex: 0)
            ],
            1: [
                SectionRange(range: 0..<2,startIndex: 1),
                SectionRange(range: 2..<3,startIndex: 9),
            ],
            2: [
                SectionRange(range: 0..<2,startIndex: 3),
                SectionRange(range: 2..<3,startIndex: 8)
            ],
            3: [
                SectionRange(range: 0..<3,startIndex: 5)
            ],
            ]


        XCTAssertEqual(layout.zIndexer.sectionRanges[0], expectedRanges[0]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[1], expectedRanges[1]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[2], expectedRanges[2]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[3], expectedRanges[3]!)
    }
    
    func testDeepNestedBottomUpIndexer() {
        /*

         section a 0
         ----brick aa 1
         ----section ab 2
         --------brick ab1 3
         --------section ab2 4
         ------------brick ab21 5
         ------------section ab22 6
         ----------------brick ab221 7
         ----------------brick ab222 8
         ----------------brick ab223 9
         ------------brick ab23 10
         --------brick ab3 11
         ----brick ac 12

         */
        let section = BrickSection("a", bricks: [
            DummyBrick("aa"),
            BrickSection("ab", bricks: [
                DummyBrick("ab1"),
                BrickSection("ab2", bricks: [
                    DummyBrick("ab21"),
                    BrickSection("ab22", bricks: [
                        DummyBrick("ab221"),
                        DummyBrick("ab222"),
                        DummyBrick("ab223"),
                        ]),
                    DummyBrick("ab23"),
                    ]),
                DummyBrick("ab3"),
                ]),
            DummyBrick("ac"),
            ])

        layout.zIndexBehavior = .bottomUp

        collectionView.registerBrickClass(DummyBrick.self)
        collectionView.setSection(section)
        collectionView.layoutSubviews()

        let expectedRanges: [Int: [SectionRange]] = [
            0: [
                SectionRange(range: 0..<1,startIndex: 0)
            ],
            1: [
                SectionRange(range: 0..<2,startIndex: 1),
                SectionRange(range: 2..<3,startIndex: 12),
            ],
            2: [
                SectionRange(range: 0..<2,startIndex: 3),
                SectionRange(range: 2..<3,startIndex: 11)
            ],
            3: [
                SectionRange(range: 0..<2,startIndex: 5),
                SectionRange(range: 2..<3,startIndex: 10)
            ],
            4: [
                SectionRange(range: 0..<3,startIndex: 7)
            ],
            ]


        XCTAssertEqual(layout.zIndexer.sectionRanges[0], expectedRanges[0]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[1], expectedRanges[1]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[2], expectedRanges[2]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[3], expectedRanges[3]!)
        XCTAssertEqual(layout.zIndexer.sectionRanges[4], expectedRanges[4]!)
    }
    

    func testThatZIndexIsReturnedBottomUp() {
        let ranges = [
            SectionRange(range: 0..<2,startIndex: 1),
            SectionRange(range: 2..<4,startIndex: 8),
            SectionRange(range: 4..<5,startIndex: 15)
        ]
        let zIndex: BrickLayoutZIndexBehavior = .bottomUp
        XCTAssertEqual(zIndex.zIndexFromRanges(ranges, index: 0), 1)
        XCTAssertEqual(zIndex.zIndexFromRanges(ranges, index: 1), 2)
        XCTAssertEqual(zIndex.zIndexFromRanges(ranges, index: 2), 8)
        XCTAssertEqual(zIndex.zIndexFromRanges(ranges, index: 3), 9)
        XCTAssertEqual(zIndex.zIndexFromRanges(ranges, index: 4), 15)
    }

    func testBottomUpZIndex() {
        layout.zIndexBehavior = .bottomUp
        collectionView.layoutSubviews()

        let offset: Int = 15
        let expectedResult = [
            0 : [
                (0 - offset),
            ],
            1 : [
                (1 - offset), (2 - offset), (8 - offset), (9 - offset), (15 - offset)
            ],
            2 : [
                (3 - offset), (4 - offset)
            ],
            3 : [
                (5 - offset), (6 - offset), (7 - offset)
            ],
            4 : [
                (10 - offset), (11 - offset)
            ],
            5 : [
                (12 - offset), (13 - offset), (14 - offset)
            ],
            ]

        let attributes = layout.layoutAttributesForElements(in: CGRect(origin:CGPoint.zero, size: layout.collectionViewContentSize))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, map: zIndexMap, expectedResult: expectedResult, sort: zIndexSort))
    }

}

// MARK: - MaxZIndex
extension BrickFlowLayoutZIndexTests {
    func testMaxZIndex() {
        layout.invalidateLayout()
        layout.prepare()
        collectionView.layoutSubviews()

        XCTAssertEqual(layout.maxZIndex, 15)
    }

    func testThatInvalidateRepeatCountWithBottomStickyRespectsZIndex() {
        let repeatIndexPath = IndexPath(item: 15, section: 2)
        let stickyIndexPath = IndexPath(item: 1, section: 1)

        let section = BrickSection(bricks: [
            BrickSection(bricks: [
                DummyBrick("Brick", height: .fixed(size: 20))
                ]),
            DummyBrick("Footer", height: .fixed(size: 50))
            ])
        let repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: ["Brick": 15])
        section.repeatCountDataSource = repeatCountDataSource
        let stickyDataSource = FixedStickyLayoutBehaviorDataSource(indexPaths: [stickyIndexPath])
        collectionView.layout.behaviors.insert(StickyFooterLayoutBehavior(dataSource: stickyDataSource))
        collectionView.layout.zIndexBehavior = .bottomUp

        collectionView.setupSectionAndLayout(section)

        let expectation = self.expectation(description: "Invalidate Repeat Counts")

        repeatCountDataSource.repeatCountHash = ["Brick": 16]
        collectionView.invalidateRepeatCounts { (completed, insertedIndexPaths, deletedIndexPaths) in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        let repeatIndex = collectionView.cellForItem(at: repeatIndexPath)!.layer.zPosition
        let stickyIndex = collectionView.cellForItem(at: stickyIndexPath)!.layer.zPosition

        XCTAssertEqual(repeatIndex + 1, stickyIndex)
    }
}
