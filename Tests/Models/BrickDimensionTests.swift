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

        XCTAssertNotNil(view.horizontalSizeClass)
        XCTAssertNotNil(view.verticalSizeClass)
        XCTAssertTrue(view.isPortrait)
    }

    func testViewLandscape() {
        setScreenPortrait(false)

        XCTAssertFalse(view.isPortrait)
    }

    func testViewSquare() {
        StubScreen.bounds.size = CGSize(width: 320, height: 320)

        XCTAssertTrue(view.isPortrait)
    }

    func testFixed() {
        let fixed = BrickDimension.fixed(size: 50)
        XCTAssertEqual(fixed.value(for: 1000, startingAt: 0, in: UIView()), 50)
        XCTAssertEqual(fixed.dimension(in: UIView()), fixed)
        XCTAssertFalse(fixed.isEstimate(in: UIView()))
        XCTAssertEqual(fixed, BrickDimension.fixed(size: 50))
        XCTAssertNotEqual(fixed, BrickDimension.fixed(size: 100))
    }

    func testRatio() {
        let ratio = BrickDimension.ratio(ratio: 0.5)
        XCTAssertEqual(ratio.value(for: 1000, startingAt: 0, in: UIView()), 500)
        XCTAssertEqual(ratio.dimension(in: UIView()), ratio)
        XCTAssertFalse(ratio.isEstimate(in: UIView()))
        XCTAssertEqual(ratio, BrickDimension.ratio(ratio: 0.5))
        XCTAssertNotEqual(ratio, BrickDimension.fixed(size: 100))
    }

    func testFill() {
        let ratio = BrickDimension.fill
        XCTAssertEqual(ratio.value(for: 1000, startingAt: 0, in: UIView()), 1000)
        XCTAssertEqual(ratio.dimension(in: UIView()), ratio)
        XCTAssertFalse(ratio.isEstimate(in: UIView()))
        XCTAssertEqual(ratio, BrickDimension.fill)
        XCTAssertNotEqual(ratio, BrickDimension.fixed(size: 100))
    }

    func testFillWithStartingOrigin() {
        let ratio = BrickDimension.fill
        XCTAssertEqual(ratio.value(for: 1000, startingAt: 500, in: UIView()), 500)
        XCTAssertEqual(ratio.dimension(in: UIView()), ratio)
        XCTAssertFalse(ratio.isEstimate(in: UIView()))
        XCTAssertEqual(ratio, BrickDimension.fill)
        XCTAssertNotEqual(ratio, BrickDimension.fixed(size: 100))
    }

    func testFillWithStartingOriginThatIsTooBig() {
        let ratio = BrickDimension.fill
        XCTAssertEqual(ratio.value(for: 1000, startingAt: 1001, in: UIView()), 1000)
        XCTAssertEqual(ratio.dimension(in: UIView()), ratio)
        XCTAssertFalse(ratio.isEstimate(in: UIView()))
        XCTAssertEqual(ratio, BrickDimension.fill)
        XCTAssertNotEqual(ratio, BrickDimension.fixed(size: 100))
    }

    func testAutoFixed() {
        let autoFixed = BrickDimension.auto(estimate: BrickDimension.fixed(size: 50))
        XCTAssertEqual(autoFixed.value(for: 1000, startingAt: 0, in: UIView()), 50)
        XCTAssertEqual(autoFixed.dimension(in: UIView()), autoFixed)
        XCTAssertTrue(autoFixed.isEstimate(in: UIView()))
        XCTAssertEqual(autoFixed, BrickDimension.auto(estimate: BrickDimension.fixed(size: 50)))
    }

    func testAutoRatio() {
        let autoRatio = BrickDimension.auto(estimate: BrickDimension.ratio(ratio: 0.5))
        XCTAssertEqual(autoRatio.value(for: 1000, startingAt: 0, in: UIView()), 500)
        XCTAssertEqual(autoRatio.dimension(in: UIView()), autoRatio)
        XCTAssertTrue(autoRatio.isEstimate(in: UIView()))
        XCTAssertEqual(autoRatio, BrickDimension.auto(estimate: BrickDimension.ratio(ratio: 0.5)))
    }

    func testOrientationPortrait() {
        setupScreen(isPortrait: true, horizontalSizeClass: .compact, verticalSizeClass: .compact)
        let orientation = BrickDimension.orientation(landscape: BrickDimension.fixed(size: 100), portrait: BrickDimension.fixed(size: 50))
        XCTAssertEqual(orientation.value(for: 1000, startingAt: 0, in: view), 50)
        XCTAssertEqual(orientation.dimension(in: view), BrickDimension.fixed(size: 50))
        XCTAssertEqual(orientation, BrickDimension.orientation(landscape: BrickDimension.fixed(size: 100), portrait: BrickDimension.fixed(size: 50)))
    }

    func testOrientationLandscape() {
        setupScreen(isPortrait: false, horizontalSizeClass: .compact, verticalSizeClass: .compact)
        let orientation = BrickDimension.orientation(landscape: BrickDimension.fixed(size: 100), portrait: BrickDimension.fixed(size: 50))
        XCTAssertEqual(orientation.value(for: 1000, startingAt: 0, in: view), 100)
        XCTAssertEqual(orientation.dimension(in: view), BrickDimension.fixed(size: 100))
        XCTAssertEqual(orientation, BrickDimension.orientation(landscape: BrickDimension.fixed(size: 100), portrait: BrickDimension.fixed(size: 50)))
    }

    func testHorizontalSizeClassCompact() {
        setupScreen(isPortrait: true, horizontalSizeClass: .compact, verticalSizeClass: .regular)
        let sizeClass = BrickDimension.horizontalSizeClass(regular: BrickDimension.fixed(size: 100), compact: BrickDimension.fixed(size: 50))
        XCTAssertEqual(sizeClass.value(for: 1000, startingAt: 0, in: view), 50)
        XCTAssertEqual(sizeClass.dimension(in: view), BrickDimension.fixed(size: 50))
        XCTAssertEqual(sizeClass, BrickDimension.horizontalSizeClass(regular: BrickDimension.fixed(size: 100), compact: BrickDimension.fixed(size: 50)))

    }

    func testHorizontalSizeClassRegular() {
        setupScreen(isPortrait: true, horizontalSizeClass: .regular, verticalSizeClass: .compact)
        let sizeClass = BrickDimension.horizontalSizeClass(regular: BrickDimension.fixed(size: 100), compact: BrickDimension.fixed(size: 50))
        XCTAssertEqual(sizeClass.value(for: 1000, startingAt: 0, in: view), 100)
        XCTAssertEqual(sizeClass.dimension(in: view), BrickDimension.fixed(size: 100))
        XCTAssertEqual(sizeClass, BrickDimension.horizontalSizeClass(regular: BrickDimension.fixed(size: 100), compact: BrickDimension.fixed(size: 50)))
    }

    func testVerticalSizeClassCompact() {
        setupScreen(isPortrait: true, horizontalSizeClass: .regular, verticalSizeClass: .compact)
        let sizeClass = BrickDimension.verticalSizeClass(regular: BrickDimension.fixed(size: 100), compact: BrickDimension.fixed(size: 50))
        XCTAssertEqual(sizeClass.value(for: 1000, startingAt: 0, in: view), 50)
        XCTAssertEqual(sizeClass.dimension(in: view), BrickDimension.fixed(size: 50))
        XCTAssertEqual(sizeClass, BrickDimension.verticalSizeClass(regular: BrickDimension.fixed(size: 100), compact: BrickDimension.fixed(size: 50)))
    }

    func testVerticalSizeClassRegular() {
        setupScreen(isPortrait: true, horizontalSizeClass: .compact, verticalSizeClass: .regular)
        let sizeClass = BrickDimension.verticalSizeClass(regular: BrickDimension.fixed(size: 100), compact: BrickDimension.fixed(size: 50))
        XCTAssertEqual(sizeClass.value(for: 1000, startingAt: 0, in: view), 100)
        XCTAssertEqual(sizeClass.dimension(in: view), BrickDimension.fixed(size: 100))
        XCTAssertEqual(sizeClass, BrickDimension.verticalSizeClass(regular: BrickDimension.fixed(size: 100), compact: BrickDimension.fixed(size: 50)))
    }

    func testNestedPortraitCompact() {
        setupScreen(isPortrait: true, horizontalSizeClass: .compact, verticalSizeClass: .regular)

        let nested = BrickDimension.orientation(
            landscape: .fixed(size: 50),
            portrait: .horizontalSizeClass(
                regular: .auto(estimate: .fixed(size: 100)),
                compact: .auto(estimate: .fixed(size: 50))
            ))
        XCTAssertEqual(nested.value(for: 1000, startingAt: 0, in: view), 50)
        XCTAssertEqual(nested.dimension(in: view), BrickDimension.auto(estimate: BrickDimension.fixed(size: 50)))
        XCTAssertTrue(nested.isEstimate(in: view))
        XCTAssertEqual(nested, BrickDimension.orientation(
            landscape: .fixed(size: 50),
            portrait: .horizontalSizeClass(
                regular: .auto(estimate: .fixed(size: 100)),
                compact: .auto(estimate: .fixed(size: 50))
            )))
    }

    func testRawValue() {
        expectFatalError { 
            let auto = BrickDimension.auto(estimate: .fixed(size: 30))
            _ = BrickDimension._rawValue(for: 100, startingAt: 0, in: UIView(), with: auto)
        }
    }

}

// MARK: - Utility methods to `fake` UIScreen.mainScreen
extension BrickDimensionTests {

    /// Setup UIScreen.mainScreen to call a different method
    func swizzleScreen() {
        _ = NSObject.swizzleStaticMethodSelector(#selector(getter: UIScreen.main), withSelector: #selector(UIScreen.stubMainScreen), forClass: UIScreen.self)
    }

    /// Reset UIScreen.mainScreen to call a different method
    func resetScreen() {
        _ = NSObject.swizzleStaticMethodSelector(#selector(UIScreen.stubMainScreen), withSelector: #selector(getter: UIScreen.main), forClass: UIScreen.self)
    }

    /// Setup the UIScreen for the given test
    func setupScreen(isPortrait: Bool, horizontalSizeClass: UIUserInterfaceSizeClass, verticalSizeClass: UIUserInterfaceSizeClass) {
        StubScreen.horizontalSizeClass = horizontalSizeClass
        StubScreen.verticalSizeClass = verticalSizeClass
        setScreenPortrait(isPortrait)
    }

    func setScreenPortrait(_ isPortrait: Bool) {
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
    static let DefaultHorizontalSizeClass: UIUserInterfaceSizeClass = .unspecified
    static let DefaultVerticalSizeClass: UIUserInterfaceSizeClass = .unspecified
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

