//
//  BrickInvalidationContextTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/17/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

class BrickInvalidationContextTests: XCTestCase {
    var brickViewController: BrickViewController!
    var width:CGFloat!

    override func setUp() {
        super.setUp()

//        continueAfterFailure = false
        brickViewController = BrickViewController()
        width = brickViewController.view.frame.width
    }

    func testDescription() {
        let context = BrickLayoutInvalidationContext(type: .creation)
        XCTAssertEqual(context.description, "BrickLayoutInvalidationContext of type: creation")
    }

    func testInvalidateHeightFirstAttribute() {
        brickViewController.brickCollectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection("Test Section", bricks: [
            DummyBrick("Brick 1", height: .fixed(size: 50)),
            DummyBrick("Brick 2", height: .fixed(size: 50)),
            DummyBrick("Brick 3", height: .fixed(size: 50)),
            ])

        brickViewController.setSection(section)
        brickViewController.collectionView!.layoutSubviews()

        let context = BrickLayoutInvalidationContext(type: .updateHeight(indexPath: IndexPath(item: 0, section: 1), newHeight: 100))
        brickViewController.layout.invalidateLayout(with: context)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 200),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: 100),
                CGRect(x: 0, y: 100, width: width, height: 50),
                CGRect(x: 0, y: 150, width: width, height: 50),
            ]
        ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 200))


    }

    func testInvalidateHeightSecondAttribute() {
        brickViewController.brickCollectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection("Test Section", bricks: [
            DummyBrick("Brick 1", height: .fixed(size: 50)),
            DummyBrick("Brick 2", height: .fixed(size: 50)),
            DummyBrick("Brick 3", height: .fixed(size: 50)),
            ])

        brickViewController.setSection(section)
        brickViewController.collectionView!.layoutSubviews()

        let context = BrickLayoutInvalidationContext(type: .updateHeight(indexPath: IndexPath(item: 1, section: 1), newHeight: 100))
        brickViewController.layout.invalidateLayout(with: context)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 200),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: 50),
                CGRect(x: 0, y: 50, width: width, height: 100),
                CGRect(x: 0, y: 150, width: width, height: 50),
            ]
        ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 200))
    }


    func testInvalidateHeightThirdAttribute() {
        brickViewController.brickCollectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection("Test Section", bricks: [
            DummyBrick("Brick 1", height: .fixed(size: 50)),
            DummyBrick("Brick 2", height: .fixed(size: 50)),
            DummyBrick("Brick 3", height: .fixed(size: 50)),
            ])

        brickViewController.setSection(section)
        brickViewController.collectionView!.layoutSubviews()

        let context = BrickLayoutInvalidationContext(type: .updateHeight(indexPath: IndexPath(item: 2, section: 1), newHeight: 100))
        brickViewController.layout.invalidateLayout(with: context)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 200),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: 50),
                CGRect(x: 0, y: 50, width: width, height: 50),
                CGRect(x: 0, y: 100, width: width, height: 100),
            ]
        ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 200))
    }

    func testInvalidateHeightWithSectionsFirstAttribute() {
        brickViewController.brickCollectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection("Test Section", bricks: [
            BrickSection("Section 1", bricks: [
                DummyBrick("Brick 1", height: .fixed(size: 50)),
                ]),
            BrickSection("Section 2", bricks: [
                DummyBrick("Brick 2", height: .fixed(size: 50)),
                BrickSection("Section 3", bricks: [
                    DummyBrick("Brick 3", height: .fixed(size: 50)),
                    ])
                ]),
            ])

        brickViewController.setSection(section)
        brickViewController.collectionView!.layoutSubviews()

        let context = BrickLayoutInvalidationContext(type: .updateHeight(indexPath: IndexPath(item: 0, section: 2), newHeight: 100))
        brickViewController.layout.invalidateLayout(with: context)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 200),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: 100),
                CGRect(x: 0, y: 100, width: width, height: 100),
            ],
            2 : [
                CGRect(x: 0, y: 0, width: width, height: 100),
            ],
            3 : [
                CGRect(x: 0, y: 100, width: width, height: 50),
                CGRect(x: 0, y: 150, width: width, height: 50),
            ],
            4: [
                CGRect(x: 0, y: 150, width: width, height: 50),
            ]

        ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 200))

    }

    func testInvalidateHeightWithSectionsSecondAttribute() {
        brickViewController.brickCollectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection("Test Section", bricks: [
            BrickSection("Section 1", bricks: [
                DummyBrick("Brick 1", height: .fixed(size: 50)),
                ]),
            BrickSection("Section 2", bricks: [
                DummyBrick("Brick 2", height: .fixed(size: 50)),
                BrickSection("Section 3", bricks: [
                    DummyBrick("Brick 3", height: .fixed(size: 50)),
                    ])
                ]),
            ])

        brickViewController.setSection(section)
        brickViewController.collectionView!.layoutSubviews()

        let context = BrickLayoutInvalidationContext(type: .updateHeight(indexPath: IndexPath(item: 0, section: 3), newHeight: 100))
        brickViewController.layout.invalidateLayout(with: context)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 200),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: 50),
                CGRect(x: 0, y: 50, width: width, height: 150),
            ],
            2 : [
                CGRect(x: 0, y: 0, width: width, height: 50),
            ],
            3 : [
                CGRect(x: 0, y: 50, width: width, height: 100),
                CGRect(x: 0, y: 150, width: width, height: 50),
            ],
            4: [
                CGRect(x: 0, y: 150, width: width, height: 50),
            ]

        ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 200))


    }

    func testInvalidateHeightWithSectionsThirdAttribute() {
        brickViewController.brickCollectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection("Test Section", bricks: [
            BrickSection("Section 1", bricks: [
                DummyBrick("Brick 1", height: .fixed(size: 50)),
                ]),
            BrickSection("Section 2", bricks: [
                DummyBrick("Brick 2", height: .fixed(size: 50)),
                BrickSection("Section 3", bricks: [
                    DummyBrick("Brick 3", height: .fixed(size: 50)),
                    ])
                ]),
            ])

        brickViewController.setSection(section)
        brickViewController.collectionView!.layoutSubviews()

        let context = BrickLayoutInvalidationContext(type: .updateHeight(indexPath: IndexPath(item: 0, section: 4), newHeight: 100))
        brickViewController.layout.invalidateLayout(with: context)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 200),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: 50),
                CGRect(x: 0, y: 50, width: width, height: 150),
            ],
            2 : [
                CGRect(x: 0, y: 0, width: width, height: 50),
            ],
            3 : [
                CGRect(x: 0, y: 50, width: width, height: 50),
                CGRect(x: 0, y: 100, width: width, height: 100),
            ],
            4: [
                CGRect(x: 0, y: 100, width: width, height: 100),
            ]

        ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 200))


    }

    func testInvalidateHeightWithNestedSections() {
        brickViewController.brickCollectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection("Test Section", bricks: [
            BrickSection("Section 1", bricks: [
                DummyBrick("Brick 1", height: .fixed(size: 50)),
                ]),
            BrickSection("Section 2", bricks: [
                BrickSection("Section 3", bricks: [
                    DummyBrick("Brick 2", height: .fixed(size: 50)),
                    ]),
                BrickSection("Section 4", bricks: [
                    DummyBrick("Brick 3", height: .fixed(size: 50)),
                    ])
                ]),
            ])

        brickViewController.setSection(section)
        brickViewController.collectionView!.layoutSubviews()

        let context = BrickLayoutInvalidationContext(type: .updateHeight(indexPath: IndexPath(item: 0, section: 4), newHeight: 100))
        brickViewController.layout.invalidateLayout(with: context)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 200),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: 50),
                CGRect(x: 0, y: 50, width: width, height: 150),
            ],
            2 : [
                CGRect(x: 0, y: 0, width: width, height: 50),
            ],
            3 : [
                CGRect(x: 0, y: 50, width: width, height: 100),
                CGRect(x: 0, y: 150, width: width, height: 50),
            ],
            4: [
                CGRect(x: 0, y: 50, width: width, height: 100),
            ],
            5: [
                CGRect(x: 0, y: 150, width: width, height: 50),
            ]

        ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 200))


    }

    func testInvalidateHeightWithNestedSectionsMultiBricks() {
        brickViewController.brickCollectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection("Test Section", bricks: [
            BrickSection("Section 1", bricks: [
                DummyBrick("Brick 1", height: .fixed(size: 50)),
                DummyBrick("Brick 2", height: .fixed(size: 50)),
                ]),
            BrickSection("Section 2", bricks: [
                BrickSection("Section 3", bricks: [
                    DummyBrick("Brick 3", height: .fixed(size: 50)),
                    ]),
                BrickSection("Section 4", bricks: [
                    DummyBrick("Brick 4", height: .fixed(size: 50)),
                    ])
                ]),
            ])

        brickViewController.setSection(section)
        brickViewController.collectionView!.layoutSubviews()

        let context = BrickLayoutInvalidationContext(type: .updateHeight(indexPath: IndexPath(item: 0, section: 2), newHeight: 100))
        brickViewController.layout.invalidateLayout(with: context)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 250),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: 150),
                CGRect(x: 0, y: 150, width: width, height: 100),
            ],
            2 : [
                CGRect(x: 0, y: 0, width: width, height: 100),
                CGRect(x: 0, y: 100, width: width, height: 50),
            ],
            3 : [
                CGRect(x: 0, y: 150, width: width, height: 50),
                CGRect(x: 0, y: 200, width: width, height: 50),
            ],
            4: [
                CGRect(x: 0, y: 150, width: width, height: 50),
            ],
            5: [
                CGRect(x: 0, y: 200, width: width, height: 50),
            ]

        ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 250))


    }

    func testInvalidateHeightWithNestedSectionsMultiBricksZeroHeight() {
        brickViewController.brickCollectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection("Test Section", bricks: [
            BrickSection("Section 1", bricks: [
                DummyBrick("Brick 1", height: .fixed(size: 50)),
                ]),
            BrickSection("Section 2", bricks: [
                BrickSection("Section 3", bricks: [
                    DummyBrick("Brick 3", height: .fixed(size: 50)),
                    ]),
                BrickSection("Section 4", bricks: [
                    DummyBrick("Brick 4", height: .fixed(size: 50)),
                    ])
                ]),
            ])

        brickViewController.setSection(section)
        brickViewController.collectionView!.layoutSubviews()

        let context = BrickLayoutInvalidationContext(type: .updateHeight(indexPath: IndexPath(item: 0, section: 2), newHeight: 0))
        brickViewController.layout.invalidateLayout(with: context)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 100),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: 100),
            ],
            3 : [
                CGRect(x: 0, y: 0, width: width, height: 50),
                CGRect(x: 0, y: 50, width: width, height: 50),
            ],
            4: [
                CGRect(x: 0, y: 0, width: width, height: 50),
            ],
            5: [
                CGRect(x: 0, y: 50, width: width, height: 50),
            ]

        ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 100))


    }

    func testInvalidateHeightButSameHeight() {
        brickViewController.brickCollectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection("Test Section", bricks: [
            BrickSection("Section 1", bricks: [
                DummyBrick("Brick 1", width: .ratio(ratio: 1/2), height: .fixed(size: 50)),
                DummyBrick("Brick 1", width: .ratio(ratio: 1/2), height: .fixed(size: 25)),
                ]),
            BrickSection("Section 2", bricks: [
                BrickSection("Section 3", bricks: [
                    DummyBrick("Brick 2", height: .fixed(size: 50)),
                    ]),
                BrickSection("Section 4", bricks: [
                    DummyBrick("Brick 3", height: .fixed(size: 50)),
                    ])
                ]),
            ])

        brickViewController.setSection(section)
        brickViewController.collectionView!.layoutSubviews()

        let context = BrickLayoutInvalidationContext(type: .updateHeight(indexPath: IndexPath(item: 1, section: 2), newHeight: 50))
        brickViewController.layout.invalidateLayout(with: context)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 150),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: 50),
                CGRect(x: 0, y: 50, width: width, height: 100),
            ],
            2 : [
                CGRect(x: 0, y: 0, width: width / 2, height: 50),
                CGRect(x: width / 2, y: 0, width: width / 2, height: 50),
            ],
            3 : [
                CGRect(x: 0, y: 50, width: width, height: 50),
                CGRect(x: 0, y: 100, width: width, height: 50),
            ],
            4: [
                CGRect(x: 0, y: 50, width: width, height: 50),
            ],
            5: [
                CGRect(x: 0, y: 100, width: width, height: 50),
            ]

        ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 150))


    }

    func testInvalidateHeightWithHideBrickBehavior() {
        let hideBehaviorDataSource = FixedHideBehaviorDataSource(indexPaths: [])
        brickViewController.brickCollectionView.layout.hideBehaviorDataSource = hideBehaviorDataSource

        brickViewController.brickCollectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection("Test Section", bricks: [
            BrickSection("Section 1", bricks: [
                DummyBrick("Brick 1", height: .fixed(size: 50)),
                DummyBrick("Brick 2", height: .fixed(size: 50)),
                ]),
            BrickSection("Section 2", bricks: [
                BrickSection("Section 3", bricks: [
                    DummyBrick("Brick 3", height: .fixed(size: 50)),
                    ]),
                BrickSection("Section 4", bricks: [
                    DummyBrick("Brick 4", height: .fixed(size: 50)),
                    ])
                ]),
            ])

        brickViewController.setSection(section)
        brickViewController.collectionView!.layoutSubviews()


        // Hide a brick
        hideBehaviorDataSource.indexPaths.append(IndexPath(item: 0, section: 2))

        var context = BrickLayoutInvalidationContext(type: .updateVisibility)
        brickViewController.layout.invalidateLayout(with: context)

        var expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 150),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: 50),
                CGRect(x: 0, y: 50, width: width, height: 100),
            ],
            2 : [
                CGRect(x: 0, y: 0, width: width, height: 50),
            ],
            3 : [
                CGRect(x: 0, y: 50, width: width, height: 50),
                CGRect(x: 0, y: 100, width: width, height: 50),
            ],
            4: [
                CGRect(x: 0, y: 50, width: width, height: 50),
            ],
            5: [
                CGRect(x: 0, y: 100, width: width, height: 50),
            ]

        ]

        var attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 150))

        // Show a brick
        hideBehaviorDataSource.indexPaths.removeAll()

        context = BrickLayoutInvalidationContext(type: .updateVisibility)
        brickViewController.layout.invalidateLayout(with: context)

        expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 200),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: 100),
                CGRect(x: 0, y: 100, width: width, height: 100),
            ],
            2 : [
                CGRect(x: 0, y: 0, width: width, height: 50),
                CGRect(x: 0, y: 50, width: width, height: 50),
            ],
            3 : [
                CGRect(x: 0, y: 100, width: width, height: 50),
                CGRect(x: 0, y: 150, width: width, height: 50),
            ],
            4: [
                CGRect(x: 0, y: 100, width: width, height: 50),
            ],
            5: [
                CGRect(x: 0, y: 150, width: width, height: 50),
            ]

        ]

        attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 200))

    }

    func testInvalidateHeightWithHideSectionBehavior() {
        let hideBehaviorDataSource = FixedHideBehaviorDataSource(indexPaths: [])
        brickViewController.brickCollectionView.layout.hideBehaviorDataSource = hideBehaviorDataSource

        brickViewController.brickCollectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection("Test Section", bricks: [
            BrickSection("Section 1", bricks: [
                DummyBrick("Brick 1", height: .fixed(size: 50)),
                DummyBrick("Brick 2", height: .fixed(size: 50)),
                ]),
            BrickSection("Section 2", bricks: [
                BrickSection("Section 3", bricks: [
                    DummyBrick("Brick 3", height: .fixed(size: 50)),
                    ]),
                BrickSection("Section 4", bricks: [
                    DummyBrick("Brick 4", height: .fixed(size: 50)),
                    ])
                ]),
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))


        brickViewController.setSection(section)


        // Hide a section

        brickViewController.collectionView!.layoutSubviews()

        hideBehaviorDataSource.indexPaths.append(IndexPath(item: 0, section: 1))

        var context = BrickLayoutInvalidationContext(type: .updateVisibility)
        brickViewController.layout.invalidateLayout(with: context)

        var expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 120),
            ],
            1 : [
                CGRect(x: 10, y: 10, width: width - 20, height: 100),
            ],
            3 : [
                CGRect(x: 10, y: 10, width: width - 20, height: 50),
                CGRect(x: 10, y: 60, width: width - 20, height: 50),
            ],
            4: [
                CGRect(x: 10, y: 10, width: width - 20, height: 50),
            ],
            5: [
                CGRect(x: 10, y: 60, width: width - 20, height: 50),
            ]

        ]

        var attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 120))

        // Unhide a section

        hideBehaviorDataSource.indexPaths.removeAll()

        context = BrickLayoutInvalidationContext(type: .updateVisibility)
        brickViewController.layout.invalidateLayout(with: context)

        /*

         Actual: [
         0: [(0.0, 0.0, 320.0, 230.0)],
         1: [(10.0, 10.0, 300.0, 100.0), (10.0, 120.0, 300.0, 100.0)],
         2: [(10.0, 60.0, 300.0, 50.0), (10.0, 10.0, 300.0, 50.0)],
         3: [(10.0, 170.0, 300.0, 50.0), (10.0, 120.0, 300.0, 50.0)]]
         4: [(10.0, 120.0, 300.0, 50.0)],
         5: [(10.0, 170.0, 300.0, 50.0)],
         */

        expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 230),
            ],
            1 : [
                CGRect(x: 10, y: 10, width: width - 20, height: 100),
                CGRect(x: 10, y: 120, width: width - 20, height: 100),
            ],
            2 : [
                CGRect(x: 10, y: 10, width: width - 20, height: 50),
                CGRect(x: 10, y: 60, width: width - 20, height: 50),
            ],
            3 : [
                CGRect(x: 10, y: 120, width: width - 20, height: 50),
                CGRect(x: 10, y: 170, width: width - 20, height: 50),
            ],
            4: [
                CGRect(x: 10, y: 120, width: width - 20, height: 50),
            ],
            5: [
                CGRect(x: 10, y: 170, width: width - 20, height: 50),
            ]
        ]

        attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 230))

    }

    func testInvalidateHeightWithHideBrickBehaviorBrickInSection() {
        let hideBehaviorDataSource = FixedHideBehaviorDataSource(indexPaths: [])
        brickViewController.brickCollectionView.layout.hideBehaviorDataSource = hideBehaviorDataSource

        brickViewController.brickCollectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection("Test Section", bricks: [
            BrickSection("Section 1", bricks: [
                DummyBrick("Brick 1", height: .fixed(size: 50)),
                ], inset: 10, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)),
            BrickSection("Section 2", bricks: [
                DummyBrick("Brick 2", height: .fixed(size: 50)),
                ], inset: 10, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)),
            BrickSection("Section 3", bricks: [
                DummyBrick("Brick 3", height: .fixed(size: 50)),
                ], inset: 10, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)),
            BrickSection("Section 4", bricks: [
                DummyBrick("Brick 4", height: .fixed(size: 50)),
                ], inset: 10, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)),
            ])

        brickViewController.setSection(section)
        brickViewController.collectionView!.layoutSubviews()


        // Show a brick

        var context = BrickLayoutInvalidationContext(type: .updateVisibility)
        brickViewController.layout.invalidateLayout(with: context)

        /*
         0: [(0.0, 0.0, 320.0, 280.0)],
         1: [(0.0, 210.0, 320.0, 70.0), (0.0, 0.0, 320.0, 70.0), (0.0, 140.0, 320.0, 70.0), (0.0, 70.0, 320.0, 70.0)]]
         2: [(10.0, 10.0, 300.0, 50.0)],
         3: [(10.0, 80.0, 300.0, 50.0)],
         4: [(10.0, 150.0, 300.0, 50.0)],
         5: [(10.0, 220.0, 300.0, 50.0)],

         */

        var expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 280),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: 70),
                CGRect(x: 0, y: 70, width: width, height: 70),
                CGRect(x: 0, y: 140, width: width, height: 70),
                CGRect(x: 0, y: 210, width: width, height: 70),
            ],
            2 : [
                CGRect(x: 10, y: 10, width: width - 20, height: 50),
            ],
            3 : [
                CGRect(x: 10, y: 80, width: width - 20, height: 50),
            ],
            4 : [
                CGRect(x: 10, y: 150, width: width - 20, height: 50),
            ],
            5 : [
                CGRect(x: 10, y: 220, width: width - 20, height: 50),
            ],
            ]

        var attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 280))


        // Hide a brick
        hideBehaviorDataSource.indexPaths = [IndexPath(item: 0, section: 2), IndexPath(item: 0, section: 3)]

        context = BrickLayoutInvalidationContext(type: .updateVisibility)
        brickViewController.layout.invalidateLayout(with: context)

        expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 140),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: 70),
                CGRect(x: 0, y: 70, width: width, height: 70),
            ],
            4: [
                CGRect(x: 10, y: 10, width: width - 20, height: 50),
            ],
            5: [
                CGRect(x: 10, y: 80, width: width - 20, height: 50),
            ]

        ]

        attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 140))

    }

    func testHideBrickBehaviorMultipleBrickSections() {
        let hideBehaviorDataSource = FixedHideBehaviorDataSource(indexPaths: [IndexPath(item: 0, section: 1), IndexPath(item: 1, section: 1)])
        brickViewController.brickCollectionView.layout.hideBehaviorDataSource = hideBehaviorDataSource

        brickViewController.brickCollectionView.registerNib(UINib(nibName: "DummyBrick100", bundle: Bundle(for: DummyBrick.self)), forBrickWithIdentifier: "Brick")

        let section = BrickSection("Test Section", bricks: [
            BrickSection("Section 1", bricks: [
                DummyBrick("Brick")
                ]),
            BrickSection("Section 2", bricks: [
                DummyBrick("Brick")
                ]),
            BrickSection("Section 3", bricks: [
                DummyBrick("Brick")
                ]),
            BrickSection("Section 4", bricks: [
                DummyBrick("Brick")
                ]),
            ])

        brickViewController.setSection(section)
        brickViewController.collectionView!.layoutSubviews()

//        let context = BrickLayoutInvalidationContext(type: .UpdateVisibility)
//        brickViewController.layout.invalidateLayoutWithContext(context)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 200),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: 100),
                CGRect(x: 0, y: 100, width: width, height: 100),
            ],
            4 : [
                CGRect(x: 0, y: 0, width: width, height: 100),
            ],
            5 : [
                CGRect(x: 0, y: 100, width: width, height: 100),
            ],
            ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 200))


    }

    func testHideBrickBehaviorMultipleBrickNestedSections() {
        brickViewController.brickCollectionView.registerNib(UINib(nibName: "DummyBrick100", bundle: Bundle(for: DummyBrick.self)), forBrickWithIdentifier: "Brick")

        let section = BrickSection("Test Section", bricks: [
            BrickSection("Section 1", bricks: [
                DummyBrick("Brick"),
                BrickSection("Section 2", bricks: [
                    DummyBrick("Brick")
                    ])
                ]),
            ])

        brickViewController.setSection(section)
        brickViewController.collectionView!.layoutSubviews()


        let hideBehaviorDataSource = FixedHideBehaviorDataSource(indexPaths: [])
        hideBehaviorDataSource.indexPaths = [IndexPath(item: 0, section: 1)]
        brickViewController.brickCollectionView.layout.hideBehaviorDataSource = hideBehaviorDataSource
        brickViewController.brickCollectionView.invalidateVisibility()

        let expectedResult: [Int: [CGRect]] = [:]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 0))
    }

    func testHideBrickBehaviorMultipleBrickNestedSectionsWithHidden() {
        brickViewController.brickCollectionView.registerNib(UINib(nibName: "DummyBrick100", bundle: Bundle(for: DummyBrick.self)), forBrickWithIdentifier: "Brick")

        let section = BrickSection("Test Section", bricks: [
            BrickSection("Section 1", bricks: [
                DummyBrick("Brick"),
                BrickSection("Section 2", bricks: [
                    DummyBrick("Brick")
                    ])
                ]),
            ])

        brickViewController.setSection(section)
        brickViewController.collectionView!.layoutSubviews()

        section.bricks[0].isHidden = true
        brickViewController.brickCollectionView.invalidateVisibility()

        let expectedResult: [Int: [CGRect]] = [:]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 0))
    }

    func testWrongCollectionView() {
        let context = BrickLayoutInvalidationContext(type: .updateVisibility)
        XCTAssertFalse(context.invalidateWithLayout(UICollectionViewFlowLayout()))
    }

    func testThatInvalidateWithAlignRowHeightsReportsCorrectly() {
        brickViewController.brickCollectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection("Test Section", bricks: [
            DummyBrick("Brick 1", width: .ratio(ratio: 1/2), height: .fixed(size: 50)),
            DummyBrick("Brick 2", width: .ratio(ratio: 1/2), height: .fixed(size: 50)),
            ], alignRowHeights: true)

        brickViewController.setSection(section)
        brickViewController.collectionView!.layoutSubviews()

        section.bricks[1].height = .fixed(size: 100)
        let context = BrickLayoutInvalidationContext(type: .updateHeight(indexPath: IndexPath(item: 1, section: 1), newHeight: 100))
        brickViewController.layout.invalidateLayout(with: context)
        brickViewController.brickCollectionView.layoutIfNeeded()

        let cell = brickViewController.brickCollectionView.cellForItem(at: IndexPath(item: 0, section: 1))

        XCTAssertEqual(cell?.frame, CGRect(x: 0, y: 0, width: width/2, height: 100))

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 100),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width/2, height: 100),
                CGRect(x: width/2, y: 0, width: width/2, height: 100),
            ]
        ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 100))
    }

    func testThatContentOffsetAdjustmentIsUpdatedWhenTopBrickUpdates() {
        brickViewController.brickCollectionView.registerBrickClass(DummyBrick.self)

        let section = BrickSection("Test Section", bricks: [
            DummyBrick("Brick 1", height: .fixed(size: 50)),
            DummyBrick("Brick 2", height: .fixed(size: 50)),
            DummyBrick("Brick 3", height: .fixed(size: 1000)),
            ])

        brickViewController.brickCollectionView.setupSectionAndLayout(section)

        section.bricks[0].height = .fixed(size: 100)
        var context = BrickLayoutInvalidationContext(type: .updateHeight(indexPath: IndexPath(item: 0, section: 1), newHeight: 100))
        brickViewController.layout.invalidateLayout(with: context)
        XCTAssertEqual(context.contentOffsetAdjustment, CGPoint(x: 0, y: 0))
        brickViewController.brickCollectionView.layoutIfNeeded()
        XCTAssertEqual(brickViewController.brickCollectionView.contentOffset.y, 0)

        brickViewController.brickCollectionView.contentOffset.y = 100
        section.bricks[0].height = .fixed(size: 150)
        context = BrickLayoutInvalidationContext(type: .updateHeight(indexPath: IndexPath(item: 0, section: 1), newHeight: 150))
        brickViewController.layout.invalidateLayout(with: context)
        XCTAssertEqual(context.contentOffsetAdjustment, CGPoint(x: 0, y: 50))
        brickViewController.brickCollectionView.layoutIfNeeded()
        #if os(iOS) // On tvOS this check fails
            XCTAssertEqual(brickViewController.brickCollectionView.contentOffset.y, 150)
        #endif

        section.bricks[0].height = .fixed(size: 100)
        context = BrickLayoutInvalidationContext(type: .updateHeight(indexPath: IndexPath(item: 0, section: 1), newHeight: 100))
        brickViewController.layout.invalidateLayout(with: context)
        XCTAssertEqual(context.contentOffsetAdjustment, CGPoint(x: 0, y: -50))
        brickViewController.brickCollectionView.layoutIfNeeded()
        #if os(iOS) // On tvOS this check fails
            XCTAssertEqual(brickViewController.brickCollectionView.contentOffset.y, 100)
        #endif
        
    }
    
}
