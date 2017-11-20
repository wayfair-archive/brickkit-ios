//
//  BrickViewControllerTests.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

class MockPreviewingDelegate: BrickPreviewingDelegate {
    var successfulPop: Bool = false
    
    func previewViewController(for brick: Brick) -> UIViewController? {
        return PreviewViewController(with: brick)
    }
    
    func commit(viewController: UIViewController) {
        successfulPop = true
    }
}

class PreviewViewController: BrickViewController, BrickViewControllerPreviewing {
    var sourceBrick: Brick
    
    required init(with source: Brick) {
        sourceBrick = source
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BrickViewControllerTests: XCTestCase {
    private class RepeatCountDelegate: BrickRepeatCountDataSource {
        var repeatCount = 0
        var increment = 0
        
        init(startingCount: Int, increment: Int) {
            self.repeatCount = startingCount
            self.increment = increment
        }
        
        func repeatCount(for identifier: String, with collectionIndex: Int, collectionIdentifier: String) -> Int {
            let returnValue = repeatCount
            repeatCount += increment
            return returnValue
        }
    }

    var brickViewController: BrickViewController!
    var width:CGFloat!

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        brickViewController = BrickViewController()
        brickViewController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        width = brickViewController.view.frame.width
    }

    func testDeinit() {
        var viewController: BrickViewController? = TestBrickViewController(nibName: "TestBrickViewController", bundle: Bundle(for: type(of: self)))

        expectation(forNotification: NSNotification.Name(rawValue: "BrickViewController.deinit"), object: nil, handler: nil)
        viewController?.viewDidLoad()
        viewController = nil
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNil(viewController)
    }
    
    func testDeinitLabelBrick() {
        var viewController: TestBrickViewController? = TestBrickViewController(nibName: "TestBrickViewController", bundle: Bundle(for: type(of: self)))
        viewController?.labelTest = true
        
        expectation(forNotification: NSNotification.Name(rawValue: "BrickViewController.deinit"), object: nil, handler: nil)
        viewController?.viewDidLoad()
        viewController = nil
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNil(viewController)
    }
    
    func testFromStoryBoard() {
        let viewController = UIStoryboard(name: "TestBrickViewController", bundle: Bundle(for: type(of: self))).instantiateInitialViewController() as? BrickViewController
        XCTAssertNotNil(viewController)
        viewController?.viewDidLoad()
        XCTAssertTrue(viewController?.collectionView is BrickCollectionView)
    }

    func testFromNib() {
        let viewController = TestBrickViewController(nibName: "TestBrickViewController", bundle: Bundle(for: type(of: self)))
        XCTAssertNotNil(viewController)
        viewController.viewDidLoad()
        XCTAssertTrue(viewController.collectionView is BrickCollectionView)
    }

    func testRegistrationDataSource() {
        let viewController = TestBrickViewController(nibName: "TestBrickViewController", bundle: Bundle(for: type(of: self)))
        viewController.viewDidLoad()
        XCTAssertTrue(viewController.brickRegistered)
    }

    func testWithSectionWithSameNameAsBrick() {
        let section = BrickSection("DummyBrick", bricks: [
            DummyBrick("Brick 1"),
            ])

        brickViewController.brickCollectionView.setupSectionAndLayout(section)
        XCTAssertTrue(brickViewController.brickCollectionView.dataSource?.collectionView(brickViewController.brickCollectionView, cellForItemAt: IndexPath(item: 0, section: 0)) is BrickSectionCell)
    }

    func testWithDummyBrick() {
        let section = BrickSection("Test Section", bricks: [
            DummyBrick("Brick 1"),
            ])

        brickViewController.brickCollectionView.setupSectionAndLayout(section)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: width * 2),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: width * 2),
            ]
        ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: width * 2))

    }

    func testWithDummyBrickFixedWidth() {
        let section = BrickSection("Test Section", bricks: [
            DummyBrick("Brick 1", width: .fixed(size: 100)),
            ])

        brickViewController.brickCollectionView.setupSectionAndLayout(section)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 100 * 2),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: 100, height: 100 * 2),
            ]
        ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: 100 * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 100 * 2))

    }

    func testWithDummyBrickWithFixedHeight() {
        let section = BrickSection("Test Section", bricks: [
            DummyBrick("Brick 1", height: .fixed(size: 100)),
            ])

        brickViewController.brickCollectionView.setupSectionAndLayout(section)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 100),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: 100),
            ]
        ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: 100)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 100))

    }


    func testWithDummyBrickWithHeightRatio() {
        let section = BrickSection("Test Section", bricks: [
            DummyBrick("Brick 1", height: .ratio(ratio: 5)),
            ])

        brickViewController.brickCollectionView.setupSectionAndLayout(section)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: width * 5),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: width * 5),
            ]
        ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 5)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: width * 5))

    }


    func _testWithDummyBrickWithoutRegistering() {
        let size = CGSize(width: 100, height: 100)
        brickViewController.view.frame = CGRect(origin: CGPoint.zero, size: size)

        let section = BrickSection("Test Section", bricks: [
            DummyBrick("Brick 1"),
            ])

        brickViewController.setSection(section)
    }

    func testWithDummyBricks() {
        let section = BrickSection("Test Section", bricks: [
            DummyBrick("Brick 1"),
            DummyBrick("Brick 2")
            ])
        brickViewController.brickCollectionView.setupSectionAndLayout(section)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: width * 4),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: width * 2),
                CGRect(x: 0, y: width * 2, width: width, height: width * 2)
            ],
            ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 4)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: width * 4))

    }

    func testWithDummyBricksSideBySide() {
        let section = BrickSection("Test Section", bricks: [
            DummyBrick("Brick 1", width: .ratio(ratio: 0.5)),
            DummyBrick("Brick 2", width: .ratio(ratio: 0.5))
            ])

        brickViewController.brickCollectionView.setupSectionAndLayout(section)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: width),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width / 2, height: width),
                CGRect(x: width / 2, y: 0, width: width / 2, height: width)
            ]
        ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: width))


    }

    func testWithDummyBricksInNestedSectionsSimple() {
        brickViewController.registerNib(UINib(nibName: "DummyBrick150", bundle: Bundle(for: DummyBrick.self)), forBrickWithIdentifier: "Brick")

        let section = BrickSection("Test", bricks: [
            BrickSection("Test Section 1", bricks: [
                BrickSection("Test Section 2", bricks: [
                    DummyBrick("Brick", height: .auto(estimate: .fixed(size: 100))),
                    DummyBrick("Brick", height: .auto(estimate: .fixed(size: 150))),
                    ]),
                BrickSection("Test Section 3", bricks: [
                    DummyBrick("Brick", height: .auto(estimate: .fixed(size: 100))),
                    ]),
                ]),
            ])

        brickViewController.brickCollectionView.setupSectionAndLayout(section)
        brickViewController.collectionView?.contentOffset = CGPoint(x: 0, y: brickViewController.collectionView!.frame.height)
        brickViewController.collectionView!.layoutSubviews()

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 150 * 3)
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: 150 * 3),
            ],
            2 : [
                CGRect(x: 0, y: 0, width: width, height: 150 * 2),
                CGRect(x: 0, y: 150 * 2, width: width, height: 150)
            ],
            3 : [
                CGRect(x: 0, y: 0, width: width, height: 150),
                CGRect(x: 0, y: 150, width: width, height: 150)
            ],
            4 : [
                CGRect(x: 0, y: 150 * 2, width: width, height: 150)
            ]
        ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: brickViewController.collectionViewLayout.collectionViewContentSize))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 150 * 3))

    }


    func testWithDummyBricksInNestedSections() {
        let section = BrickSection("Test", bricks: [
            BrickSection("Test Section 1", bricks: [
                BrickSection("Test Section 2", bricks: [
                    DummyBrick("Brick 1 in section 2", height: .auto(estimate: .fixed(size: 100))),
                    DummyBrick("Brick 2 in section 2", height: .auto(estimate: .fixed(size: 100)))
                    ]),
                BrickSection("Test Section 3", bricks: [
                    DummyBrick("Brick 1 in section 3", height: .auto(estimate: .fixed(size: 100))),
                    DummyBrick("Brick 2 in section 3", height: .auto(estimate: .fixed(size: 100))),
                    DummyBrick("Brick 3 in section 3", height: .auto(estimate: .fixed(size: 100)))
                    ]),
                ]),
            ])

        brickViewController.brickCollectionView.setupSectionAndLayout(section)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: width * 10)
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: width * 10)
            ],
            2 : [
                CGRect(x: 0, y: 0, width: width, height: width * 4),
                CGRect(x: 0, y: width * 4, width: width, height: width * 6)
            ],
            3 : [
                CGRect(x: 0, y: 0, width: width, height: width * 2),
                CGRect(x: 0, y: width * 2, width: width, height: width * 2)
            ],
            4 : [
                CGRect(x: 0, y: width * 4, width: width, height: width * 2),
                CGRect(x: 0, y: width * 6, width: width, height: width * 2),
                CGRect(x: 0, y: width * 8, width: width, height: width * 2)
            ]
        ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: brickViewController.collectionViewLayout.collectionViewContentSize))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: width * 10))

    }

    func testClassIdentifiersOnMultipleLabelBricks() {
        let height:CGFloat = brickViewController.brickCollectionView.frame.height
        let section = BrickSection("Test", bricks: [
            LabelBrick("Brick1", height: .fixed(size: height), dataSource: LabelBrickCellModel(text: "Brick 1")),
            LabelBrick("Brick2", height: .fixed(size: height), dataSource: LabelBrickCellModel(text: "Brick 2")),
            LabelBrick("Brick3", height: .fixed(size: height), dataSource: LabelBrickCellModel(text: "Brick 3")),
            LabelBrick("Brick4", height: .fixed(size: height), dataSource: LabelBrickCellModel(text: "Brick 4")),
            LabelBrick("Brick5", height: .fixed(size: height), dataSource: LabelBrickCellModel(text: "Brick 5")),
            LabelBrick("Brick6", height: .fixed(size: height), dataSource: LabelBrickCellModel(text: "Brick 6", configureCellBlock: {
                (cell: LabelBrickCell) -> Void in
                cell.accessoryView = UIImageView(image: UIImage(named: "image0"))
            })),
            LabelBrick("Brick7", height: .fixed(size: height), dataSource: LabelBrickCellModel(text: "Brick 5")),
            LabelBrick("Brick8", height: .fixed(size: height), dataSource: LabelBrickCellModel(text: "Brick 5")),
            LabelBrick("Brick9", height: .fixed(size: height), dataSource: LabelBrickCellModel(text: "Brick 5")),
            LabelBrick("Brick10", height: .fixed(size: height), dataSource: LabelBrickCellModel(text: "Brick 5")),
            LabelBrick("Brick11", height: .fixed(size: height), dataSource: LabelBrickCellModel(text: "Brick 5"))
        ])

        brickViewController.brickCollectionView.setupSectionAndLayout(section)

        if let indexPath6 = brickViewController.brickCollectionView.indexPathsForBricksWithIdentifier("Brick6").first {

            brickViewController.brickCollectionView.contentOffset.y += height * 5
            brickViewController.brickCollectionView.layoutSubviews()

            guard let labelBrick6 = brickViewController.brickCollectionView.cellForItem(at: indexPath6) as? LabelBrickCell else {
                XCTFail("LabelBrickCell should not be nil")
                return
            }

            XCTAssertNotNil(labelBrick6.accessoryView)

            brickViewController.brickCollectionView.contentOffset.y += height * 4
            brickViewController.brickCollectionView.layoutSubviews()

            brickViewController.brickCollectionView.contentOffset.y -= height * 9
            brickViewController.brickCollectionView.layoutSubviews()

            for cell in brickViewController.brickCollectionView.visibleCells where brickViewController.brickCollectionView.cellForItem(at: indexPath6) == nil {
                if let cell = cell as? LabelBrickCell {
                    XCTAssertNil(cell.accessoryView)
                }
            }
        }
    }

    func testInsets() {
        let size = CGSize(width: 100, height: 100)
        brickViewController.view.frame = CGRect(origin: CGPoint.zero, size: size)

        let section = BrickSection("Test Section", bricks: [
            DummyBrick("Brick 1"),
            BrickSection("Test Section 2", bricks: [
                DummyBrick("Brick 2"),
                ], inset: 20, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
            ], inset: 10, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))

        brickViewController.brickCollectionView.setupSectionAndLayout(section)

        XCTAssertEqual(brickViewController.brickCollectionView.brickLayout(brickViewController.layout, insetFor: 1), 10)
        XCTAssertEqual(brickViewController.brickCollectionView.brickLayout(brickViewController.layout, edgeInsetsFor: 1), UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        XCTAssertEqual(brickViewController.brickCollectionView.brickLayout(brickViewController.layout, insetFor: 2), 20)
        XCTAssertEqual(brickViewController.brickCollectionView.brickLayout(brickViewController.layout, edgeInsetsFor: 2), UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))


    }

    func testWithDummyBricksWithDifferentNibs() {
        let section = BrickSection("Test Section", bricks: [
            DummyBrick("Brick 1"),
            DummyBrick("Brick 2")
            ])

        brickViewController.registerNib(UINib(nibName: "DummyBrick100", bundle: Bundle(for: DummyBrick.self)), forBrickWithIdentifier: "Brick 1")
        brickViewController.registerNib(UINib(nibName: "DummyBrick150", bundle: Bundle(for: DummyBrick.self)), forBrickWithIdentifier: "Brick 2")

        brickViewController.brickCollectionView.setupSectionAndLayout(section)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 250),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: 100),
                CGRect(x: 0, y: 100, width: width, height: 150)
            ]
        ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: 250)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 250))

    }

    func testWithDummyBricksWithDifferentNibCombinations() {
        let section = BrickSection("Test Section", bricks: [
            DummyBrick("Brick 1"),
            DummyBrick("Brick 2")
            ])

        brickViewController.registerNib(UINib(nibName: "DummyBrick150", bundle: Bundle(for: DummyBrick.self)), forBrickWithIdentifier: "Brick 2")

        brickViewController.brickCollectionView.setupSectionAndLayout(section)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: width * 2 + 150),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: width * 2),
                CGRect(x: 0, y: width * 2, width: width, height: 150)
            ]
        ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 3.5)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: width * 2 + 150))

    }

    func testAlignHeights() {
        let section = BrickSection("Test Section", bricks: [
            DummyBrick("Brick 1"),
            ])

        brickViewController.brickCollectionView.setupSectionAndLayout(section)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: width * 2),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: width * 2),
            ]
        ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: width * 2))
    }


    func testCollectionBrick() {
        let collectionSection = BrickSection("CollectionBrick Section", bricks: [
            DummyBrick("Brick 1", height: .fixed(size: 50)),
            ])

        let section = BrickSection("Test Section", bricks: [
            CollectionBrick("Collection Brick", scrollDirection: .horizontal, dataSource: CollectionBrickCellModel(section: collectionSection, configureHandler: { (cell) in
                cell.brickCollectionView.registerBrickClass(DummyBrick.self)
            }))
            ])

        brickViewController.brickCollectionView.setupSectionAndLayout(section)

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 50),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: 50),
            ]
        ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 50))

    }

    func testCollectionBrickWithNoContentFirst() {
        let collectionSection = BrickSection("CollectionBrick Section", bricks: [
            DummyBrick("Brick 1", height: .fixed(size: 50)),
            ])
        let model = CollectionBrickCellModel(section: collectionSection, configureHandler: { (cell) in
            cell.brickCollectionView.registerBrickClass(DummyBrick.self)
        })
        let repeatCount = FixedRepeatCountDataSource(repeatCountHash: ["Brick 1": 0])
        collectionSection.repeatCountDataSource = repeatCount
        model.section = collectionSection

        let section = BrickSection("Test Section", bricks: [
            CollectionBrick("Collection Brick", scrollDirection: .horizontal, dataSource: model)
            ])

        brickViewController.brickCollectionView.setupSectionAndLayout(section)

        var expectedResult: [Int: [CGRect]] = [ : ]

        var attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))


        repeatCount.repeatCountHash = ["Brick 1": 1]
        model.section = collectionSection
        brickViewController.reloadBricksWithIdentifiers(["Collection Brick"], shouldReloadCell: true)

        expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: width, height: 50),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: width, height: 50),
            ]
        ]

        attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: width * 2)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: width, height: 50))
    }

    func testChangingRepeatCountWhileInvalidatingAndReloading() {
        let sectionIdentifier = "repeated brick section"
        let brick = GenericBrick<UIView>("", width: .ratio(ratio: 1.0), height: .fixed(size: 50.0)) { (_, _) in }
        let sectionWithMultipleBricks = BrickSection(sectionIdentifier, bricks: [brick])
        let repeatCountDelegate = RepeatCountDelegate(startingCount: 0, increment: 1)
        sectionWithMultipleBricks.repeatCountDataSource = repeatCountDelegate
        brickViewController.brickCollectionView.setupSectionAndLayout(BrickSection("", bricks: [sectionWithMultipleBricks]))
        
        // Repeat counts incrementing by 1
        brickViewController.reloadBricksWithIdentifiers([sectionWithMultipleBricks.identifier], shouldReloadCell: false)
        brickViewController.brickCollectionView.invalidateRepeatCounts()
        
        brickViewController.reloadBricksWithIdentifiers([sectionWithMultipleBricks.identifier], shouldReloadCell: true)
        brickViewController.brickCollectionView.invalidateRepeatCounts()

        XCTAssertEqual(brickViewController.collectionView!.numberOfItems(inSection: 2), 2)
        XCTAssertEqual(brickViewController.brickCollectionView.numberOfItems(inSection: 2), 2)

        // Repeat counts decrementing by 1
        repeatCountDelegate.repeatCount = 10
        repeatCountDelegate.increment = -1
        
        brickViewController.reloadBricksWithIdentifiers([sectionWithMultipleBricks.identifier], shouldReloadCell: false)
        brickViewController.brickCollectionView.invalidateRepeatCounts()
        
        brickViewController.reloadBricksWithIdentifiers([sectionWithMultipleBricks.identifier], shouldReloadCell: true)
        brickViewController.brickCollectionView.invalidateRepeatCounts()
        
        XCTAssertEqual(brickViewController.collectionView!.numberOfItems(inSection: 2), 9)
        XCTAssertEqual(brickViewController.brickCollectionView.numberOfItems(inSection: 2), 9)
        
        // Repeat counts incrementing by 5
        XCTAssertNotNil(brickViewController)
        
        repeatCountDelegate.repeatCount = 100
        repeatCountDelegate.increment = 5
        
        brickViewController.reloadBricksWithIdentifiers([sectionWithMultipleBricks.identifier], shouldReloadCell: false)
        brickViewController.brickCollectionView.invalidateRepeatCounts()
        
        brickViewController.reloadBricksWithIdentifiers([sectionWithMultipleBricks.identifier], shouldReloadCell: true)
        brickViewController.brickCollectionView.invalidateRepeatCounts()
        
        XCTAssertEqual(brickViewController.collectionView!.numberOfItems(inSection: 2), 105)
        XCTAssertEqual(brickViewController.brickCollectionView.numberOfItems(inSection: 2), 105)

        // Repeat counts decrementing by 5
        XCTAssertNotNil(brickViewController)
        
        repeatCountDelegate.repeatCount = 100
        repeatCountDelegate.increment = -5
        
        brickViewController.reloadBricksWithIdentifiers([sectionWithMultipleBricks.identifier], shouldReloadCell: false)
        brickViewController.brickCollectionView.invalidateRepeatCounts()
        
        brickViewController.reloadBricksWithIdentifiers([sectionWithMultipleBricks.identifier], shouldReloadCell: true)
        brickViewController.brickCollectionView.invalidateRepeatCounts()
        
        // If the test method makes it this far, then it didn't crash for NSInternalConsistencyException, which is the main issue this method is testing for.
        XCTAssertNotNil(brickViewController)
        XCTAssertEqual(brickViewController.collectionView!.numberOfSections, 3)
        XCTAssertEqual(brickViewController.collectionView!.numberOfItems(inSection: 0), 1)
        XCTAssertEqual(brickViewController.collectionView!.numberOfItems(inSection: 1), 1)
        XCTAssertEqual(brickViewController.collectionView!.numberOfItems(inSection: 2), 95)
        XCTAssertEqual(brickViewController.brickCollectionView.numberOfSections, 3)
        XCTAssertEqual(brickViewController.brickCollectionView.numberOfItems(inSection: 0), 1)
        XCTAssertEqual(brickViewController.brickCollectionView.numberOfItems(inSection: 1), 1)
        XCTAssertEqual(brickViewController.brickCollectionView.numberOfItems(inSection: 2), 95)
    }
    
    func testUpdateFrame() {
        let section = BrickSection("Test Section", bricks: [
            DummyBrick("Brick 1", height: .fixed(size: 50)),
            ])

        brickViewController.brickCollectionView.setupSectionAndLayout(section)
        brickViewController.brickCollectionView.frame.size.width = 400

        let expectedResult = [
            0 : [
                CGRect(x: 0, y: 0, width: 400, height: 50),
            ],
            1 : [
                CGRect(x: 0, y: 0, width: 400, height: 50),
            ]
        ]

        let attributes = brickViewController.collectionViewLayout.layoutAttributesForElements(in: CGRect(origin: CGPoint.zero, size: CGSize(width: 400, height: 50)))
        XCTAssertNotNil(attributes)
        XCTAssertTrue(verifyAttributesToExpectedResult(attributes!, expectedResult: expectedResult))
        XCTAssertEqual(brickViewController.collectionViewLayout.collectionViewContentSize, CGSize(width: 400, height: 50))
    }

    // MARK: iOS-only tests
    #if os(iOS)
    // MARK: Refresh Control
    // These tests aren't applicable to tvOS because tvOS doesn't have UIRefreshControl
    func testRefreshControl() {
        let refreshControl = UIRefreshControl()

        let expectation = self.expectation(description: "Refresh")
        brickViewController.addRefreshControl(refreshControl) { (refreshControl) in
            expectation.fulfill()
        }

        // Workaround to start refreshing. I haven't found a way to do this programmatically
        // I had hoped that `refreshControl.beginRefreshing()` or  `refreshControl.sendActionsForControlEvents(.ValueChanged)` would do the trick...
        brickViewController.refreshControlAction()

        waitForExpectations(timeout: 2, handler: nil)

        XCTAssertNotNil(brickViewController.refreshControl)
        XCTAssertNotNil(brickViewController.refreshAction)
        XCTAssertEqual(refreshControl.allTargets.count, 1)
        XCTAssertEqual(refreshControl.allTargets.first, brickViewController)
        XCTAssertEqual(refreshControl.superview, brickViewController.brickCollectionView)
    }

    func testResetRefreshControl() {
        let refreshControl = UIRefreshControl()
        brickViewController.addRefreshControl(refreshControl) { (refreshControl) in
        }
        refreshControl.beginRefreshing()
        brickViewController.resetRefreshControl()

        XCTAssertEqual(refreshControl.layer.zPosition, 1)
    }

    func testResetRefreshControlWithBackgroundView() {
        let view = UIView()
        brickViewController.brickCollectionView.backgroundView = view
        view.layer.zPosition = 1

        let refreshControl = UIRefreshControl()
        brickViewController.addRefreshControl(refreshControl) { (refreshControl) in
        }
        refreshControl.beginRefreshing()
        brickViewController.resetRefreshControl()

        XCTAssertEqual(refreshControl.layer.zPosition, 2)
    }
    
    // MARK: 3D Touch
    
    // These tests aren't applicable to tvOS because while UIViewControllerPreviewingDelegate are available on tvOS,
    // registering for 3D Touch returns a nil UIViewControllerPreviewing object and you cannot actually receive events. 
    // Despite this, you can safely use the API on tvOS as you do on iOS without causing any issues.
    func testTraitChangeAltersForceTouchRegistration() {
        var mockCurrentTraits = UITraitCollection(forceTouchCapability: .available)
        var mockPreviousTraits = UITraitCollection(forceTouchCapability: .unavailable)
        brickViewController.handleTraitCollectionChange(mockCurrentTraits, mockPreviousTraits)
        XCTAssertNotNil(brickViewController.previewingContext)
        
        mockCurrentTraits = UITraitCollection(forceTouchCapability: .unavailable)
        mockPreviousTraits = UITraitCollection(forceTouchCapability: .available)
        brickViewController.handleTraitCollectionChange(mockCurrentTraits, mockPreviousTraits)
        XCTAssertNil(brickViewController.previewingContext)
    }
    
    func testForceTouchPeek() {
        brickViewController.brickCollectionView.frame.size.width = 320
        let brick = DummyBrick("Brick 1", width: .ratio(ratio: 1), height: .ratio(ratio: 0.5))
        let delegate = MockPreviewingDelegate()
        brick.previewingDelegate = delegate
        brickViewController.brickCollectionView.setupSingleBrickAndLayout(brick)
        
        let mockCurrentTraits = UITraitCollection(forceTouchCapability: .available)
        let mockPreviousTraits = UITraitCollection(forceTouchCapability: .unavailable)
        brickViewController.handleTraitCollectionChange(mockCurrentTraits, mockPreviousTraits)
        
        let badResult = brickViewController.previewingContext(brickViewController.previewingContext!, viewControllerForLocation: CGPoint(x: 320, y: 320))
        XCTAssertNil(badResult)
        
        let goodResult = brickViewController.previewingContext(brickViewController.previewingContext!, viewControllerForLocation: CGPoint(x: 160, y: 50)) as? PreviewViewController
        
        XCTAssertNotNil(goodResult)
        XCTAssertNotNil(goodResult?.sourceBrick)
    }
    
    func testForceTouchPop() {
        brickViewController.brickCollectionView.frame.size.width = 320
        let brick = DummyBrick("Brick 1", width: .ratio(ratio: 1), height: .ratio(ratio: 0.5))
        let delegate = MockPreviewingDelegate()
        brick.previewingDelegate = delegate
        brickViewController.brickCollectionView.setupSingleBrickAndLayout(brick)
        
        let mockCurrentTraits = UITraitCollection(forceTouchCapability: .available)
        let mockPreviousTraits = UITraitCollection(forceTouchCapability: .unavailable)
        brickViewController.handleTraitCollectionChange(mockCurrentTraits, mockPreviousTraits)
        
        guard let result = brickViewController.previewingContext(brickViewController.previewingContext!, viewControllerForLocation: CGPoint(x: 160, y: 50)) else {
            XCTFail()
            return
        }
        brickViewController.previewingContext(brickViewController.previewingContext!, commit: result)
        
        XCTAssertTrue(delegate.successfulPop)
    }
    #endif
    
    func testReloadBricks() {
        let width = brickViewController.brickCollectionView.frame.size.width

        let brick = DummyBrick(width: .ratio(ratio: 1/10))
        let section = BrickSection(bricks: [
            brick
            ])
        brickViewController.brickCollectionView.setupSectionAndLayout(section)

        var cell: DummyBrickCell?
        cell = brickViewController.brickCollectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? DummyBrickCell
        XCTAssertEqual(cell!.frame.width, width / 10, accuracy: 0.01)
        XCTAssertEqual(cell?.frame.height ?? 0, (width / 10) * 2, accuracy: 0.5)

        brick.size.width = .ratio(ratio: 1/5)

        let expectation = self.expectation(description: "Invalidate Bricks")

        brickViewController.brickCollectionView.invalidateBricks(true) { completed in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        cell = brickViewController.brickCollectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? DummyBrickCell
        XCTAssertEqual(cell?.frame.width ?? 0, width / 5, accuracy: 0.1)
        XCTAssertEqual(cell?.frame.height ?? 0 , (width / 5) * 2, accuracy: 0.1)
    }

    // MARK: tvOS-only tests
    #if os(tvOS)
    func testCanFocus() {
        brickViewController.brickCollectionView.registerBrickClass(DummyFocusableBrick.self)
        
        let section = BrickSection("Test Section", bricks: [
            DummyFocusableBrick("Brick 1", height: .fixed(size: 50)),
            ])
        
        
        brickViewController.setSection(section)
        brickViewController.collectionView!.layoutSubviews()
        brickViewController.brickCollectionView.frame.size.width = 400


        let brickOneIndex = brickViewController.brickCollectionView.indexPathsForBricksWithIdentifier("Brick 1").first
        
        XCTAssertNotNil(brickOneIndex)
        
        XCTAssertTrue(brickViewController.collectionView(collectionView: brickViewController.brickCollectionView, canFocusItemAtIndexPath: brickOneIndex!))
    }
    
    func testFocus() {
        brickViewController.brickCollectionView.registerBrickClass(DummyFocusableBrick.self)
        
        let section = BrickSection("Test Section", bricks: [
            DummyFocusableBrick("Brick 1", height: .fixed(size: 50)),
            DummyFocusableBrick("Brick 2", height: .fixed(size: 50))
            ])
        
        
        brickViewController.brickCollectionView.setupSectionAndLayout(section)
        brickViewController.brickCollectionView.frame.size.width = 400
        
        let brickOneIndex = brickViewController.brickCollectionView.indexPathsForBricksWithIdentifier("Brick 1").first
        let brickTwoIndex = brickViewController.brickCollectionView.indexPathsForBricksWithIdentifier("Brick 2").first
        
        XCTAssertNotNil(brickOneIndex)
        XCTAssertNotNil(brickTwoIndex)
        
        let context = MockCollectionViewFocusUpdateContext()
        context.nextFocusedIndexPath = brickOneIndex!
        
        _ = brickViewController.collectionViewShouldUpdateFocusIn(context: context)
        
        let cell = brickViewController.brickCollectionView.cellForItem(at: brickOneIndex!) as? DummyFocusableBrickCell
        
        XCTAssertTrue(cell!.isCurrentlyFocused)
    }
    
    func testUnfocus() {
        brickViewController.brickCollectionView.registerBrickClass(DummyFocusableBrick.self)
        
        let section = BrickSection("Test Section", bricks: [
            DummyFocusableBrick("Brick 1", height: .fixed(size: 50)),
            DummyFocusableBrick("Brick 2", height: .fixed(size: 50))
            ])
        
        
        brickViewController.brickCollectionView.setupSectionAndLayout(section)
        brickViewController.brickCollectionView.frame.size.width = 400
        
        
        let brickOneIndex = brickViewController.brickCollectionView.indexPathsForBricksWithIdentifier("Brick 1").first
        let brickTwoIndex = brickViewController.brickCollectionView.indexPathsForBricksWithIdentifier("Brick 2").first
        
        XCTAssertNotNil(brickOneIndex)
        XCTAssertNotNil(brickTwoIndex)
        
        let context = MockCollectionViewFocusUpdateContext()
        context.nextFocusedIndexPath = brickOneIndex!
        
        _ = brickViewController.collectionViewShouldUpdateFocusIn(context: context)
        
        let cell1 = brickViewController.brickCollectionView.cellForItem(at: brickOneIndex!) as? DummyFocusableBrickCell
        
        XCTAssertTrue(cell1!.isCurrentlyFocused)
        
        context.previouslyFocusedIndexPath = brickOneIndex!
        context.nextFocusedIndexPath = brickTwoIndex!
        
        _ = brickViewController.collectionViewShouldUpdateFocusIn(context: context)
        
        let cell2 = brickViewController.brickCollectionView.cellForItem(at: brickTwoIndex!) as? DummyFocusableBrickCell
        
        XCTAssertFalse(cell1!.isCurrentlyFocused)
        XCTAssertTrue(cell2!.isCurrentlyFocused)
    }
    
    func testKeepFocus() {
        brickViewController.brickCollectionView.registerBrickClass(DummyFocusableBrick.self)

        let section = BrickSection("Test Section", bricks: [
            DummyFocusableBrick("Brick 1", height: .fixed(size: 50)),
            DummyFocusableBrick("Brick 2", height: .fixed(size: 50)),
            DummyBrick("Brick 3", height: .fixed(size: 50))
            ])
        
        
        brickViewController.brickCollectionView.setupSectionAndLayout(section)
        brickViewController.brickCollectionView.frame.size.width = 400
        
        let brickOneIndex = brickViewController.brickCollectionView.indexPathsForBricksWithIdentifier("Brick 1").first
        let brickTwoIndex = brickViewController.brickCollectionView.indexPathsForBricksWithIdentifier("Brick 2").first
        let brickThreeIndex = brickViewController.brickCollectionView.indexPathsForBricksWithIdentifier("Brick 3").first
        
        XCTAssertNotNil(brickOneIndex)
        XCTAssertNotNil(brickTwoIndex)
        XCTAssertNotNil(brickThreeIndex)
        
        let context = MockCollectionViewFocusUpdateContext()
        context.nextFocusedIndexPath = brickThreeIndex!
        
        XCTAssertFalse(brickViewController.collectionViewShouldUpdateFocusIn(context: context))
        
        let cell1 = brickViewController.brickCollectionView.cellForItem(at: brickOneIndex!) as? DummyFocusableBrickCell
        
        cell1?.shouldLoseFocus = false
        cell1?.isCurrentlyFocused = true
        
        context.previouslyFocusedIndexPath = brickOneIndex!
        context.nextFocusedIndexPath = brickTwoIndex!
        
        _ = brickViewController.collectionViewShouldUpdateFocusIn(context: context)
        
        let cell2 = brickViewController.brickCollectionView.cellForItem(at: brickTwoIndex!) as? DummyFocusableBrickCell
        
        XCTAssertTrue(cell1!.isCurrentlyFocused)
        XCTAssertFalse(cell2!.isCurrentlyFocused)
    }

    #endif
}
