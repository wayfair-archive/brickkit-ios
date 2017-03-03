//
//  BrickDimensionTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/29/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

class BrickDimensionTests: XCTestCase {
    var view: UIView!

    override func setUp() {
        super.setUp()

        view = UIView()
        swizzleScreen()
    }

    override func tearDown() {
        super.tearDown()
        resetScreen()
        StubScreen.reset()
    }

    func testViewPortrait() {
        setScreenPortrait(true)

        XCTAssertNotNil(BrickDimension.horizontalSizeClass)
        XCTAssertNotNil(BrickDimension.verticalSizeClass)
        XCTAssertTrue(BrickDimension.isPortrait)
    }

    func testViewLandscape() {
        setScreenPortrait(false)

        XCTAssertFalse(BrickDimension.isPortrait)
    }

    func testViewSquare() {
        StubScreen.bounds.size = CGSize(width: 320, height: 320)

        XCTAssertTrue(BrickDimension.isPortrait)
    }

    func testFixed() {
        let fixed = BrickDimension.Fixed(size: 50)
        XCTAssertEqual(fixed.value(for: 1000, startingAt: 0), 50)
        XCTAssertEqual(fixed.dimension, fixed)
        XCTAssertFalse(fixed.isEstimate)
        XCTAssertEqual(fixed, BrickDimension.Fixed(size: 50))
        XCTAssertNotEqual(fixed, BrickDimension.Fixed(size: 100))
    }

    func testRatio() {
        let ratio = BrickDimension.Ratio(ratio: 0.5)
        XCTAssertEqual(ratio.value(for: 1000, startingAt: 0), 500)
        XCTAssertEqual(ratio.dimension, ratio)
        XCTAssertFalse(ratio.isEstimate)
        XCTAssertEqual(ratio, BrickDimension.Ratio(ratio: 0.5))
        XCTAssertNotEqual(ratio, BrickDimension.Fixed(size: 100))
    }

    func testFill() {
        let ratio = BrickDimension.Fill
        XCTAssertEqual(ratio.value(for: 1000, startingAt: 0), 1000)
        XCTAssertEqual(ratio.dimension, ratio)
        XCTAssertFalse(ratio.isEstimate)
        XCTAssertEqual(ratio, BrickDimension.Fill)
        XCTAssertNotEqual(ratio, BrickDimension.Fixed(size: 100))
    }

    func testFillWithStartingOrigin() {
        let ratio = BrickDimension.Fill
        XCTAssertEqual(ratio.value(for: 1000, startingAt: 500), 500)
        XCTAssertEqual(ratio.dimension, ratio)
        XCTAssertFalse(ratio.isEstimate)
        XCTAssertEqual(ratio, BrickDimension.Fill)
        XCTAssertNotEqual(ratio, BrickDimension.Fixed(size: 100))
    }

    func testFillWithStartingOriginThatIsTooBig() {
        let ratio = BrickDimension.Fill
        XCTAssertEqual(ratio.value(for: 1000, startingAt: 1001), 1000)
        XCTAssertEqual(ratio.dimension, ratio)
        XCTAssertFalse(ratio.isEstimate)
        XCTAssertEqual(ratio, BrickDimension.Fill)
        XCTAssertNotEqual(ratio, BrickDimension.Fixed(size: 100))
    }

    func testAutoFixed() {
        let autoFixed = BrickDimension.Auto(estimate: BrickDimension.Fixed(size: 50))
        XCTAssertEqual(autoFixed.value(for: 1000, startingAt: 0), 50)
        XCTAssertEqual(autoFixed.dimension, autoFixed)
        XCTAssertTrue(autoFixed.isEstimate)
        XCTAssertEqual(autoFixed, BrickDimension.Auto(estimate: BrickDimension.Fixed(size: 50)))
    }

    func testAutoRatio() {
        let autoRatio = BrickDimension.Auto(estimate: BrickDimension.Ratio(ratio: 0.5))
        XCTAssertEqual(autoRatio.value(for: 1000, startingAt: 0), 500)
        XCTAssertEqual(autoRatio.dimension, autoRatio)
        XCTAssertTrue(autoRatio.isEstimate)
        XCTAssertEqual(autoRatio, BrickDimension.Auto(estimate: BrickDimension.Ratio(ratio: 0.5)))
    }

    func testOrientationPortrait() {
        setupScreen(isPortrait: true, horizontalSizeClass: .Compact, verticalSizeClass: .Compact)
        let orientation = BrickDimension.Orientation(landscape: BrickDimension.Fixed(size: 100), portrait: BrickDimension.Fixed(size: 50))
        XCTAssertEqual(orientation.value(for: 1000, startingAt: 0), 50)
        XCTAssertEqual(orientation.dimension, BrickDimension.Fixed(size: 50))
        XCTAssertEqual(orientation, BrickDimension.Orientation(landscape: BrickDimension.Fixed(size: 100), portrait: BrickDimension.Fixed(size: 50)))
    }

    func testOrientationLandscape() {
        setupScreen(isPortrait: false, horizontalSizeClass: .Compact, verticalSizeClass: .Compact)
        let orientation = BrickDimension.Orientation(landscape: BrickDimension.Fixed(size: 100), portrait: BrickDimension.Fixed(size: 50))
        XCTAssertEqual(orientation.value(for: 1000, startingAt: 0), 100)
        XCTAssertEqual(orientation.dimension, BrickDimension.Fixed(size: 100))
        XCTAssertEqual(orientation, BrickDimension.Orientation(landscape: BrickDimension.Fixed(size: 100), portrait: BrickDimension.Fixed(size: 50)))
    }

    func testHorizontalSizeClassCompact() {
        setupScreen(isPortrait: true, horizontalSizeClass: .Compact, verticalSizeClass: .Regular)
        let sizeClass = BrickDimension.HorizontalSizeClass(regular: BrickDimension.Fixed(size: 100), compact: BrickDimension.Fixed(size: 50))
        XCTAssertEqual(sizeClass.value(for: 1000, startingAt: 0), 50)
        XCTAssertEqual(sizeClass.dimension, BrickDimension.Fixed(size: 50))
        XCTAssertEqual(sizeClass, BrickDimension.HorizontalSizeClass(regular: BrickDimension.Fixed(size: 100), compact: BrickDimension.Fixed(size: 50)))

    }

    func testHorizontalSizeClassRegular() {
        setupScreen(isPortrait: true, horizontalSizeClass: .Regular, verticalSizeClass: .Compact)
        let sizeClass = BrickDimension.HorizontalSizeClass(regular: BrickDimension.Fixed(size: 100), compact: BrickDimension.Fixed(size: 50))
        XCTAssertEqual(sizeClass.value(for: 1000, startingAt: 0), 100)
        XCTAssertEqual(sizeClass.dimension, BrickDimension.Fixed(size: 100))
        XCTAssertEqual(sizeClass, BrickDimension.HorizontalSizeClass(regular: BrickDimension.Fixed(size: 100), compact: BrickDimension.Fixed(size: 50)))
    }

    func testVerticalSizeClassCompact() {
        setupScreen(isPortrait: true, horizontalSizeClass: .Regular, verticalSizeClass: .Compact)
        let sizeClass = BrickDimension.VerticalSizeClass(regular: BrickDimension.Fixed(size: 100), compact: BrickDimension.Fixed(size: 50))
        XCTAssertEqual(sizeClass.value(for: 1000, startingAt: 0), 50)
        XCTAssertEqual(sizeClass.dimension, BrickDimension.Fixed(size: 50))
        XCTAssertEqual(sizeClass, BrickDimension.VerticalSizeClass(regular: BrickDimension.Fixed(size: 100), compact: BrickDimension.Fixed(size: 50)))
    }

    func testVerticalSizeClassRegular() {
        setupScreen(isPortrait: true, horizontalSizeClass: .Compact, verticalSizeClass: .Regular)
        let sizeClass = BrickDimension.VerticalSizeClass(regular: BrickDimension.Fixed(size: 100), compact: BrickDimension.Fixed(size: 50))
        XCTAssertEqual(sizeClass.value(for: 1000, startingAt: 0), 100)
        XCTAssertEqual(sizeClass.dimension, BrickDimension.Fixed(size: 100))
        XCTAssertEqual(sizeClass, BrickDimension.VerticalSizeClass(regular: BrickDimension.Fixed(size: 100), compact: BrickDimension.Fixed(size: 50)))
    }

    func testNestedPortraitCompact() {
        setupScreen(isPortrait: true, horizontalSizeClass: .Compact, verticalSizeClass: .Regular)

        let nested = BrickDimension.Orientation(
            landscape: .Fixed(size: 50),
            portrait: .HorizontalSizeClass(
                regular: .Auto(estimate: .Fixed(size: 100)),
                compact: .Auto(estimate: .Fixed(size: 50))
            ))
        XCTAssertEqual(nested.value(for: 1000, startingAt: 0), 50)
        XCTAssertEqual(nested.dimension, BrickDimension.Auto(estimate: BrickDimension.Fixed(size: 50)))
        XCTAssertTrue(nested.isEstimate)
        XCTAssertEqual(nested, BrickDimension.Orientation(
            landscape: .Fixed(size: 50),
            portrait: .HorizontalSizeClass(
                regular: .Auto(estimate: .Fixed(size: 100)),
                compact: .Auto(estimate: .Fixed(size: 50))
            )))
    }

    func testRawValue() {
        expectFatalError { 
            let auto = BrickDimension.Auto(estimate: .Fixed(size: 30))
            BrickDimension._rawValue(for: 100, startingAt: 0, with: auto)
        }
    }

}

// MARK: - Utility methods to `fake` UIScreen.mainScreen
extension BrickDimensionTests {

    /// Setup UIScreen.mainScreen to call a different method
    func swizzleScreen() {
        NSObject.swizzleStaticMethodSelector(#selector(UIScreen.mainScreen), withSelector: #selector(UIScreen.stubMainScreen), forClass: UIScreen.self)
    }

    /// Reset UIScreen.mainScreen to call a different method
    func resetScreen() {
        NSObject.swizzleStaticMethodSelector(#selector(UIScreen.stubMainScreen), withSelector: #selector(UIScreen.mainScreen), forClass: UIScreen.self)
    }

    /// Setup the UIScreen for the given test
    func setupScreen(isPortrait isPortrait: Bool, horizontalSizeClass: UIUserInterfaceSizeClass, verticalSizeClass: UIUserInterfaceSizeClass) {
        StubScreen.horizontalSizeClass = horizontalSizeClass
        StubScreen.verticalSizeClass = verticalSizeClass
        setScreenPortrait(isPortrait)
    }

    func setScreenPortrait(isPortrait: Bool) {
        StubScreen.bounds.size = isPortrait ? CGSize(width: 320, height: 480) : CGSize(width: 480, height: 320)
    }

}


// Mark: - Screen

extension UIScreen {
    @objc class func stubMainScreen() -> UIScreen {
        return StubScreen()
    }
}

class StubScreen: UIScreen {
    static let DefaultHorizontalSizeClass: UIUserInterfaceSizeClass = .Unspecified
    static let DefaultVerticalSizeClass: UIUserInterfaceSizeClass = .Unspecified
    static let ScreenDefaultBounds = CGRect(x: 0, y: 0, width: 320, height: 480)

    static var horizontalSizeClass: UIUserInterfaceSizeClass = StubScreen.DefaultHorizontalSizeClass
    static var verticalSizeClass: UIUserInterfaceSizeClass = StubScreen.DefaultVerticalSizeClass
    static var bounds: CGRect = StubScreen.ScreenDefaultBounds

    static func reset() {
        StubScreen.horizontalSizeClass = StubScreen.DefaultHorizontalSizeClass
        StubScreen.verticalSizeClass = StubScreen.DefaultVerticalSizeClass
        StubScreen.bounds = StubScreen.ScreenDefaultBounds
    }

    override var traitCollection: UITraitCollection {
        return StubTraitCollection()
    }

    override var bounds: CGRect {
        return StubScreen.bounds
    }
    
}

class StubTraitCollection: UITraitCollection {
    override var horizontalSizeClass: UIUserInterfaceSizeClass {
        return StubScreen.horizontalSizeClass
    }
    override var verticalSizeClass: UIUserInterfaceSizeClass {
        return StubScreen.verticalSizeClass
    }
}

