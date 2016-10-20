//
//  BrickSectionDataSourceTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/29/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

class BrickSectionDataSourceTests: XCTestCase {
    let collection: CollectionInfo = CollectionInfo(index: 0, identifier: "")
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        continueAfterFailure = true
    }

    func testInvalidateEmptySection() {
        let section = BrickSection(bricks: [])

        section.invalidateIfNeeded(in: collection)
        XCTAssertEqual(section.sectionIndexPaths[collection]!, [1: NSIndexPath(forItem: 0, inSection: 0)])
        XCTAssertEqual(section.numberOfItems(in: 0, in: collection), 1)
        XCTAssertEqual(section.numberOfItems(in: 1000, in: collection), 0)
    }

    func testInvalidateWithOneLevelSection() {
        let section = BrickSection(bricks: [
            Brick(),
            BrickSection(bricks: [
                Brick()
                ])
            ])
        section.invalidateIfNeeded(in: collection)
        XCTAssertEqual(section.sectionIndexPaths[collection]!, [1: NSIndexPath(forItem: 0, inSection: 0), 2: NSIndexPath(forItem: 1, inSection: 1)])
    }

    func testInvalidateWithOneLevelSectionInversed() {
        let section = BrickSection(bricks: [
            BrickSection(bricks: [
                Brick()
                ]),
            Brick()
            ])
        section.invalidateIfNeeded(in: collection)
        XCTAssertEqual(section.sectionIndexPaths[collection]!, [1: NSIndexPath(forItem: 0, inSection: 0), 2: NSIndexPath(forItem: 0, inSection: 1)])
    }

    func testInvalidateWithMultiLevelsSection() {
        let section = BrickSection(bricks: [
            BrickSection(bricks: [
                Brick(),
                BrickSection(bricks: [
                    Brick(),
                    BrickSection(bricks: [
                        Brick()
                        ])
                    ])
                ]),
            Brick(),
            BrickSection(bricks: [
                BrickSection(bricks: [
                    Brick()
                    ]),
                Brick()
                ])
            ])
        section.invalidateIfNeeded(in: collection)
        XCTAssertEqual(section.sectionIndexPaths[collection]!, [
            1: NSIndexPath(forItem: 0, inSection: 0),
            2: NSIndexPath(forItem: 0, inSection: 1),
            3: NSIndexPath(forItem: 1, inSection: 2),
            4: NSIndexPath(forItem: 1, inSection: 3),
            5: NSIndexPath(forItem: 2, inSection: 1),
            6: NSIndexPath(forItem: 0, inSection: 5),
            ])
    }

    func testInvalidateWithOneLevelBricksRepeatCount() {
        let brick1 = Brick()
        brick1.counts[collection] = 5
        let brick2 = Brick()
        brick2.counts[collection] = 10
        let section = BrickSection(bricks: [
            brick1,
            BrickSection(bricks: [
                Brick()
                ]),
            brick2
            ])
        section.invalidateIfNeeded(in: collection)

        XCTAssertEqual(section.sectionIndexPaths[collection]!, [
            1: NSIndexPath(forItem: 0, inSection: 0),
            2: NSIndexPath(forItem: 5, inSection: 1),
            ])
        XCTAssertEqual(section.indexPathForSection(1, in: collection), NSIndexPath(forItem: 0, inSection: 0))
        XCTAssertEqual(section.indexPathForSection(2, in: collection), NSIndexPath(forItem: 5, inSection: 1))
    }

    func testEmptySection() {
        let section = BrickSection("Section1", bricks: [])

        XCTAssertEqual(section.numberOfSections(in: collection), 2)
        XCTAssertEqual(section.numberOfItems(in: 0, in: collection), 1)
        XCTAssertEqual(section.numberOfItems(in: 1, in: collection), 0)
        XCTAssertEqual(section.brick(at: NSIndexPath(forItem: 0, inSection: 0), in: collection)?.identifier, "Section1")
        XCTAssertEqual(section.index(at: NSIndexPath(forItem: 0, inSection: 0), in: collection), 0)
    }

    func testSectionWithOneLevelBricks() {
        let section = BrickSection("Section1", bricks: [
            Brick("Brick1"),
            Brick("Brick2")
            ])

        XCTAssertEqual(section.numberOfSections(in: collection), 2)
        XCTAssertEqual(section.numberOfItems(in: 0, in: collection), 1)
        XCTAssertEqual(section.numberOfItems(in: 1, in: collection), 2)
        XCTAssertEqual(section.brick(at: NSIndexPath(forItem: 0, inSection: 1), in: collection)?.identifier, "Brick1")
        XCTAssertEqual(section.brick(at: NSIndexPath(forItem: 1, inSection: 1), in: collection)?.identifier, "Brick2")
        XCTAssertNil(section.brick(at: NSIndexPath(forItem: 2, inSection: 1), in: collection))
        XCTAssertNil(section.brick(at: NSIndexPath(forItem: 0, inSection: 2), in: collection))
    }

    func testSectionWithOneLevelBricksRepeatCount() {
        let brick1 = Brick("Brick1")
        brick1.counts[collection] = 5
        let brick2 = Brick("Brick2")
        brick2.counts[collection] = 10
        let section = BrickSection("Section1", bricks: [
            brick1,
            brick2
            ])

        XCTAssertEqual(section.numberOfSections(in: collection), 2)
        XCTAssertEqual(section.numberOfItems(in: 0, in: collection), 1)
        XCTAssertEqual(section.numberOfItems(in: 1, in: collection), 15)
        XCTAssertEqual(section.brick(at: NSIndexPath(forItem: 0, inSection: 1), in: collection)?.identifier, "Brick1")
        XCTAssertEqual(section.brick(at: NSIndexPath(forItem: 1, inSection: 1), in: collection)?.identifier, "Brick1")
        XCTAssertEqual(section.brick(at: NSIndexPath(forItem: 2, inSection: 1), in: collection)?.identifier, "Brick1")
        XCTAssertEqual(section.brick(at: NSIndexPath(forItem: 3, inSection: 1), in: collection)?.identifier, "Brick1")
        XCTAssertEqual(section.brick(at: NSIndexPath(forItem: 4, inSection: 1), in: collection)?.identifier, "Brick1")
        XCTAssertEqual(section.brick(at: NSIndexPath(forItem: 5, inSection: 1), in: collection)?.identifier, "Brick2")
        XCTAssertEqual(section.brick(at: NSIndexPath(forItem: 6, inSection: 1), in: collection)?.identifier, "Brick2")
        XCTAssertEqual(section.brick(at: NSIndexPath(forItem: 7, inSection: 1), in: collection)?.identifier, "Brick2")
        XCTAssertEqual(section.brick(at: NSIndexPath(forItem: 8, inSection: 1), in: collection)?.identifier, "Brick2")
        XCTAssertEqual(section.brick(at: NSIndexPath(forItem: 9, inSection: 1), in: collection)?.identifier, "Brick2")
        XCTAssertEqual(section.brick(at: NSIndexPath(forItem: 10, inSection: 1), in: collection)?.identifier, "Brick2")
        XCTAssertEqual(section.brick(at: NSIndexPath(forItem: 11, inSection: 1), in: collection)?.identifier, "Brick2")
        XCTAssertEqual(section.brick(at: NSIndexPath(forItem: 12, inSection: 1), in: collection)?.identifier, "Brick2")
        XCTAssertEqual(section.brick(at: NSIndexPath(forItem: 13, inSection: 1), in: collection)?.identifier, "Brick2")
        XCTAssertEqual(section.brick(at: NSIndexPath(forItem: 14, inSection: 1), in: collection)?.identifier, "Brick2")

        XCTAssertEqual(section.index(at: NSIndexPath(forItem: 0, inSection: 1), in: collection), 0)
        XCTAssertEqual(section.index(at: NSIndexPath(forItem: 1, inSection: 1), in: collection), 1)
        XCTAssertEqual(section.index(at: NSIndexPath(forItem: 2, inSection: 1), in: collection), 2)
        XCTAssertEqual(section.index(at: NSIndexPath(forItem: 3, inSection: 1), in: collection), 3)
        XCTAssertEqual(section.index(at: NSIndexPath(forItem: 4, inSection: 1), in: collection), 4)
        XCTAssertEqual(section.index(at: NSIndexPath(forItem: 5, inSection: 1), in: collection), 0)
        XCTAssertEqual(section.index(at: NSIndexPath(forItem: 6, inSection: 1), in: collection), 1)
        XCTAssertEqual(section.index(at: NSIndexPath(forItem: 7, inSection: 1), in: collection), 2)
        XCTAssertEqual(section.index(at: NSIndexPath(forItem: 8, inSection: 1), in: collection), 3)
        XCTAssertEqual(section.index(at: NSIndexPath(forItem: 9, inSection: 1), in: collection), 4)
        XCTAssertEqual(section.index(at: NSIndexPath(forItem: 10, inSection: 1), in: collection), 5)
        XCTAssertEqual(section.index(at: NSIndexPath(forItem: 11, inSection: 1), in: collection), 6)
        XCTAssertEqual(section.index(at: NSIndexPath(forItem: 12, inSection: 1), in: collection), 7)
        XCTAssertEqual(section.index(at: NSIndexPath(forItem: 13, inSection: 1), in: collection), 8)
        XCTAssertEqual(section.index(at: NSIndexPath(forItem: 14, inSection: 1), in: collection), 9)
    }

    func testSectionWithTwoLevelBricks() {
        let section = BrickSection("Section1", bricks: [
            Brick("Brick1"),
            BrickSection("Section2", bricks: [
                Brick("Brick2")
                ])
            ])

        XCTAssertEqual(section.numberOfSections(in: collection), 3)
        XCTAssertEqual(section.numberOfItems(in: 0, in: collection), 1)
        XCTAssertEqual(section.numberOfItems(in: 1, in: collection), 2)
        XCTAssertEqual(section.numberOfItems(in: 2, in: collection), 1)
        XCTAssertEqual(section.brick(at: NSIndexPath(forItem: 0, inSection: 0), in: collection)?.identifier, "Section1")
        XCTAssertEqual(section.brick(at: NSIndexPath(forItem: 0, inSection: 1), in: collection)?.identifier, "Brick1")
        XCTAssertEqual(section.brick(at: NSIndexPath(forItem: 1, inSection: 1), in: collection)?.identifier, "Section2")
        XCTAssertEqual(section.brick(at: NSIndexPath(forItem: 0, inSection: 2), in: collection)?.identifier, "Brick2")
    }

    func testIndexPathsForBricksWithIdentifier() {
        let section = BrickSection("Section1", bricks: [
            Brick("Brick1"),
            BrickSection("Section2", bricks: [
                Brick("Brick1"),
                Brick("Brick2")
                ])
            ])
        XCTAssertEqual(section.indexPathsForBricksWithIdentifier("Section1", in: collection), [NSIndexPath(forItem: 0, inSection: 0)])
        XCTAssertEqual(section.indexPathsForBricksWithIdentifier("Section2", in: collection), [NSIndexPath(forItem: 1, inSection: 1)])
        XCTAssertEqual(section.indexPathsForBricksWithIdentifier("Brick1", in: collection), [NSIndexPath(forItem: 0, inSection: 1), NSIndexPath(forItem: 0, inSection: 2)])
        XCTAssertEqual(section.indexPathsForBricksWithIdentifier("Brick2", in: collection), [NSIndexPath(forItem: 1, inSection: 2)])
        XCTAssertEqual(section.indexPathsForBricksWithIdentifier("Brick3", in: collection), [])
    }
    
    func testIndexPathsForBricksWithIdentifierWithRepeatCount() {
        let brick1 = Brick("Brick1")
        brick1.counts[collection] = 5
        let brick2 = Brick("Brick2")
        brick2.counts[collection] = 10
        let section = BrickSection("Section1", bricks: [
            brick1,
            brick2
            ])

        XCTAssertEqual(section.indexPathsForBricksWithIdentifier("Brick1", in: collection), [
            NSIndexPath(forItem: 0, inSection: 1),
            NSIndexPath(forItem: 1, inSection: 1),
            NSIndexPath(forItem: 2, inSection: 1),
            NSIndexPath(forItem: 3, inSection: 1),
            NSIndexPath(forItem: 4, inSection: 1),
            ])
        XCTAssertEqual(section.indexPathsForBricksWithIdentifier("Brick2", in: collection), [
            NSIndexPath(forItem: 5, inSection: 1),
            NSIndexPath(forItem: 6, inSection: 1),
            NSIndexPath(forItem: 7, inSection: 1),
            NSIndexPath(forItem: 8, inSection: 1),
            NSIndexPath(forItem: 9, inSection: 1),
            NSIndexPath(forItem: 10, inSection: 1),
            NSIndexPath(forItem: 11, inSection: 1),
            NSIndexPath(forItem: 12, inSection: 1),
            NSIndexPath(forItem: 13, inSection: 1),
            NSIndexPath(forItem: 14, inSection: 1)
            ])
    }

    func testIndexPathsForBricksWithIdentifierWithRepeatCountAndIndex() {
        let brick1 = Brick("Brick1")
        brick1.counts[collection] = 5
        let brick2 = Brick("Brick2")
        brick2.counts[collection] = 10
        let section = BrickSection("Section1", bricks: [
            brick1,
            brick2
            ])

        XCTAssertEqual(section.indexPathsForBricksWithIdentifier("Brick1", index: 2, in: collection), [
            NSIndexPath(forItem: 2, inSection: 1),
            ])
        XCTAssertEqual(section.indexPathsForBricksWithIdentifier("Brick2", index: 2, in: collection), [
            NSIndexPath(forItem: 7, inSection: 1),
            ])
    }

    func testSectionIndexForSectionAtIndexPath() {
        let section = BrickSection(bricks: [
            Brick(),
            BrickSection(bricks: [
                Brick(),
                BrickSection(bricks: [
                    Brick()
                    ])
                ]),
            BrickSection(bricks: [
                Brick()
                ])
            ])

        XCTAssertEqual(section.sectionIndexForSectionAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), in: collection), 1)
        XCTAssertEqual(section.sectionIndexForSectionAtIndexPath(NSIndexPath(forItem: 1, inSection: 1), in: collection), 2)
        XCTAssertEqual(section.sectionIndexForSectionAtIndexPath(NSIndexPath(forItem: 1, inSection: 2), in: collection), 3)
        XCTAssertEqual(section.sectionIndexForSectionAtIndexPath(NSIndexPath(forItem: 2, inSection: 1), in: collection), 4)
        XCTAssertNil(section.sectionIndexForSectionAtIndexPath(NSIndexPath(forItem: 0, inSection: 5), in: collection))
    }

    func testCurrentSectionCounts() {
        let section = BrickSection(bricks: [
            Brick(),
            BrickSection(bricks: [
                Brick(),
                BrickSection(bricks: [
                    Brick()
                    ])
                ]),
            BrickSection(bricks: [
                Brick()
                ])
            ])
        let expectedResult: [Int: Int] = [
            0: 1,
            1: 3,
            2: 2,
            3: 1,
            4: 1
        ]
        XCTAssertEqual(section.currentSectionCounts(in: collection), expectedResult)
    }

    func testCurrentSectionCountsRepeatCounts() {
        let section = BrickSection(bricks: [
            Brick("Brick1"),
            BrickSection(bricks: [
                Brick("Brick2"),
                BrickSection(bricks: [
                    Brick("Brick3")
                    ])
                ]),
            BrickSection(bricks: [
                Brick("Brick4")
                ])
            ])
        let repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: ["Brick1": 5, "Brick2": 4, "Brick3": 3, "Brick4": 2])
        section.repeatCountDataSource = repeatCountDataSource

        let expectedResult: [Int: Int] = [
            0: 1,
            1: 7,
            2: 5,
            3: 3,
            4: 2
        ]

        XCTAssertEqual(section.currentSectionCounts(in: collection), expectedResult)
    }

    func testCurrentSectionCountsRepeatCountsInvalidate() {
        let section = BrickSection(bricks: [
            Brick("Brick1"),
            BrickSection(bricks: [
                Brick("Brick2"),
                BrickSection(bricks: [
                    Brick("Brick3")
                    ])
                ]),
            BrickSection(bricks: [
                Brick("Brick4")
                ])
            ])

        let fixed = FixedRepeatCountDataSource(repeatCountHash: ["Brick1": 5, "Brick2": 4, "Brick3": 3, "Brick4": 2])
        section.repeatCountDataSource = fixed

        let expectedResultBefore: [Int: Int] = [
            0: 1,
            1: 7,
            2: 5,
            3: 3,
            4: 2
        ]
        XCTAssertEqual(section.currentSectionCounts(in: collection), expectedResultBefore)

        fixed.repeatCountHash = ["Brick1": 3, "Brick2": 2, "Brick3": 1, "Brick4": 0]
        section.invalidateCounts(in: collection)

        let expectedResultAfter: [Int: Int] = [
            0: 1,
            1: 5,
            2: 3,
            3: 1,
            4: 0
        ]
        XCTAssertEqual(section.currentSectionCounts(in: collection), expectedResultAfter)
    }

    /// Repeat count on a BrickSection is not allowed
    func testRepeatCountOnSection() {
        let section = BrickSection(bricks: [
            BrickSection("Section", bricks: [
                Brick("Brick"),
            ])
        ])

        let fixed = FixedRepeatCountDataSource(repeatCountHash: ["Section": 5])
        section.repeatCountDataSource = fixed

        expectFatalError { 
            section.currentSectionCounts(in: self.collection)
        }
    }

    /// Allow to set the repeat count on a subsection
    func testMultipeSectionCountsRepeatCounts() {
        let section1 = BrickSection(bricks: [
            Brick("Brick")
            ])
        let repeatCountDataSource1 = FixedRepeatCountDataSource(repeatCountHash: ["Brick": 5])
        section1.repeatCountDataSource = repeatCountDataSource1

        let section = BrickSection(bricks: [
            Brick("Brick"),
            section1
            ])
        let repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: ["Brick": 15])
        section.repeatCountDataSource = repeatCountDataSource

        let expectedResult: [Int: Int] = [
            0: 1,
            1: 16,
            2: 5,
            ]

        XCTAssertEqual(section.currentSectionCounts(in: collection), expectedResult)
    }

    func testMultipeSectionCountsRepeatCountsInherit() {
        let section1 = BrickSection(bricks: [
            BrickSection(bricks: [
                Brick("Brick")
                ])
            ])
        let repeatCountDataSource1 = FixedRepeatCountDataSource(repeatCountHash: ["Brick": 5])
        section1.repeatCountDataSource = repeatCountDataSource1

        let section = BrickSection(bricks: [
            Brick("Brick"),
            section1
            ])
        let repeatCountDataSource = FixedRepeatCountDataSource(repeatCountHash: ["Brick": 15])
        section.repeatCountDataSource = repeatCountDataSource

        let expectedResult: [Int: Int] = [
            0: 1,
            1: 16,
            2: 1,
            3: 5,
            ]

        XCTAssertEqual(section.currentSectionCounts(in: collection), expectedResult)
    }


    func testMultipeSectionCountsRepeatCountsNested() {

        let section4 = BrickSection(bricks: [
            Brick("Brick")
            ])
        let repeatCountDataSource4 = FixedRepeatCountDataSource(repeatCountHash: ["Brick": 5])
        section4.repeatCountDataSource = repeatCountDataSource4

        let section3 = BrickSection(bricks: [
            section4
        ])
        let repeatCountDataSource3 = FixedRepeatCountDataSource(repeatCountHash: ["Brick": 4])
        section3.repeatCountDataSource = repeatCountDataSource3

        let section2 = BrickSection(bricks: [
            section3
            ])
        let repeatCountDataSource2 = FixedRepeatCountDataSource(repeatCountHash: ["Brick": 3])
        section2.repeatCountDataSource = repeatCountDataSource2

        let section1 = BrickSection(bricks: [
            Brick("Brick")
            ])
        let repeatCountDataSource1 = FixedRepeatCountDataSource(repeatCountHash: ["Brick": 2])
        section1.repeatCountDataSource = repeatCountDataSource1


        let section = BrickSection(bricks: [
            Brick("Brick"),
            section2,
            section1
            ])

        let expectedResult: [Int: Int] = [
            0: 1,
            1: 3,
            2: 1,
            3: 1,
            4: 5,
            5: 2
        ]

        XCTAssertEqual(section.currentSectionCounts(in: collection), expectedResult)
    }


}
