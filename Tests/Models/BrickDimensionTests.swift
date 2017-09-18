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
        let fixed = BrickDimension.fixed(size: 50)
        XCTAssertEqual(fixed.value(for: 1000, startingAt: 0), 50)
        XCTAssertEqual(fixed.dimension(withValue: nil), fixed)
        XCTAssertFalse(fixed.isEstimate(withValue: nil))
        XCTAssertEqual(fixed, BrickDimension.fixed(size: 50))
        XCTAssertNotEqual(fixed, BrickDimension.fixed(size: 100))
    }

    func testRatio() {
        let ratio = BrickDimension.ratio(ratio: 0.5)
        XCTAssertEqual(ratio.value(for: 1000, startingAt: 0), 500)
        XCTAssertEqual(ratio.dimension(withValue: nil), ratio)
        XCTAssertFalse(ratio.isEstimate(withValue: nil))
        XCTAssertEqual(ratio, BrickDimension.ratio(ratio: 0.5))
        XCTAssertNotEqual(ratio, BrickDimension.fixed(size: 100))
    }

    func testFill() {
        let ratio = BrickDimension.fill
        XCTAssertEqual(ratio.value(for: 1000, startingAt: 0), 1000)
        XCTAssertEqual(ratio.dimension(withValue: nil), ratio)
        XCTAssertFalse(ratio.isEstimate(withValue: nil))
        XCTAssertEqual(ratio, BrickDimension.fill)
        XCTAssertNotEqual(ratio, BrickDimension.fixed(size: 100))
    }

    func testFillWithStartingOrigin() {
        let ratio = BrickDimension.fill
        XCTAssertEqual(ratio.value(for: 1000, startingAt: 500), 500)
        XCTAssertEqual(ratio.dimension(withValue: nil), ratio)
        XCTAssertFalse(ratio.isEstimate(withValue: nil))
        XCTAssertEqual(ratio, BrickDimension.fill)
        XCTAssertNotEqual(ratio, BrickDimension.fixed(size: 100))
    }

    func testFillWithStartingOriginThatIsTooBig() {
        let ratio = BrickDimension.fill
        XCTAssertEqual(ratio.value(for: 1000, startingAt: 1001), 1000)
        XCTAssertEqual(ratio.dimension(withValue: nil), ratio)
        XCTAssertFalse(ratio.isEstimate(withValue: nil))
        XCTAssertEqual(ratio, BrickDimension.fill)
        XCTAssertNotEqual(ratio, BrickDimension.fixed(size: 100))
    }

    func testAutoFixed() {
        let autoFixed = BrickDimension.auto(estimate: BrickDimension.fixed(size: 50))
        XCTAssertEqual(autoFixed.value(for: 1000, startingAt: 0), 50)
        XCTAssertEqual(autoFixed.dimension(withValue: nil), autoFixed)
        XCTAssertTrue(autoFixed.isEstimate(withValue: nil))
        XCTAssertEqual(autoFixed, BrickDimension.auto(estimate: BrickDimension.fixed(size: 50)))
    }

    func testAutoRatio() {
        let autoRatio = BrickDimension.auto(estimate: BrickDimension.ratio(ratio: 0.5))
        XCTAssertEqual(autoRatio.value(for: 1000, startingAt: 0), 500)
        XCTAssertEqual(autoRatio.dimension(withValue: nil), autoRatio)
        XCTAssertTrue(autoRatio.isEstimate(withValue: nil))
        XCTAssertEqual(autoRatio, BrickDimension.auto(estimate: BrickDimension.ratio(ratio: 0.5)))
    }

    func testOrientationPortrait() {
        setupScreen(isPortrait: true, horizontalSizeClass: .compact, verticalSizeClass: .compact)
        let orientation = BrickDimension.orientation(landscape: BrickDimension.fixed(size: 100), portrait: BrickDimension.fixed(size: 50))
        XCTAssertEqual(orientation.value(for: 1000, startingAt: 0), 50)
        XCTAssertEqual(orientation.dimension(withValue: nil), BrickDimension.fixed(size: 50))
        XCTAssertEqual(orientation, BrickDimension.orientation(landscape: BrickDimension.fixed(size: 100), portrait: BrickDimension.fixed(size: 50)))
    }

    func testOrientationLandscape() {
        setupScreen(isPortrait: false, horizontalSizeClass: .compact, verticalSizeClass: .compact)
        let orientation = BrickDimension.orientation(landscape: BrickDimension.fixed(size: 100), portrait: BrickDimension.fixed(size: 50))
        XCTAssertEqual(orientation.value(for: 1000, startingAt: 0), 100)
        XCTAssertEqual(orientation.dimension(withValue: nil), BrickDimension.fixed(size: 100))
        XCTAssertEqual(orientation, BrickDimension.orientation(landscape: BrickDimension.fixed(size: 100), portrait: BrickDimension.fixed(size: 50)))
    }

    func testHorizontalSizeClassCompact() {
        setupScreen(isPortrait: true, horizontalSizeClass: .compact, verticalSizeClass: .regular)
        let sizeClass = BrickDimension.horizontalSizeClass(regular: BrickDimension.fixed(size: 100), compact: BrickDimension.fixed(size: 50))
        XCTAssertEqual(sizeClass.value(for: 1000, startingAt: 0), 50)
        XCTAssertEqual(sizeClass.dimension(withValue: nil), BrickDimension.fixed(size: 50))
        XCTAssertEqual(sizeClass, BrickDimension.horizontalSizeClass(regular: BrickDimension.fixed(size: 100), compact: BrickDimension.fixed(size: 50)))

    }

    func testHorizontalSizeClassRegular() {
        setupScreen(isPortrait: true, horizontalSizeClass: .regular, verticalSizeClass: .compact)
        let sizeClass = BrickDimension.horizontalSizeClass(regular: BrickDimension.fixed(size: 100), compact: BrickDimension.fixed(size: 50))
        XCTAssertEqual(sizeClass.value(for: 1000, startingAt: 0), 100)
        XCTAssertEqual(sizeClass.dimension(withValue: nil), BrickDimension.fixed(size: 100))
        XCTAssertEqual(sizeClass, BrickDimension.horizontalSizeClass(regular: BrickDimension.fixed(size: 100), compact: BrickDimension.fixed(size: 50)))
    }

    func testVerticalSizeClassCompact() {
        setupScreen(isPortrait: true, horizontalSizeClass: .regular, verticalSizeClass: .compact)
        let sizeClass = BrickDimension.verticalSizeClass(regular: BrickDimension.fixed(size: 100), compact: BrickDimension.fixed(size: 50))
        XCTAssertEqual(sizeClass.value(for: 1000, startingAt: 0), 50)
        XCTAssertEqual(sizeClass.dimension(withValue: nil), BrickDimension.fixed(size: 50))
        XCTAssertEqual(sizeClass, BrickDimension.verticalSizeClass(regular: BrickDimension.fixed(size: 100), compact: BrickDimension.fixed(size: 50)))
    }

    func testVerticalSizeClassRegular() {
        setupScreen(isPortrait: true, horizontalSizeClass: .compact, verticalSizeClass: .regular)
        let sizeClass = BrickDimension.verticalSizeClass(regular: BrickDimension.fixed(size: 100), compact: BrickDimension.fixed(size: 50))
        XCTAssertEqual(sizeClass.value(for: 1000, startingAt: 0), 100)
        XCTAssertEqual(sizeClass.dimension(withValue: nil), BrickDimension.fixed(size: 100))
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
        XCTAssertEqual(nested.value(for: 1000, startingAt: 0), 50)
        XCTAssertEqual(nested.dimension(withValue: nil), BrickDimension.auto(estimate: BrickDimension.fixed(size: 50)))
        XCTAssertTrue(nested.isEstimate(withValue: nil))
        XCTAssertEqual(nested, BrickDimension.orientation(
            landscape: .fixed(size: 50),
            portrait: .horizontalSizeClass(
                regular: .auto(estimate: .fixed(size: 100)),
                compact: .auto(estimate: .fixed(size: 50))
            )))
    }
    
    func testBrickRangeDimension() {
        setupScreen(isPortrait: true, horizontalSizeClass: .compact, verticalSizeClass: .regular)
        
        let additionalRangePairs: [RangeDimensionPair] = [(dimension: .ratio(ratio: 0.5), minimumSize: CGFloat(350)),
                                                          (dimension: .ratio(ratio: 0.25), minimumSize: CGFloat(700))]
        let regularDimensionRange : BrickDimension = .dimensionRange(default: .ratio(ratio: 1.0), additionalRangePairs: additionalRangePairs)
        XCTAssertEqual(regularDimensionRange.value(for: 320, startingAt: 0), 320)
        setupScreen(isPortrait: true, horizontalSizeClass: .regular, verticalSizeClass: .regular)
        XCTAssertEqual(regularDimensionRange.value(for: 350, startingAt: 0), 175)
        XCTAssertEqual(regularDimensionRange.value(for: 768, startingAt: 0), 192)
        XCTAssertEqual(regularDimensionRange.dimension(withValue: nil).value(for: 400, startingAt: 0), 400)
    }
    
    func testVariableDimensionEquality() {
        let additionalRangePairs1: [RangeDimensionPair] = [(dimension: .ratio(ratio: 1/2), minimumSize: CGFloat(350))]
        let dimensionRange1: BrickDimension = .dimensionRange(default: .ratio(ratio: 1.0), additionalRangePairs: additionalRangePairs1)
        let brickRangeDimension1 =  BrickRangeDimension(default: .ratio(ratio: 1.0), additionalRangePairs: additionalRangePairs1)
        let additionalRangePairs2: [RangeDimensionPair] = [(dimension: .ratio(ratio: 0.5), minimumSize: CGFloat(350))]
        let dimensionRange2: BrickDimension = .dimensionRange(default: .ratio(ratio: 0.5 + 0.5), additionalRangePairs: additionalRangePairs2)
        let brickRangeDimension2 =  BrickRangeDimension(default: .ratio(ratio: 0.5 + 0.5), additionalRangePairs: additionalRangePairs2)
        let additionalRangePairs3: [RangeDimensionPair] = [(dimension: .ratio(ratio: 1/3), minimumSize: CGFloat(350))]
        let dimensionRange3: BrickDimension = .dimensionRange(default: .ratio(ratio: 1.0), additionalRangePairs: additionalRangePairs3)
        let brickRangeDimension3 =  BrickRangeDimension(default: .ratio(ratio: 1.0), additionalRangePairs: additionalRangePairs3)
        let additionalRangePairs4: [RangeDimensionPair] = [(dimension: .ratio(ratio: 1/2), minimumSize: CGFloat(350))]
        let dimensionRange4: BrickDimension = .dimensionRange(default: .ratio(ratio: 1.5), additionalRangePairs: additionalRangePairs4)
        let brickRangeDimension4 =  BrickRangeDimension(default: .ratio(ratio: 1.5), additionalRangePairs: additionalRangePairs4)
        let additionalRangePairs5: [RangeDimensionPair] = [(dimension: .ratio(ratio: 1/2), minimumSize: CGFloat(350)), (dimension: .ratio(ratio: 1/3), minimumSize: CGFloat(500))]
        let dimensionRange5: BrickDimension = .dimensionRange(default: .ratio(ratio: 1.5), additionalRangePairs: additionalRangePairs5)
        let brickRangeDimension5 =  BrickRangeDimension(default: .ratio(ratio: 1.5), additionalRangePairs: additionalRangePairs5)
        XCTAssertEqual(dimensionRange1, dimensionRange2)
        XCTAssertTrue(brickRangeDimension1 == brickRangeDimension2)
        XCTAssertNotEqual(dimensionRange1, dimensionRange3)
        XCTAssertFalse(brickRangeDimension1 == brickRangeDimension3)
        XCTAssertNotEqual(dimensionRange1, dimensionRange4)
        XCTAssertFalse(brickRangeDimension1 == brickRangeDimension4)
        XCTAssertNotEqual(dimensionRange1, dimensionRange5)
        XCTAssertFalse(brickRangeDimension1 == brickRangeDimension5)
        
        
        let dimensionPair1: RangeDimensionPair = (dimension: .ratio(ratio: 1/2), minimumSize: CGFloat(350))
        let dimensionPair2: RangeDimensionPair = (dimension: .ratio(ratio: 0.25 * 2), minimumSize: (300.01 + 49.99))
        let dimensionPair3: RangeDimensionPair = (dimension: .ratio(ratio: 0.25 * 2), minimumSize: (300.01 + 49.98))
        let dimensionPair4: RangeDimensionPair = (dimension: .ratio(ratio: 1.5), minimumSize: CGFloat(350))
        XCTAssertTrue(dimensionPair1 == dimensionPair2)
        XCTAssertTrue(dimensionPair2 == dimensionPair1)
        XCTAssertFalse(dimensionPair1 == dimensionPair3)
        XCTAssertFalse(dimensionPair1 == dimensionPair4)
        XCTAssertFalse(almostEqualRelative(first: 350, second: 350.001)) // Needed for code coverage completeness.
        
    }
    
    func testNestedBrickRangeDimension() {
        let additionalRangePairs: [RangeDimensionPair] = [(dimension: .ratio(ratio: 1/2), minimumSize: CGFloat(350)),
                                                     (dimension: .ratio(ratio: 0.25), minimumSize: CGFloat(700))]
        let nestedDimensionRange : BrickDimension = .dimensionRange(default: .ratio(ratio: 0.5), additionalRangePairs: additionalRangePairs)
        let regularDimensionRange : BrickDimension = .dimensionRange(default: nestedDimensionRange, additionalRangePairs: [])
        XCTAssertEqual(regularDimensionRange.dimension(withValue: 200).value(for: 200, startingAt: 0), 100);
        XCTAssertEqual(regularDimensionRange.dimension(withValue: 400).value(for: 400, startingAt: 0), 200);
        XCTAssertEqual(regularDimensionRange.dimension(withValue: 800).value(for: 800, startingAt: 0), 200);
    }

    func testRawValue() {
        expectFatalError { 
            let auto = BrickDimension.auto(estimate: .fixed(size: 30))
            _ = BrickDimension._rawValue(for: 100, startingAt: 0, with: auto)
        }
    }

    func testRatioCheck() {
        let simpleRatio = BrickDimension.ratio(ratio: 0.3)
        XCTAssertTrue(simpleRatio.isRatio())

        let nested = BrickDimension.orientation(
            landscape: .ratio(ratio: 0.3),
            portrait: .horizontalSizeClass(
                regular: .auto(estimate: .fixed(size: 100)),
                compact: .ratio(ratio: 0.3)
            ))

        setupScreen(isPortrait: false, horizontalSizeClass: .compact, verticalSizeClass: .compact)
        XCTAssertTrue(nested.isRatio())

        setupScreen(isPortrait: true, horizontalSizeClass: .compact, verticalSizeClass: .compact)
        XCTAssertTrue(nested.isRatio())

        setupScreen(isPortrait: true, horizontalSizeClass: .regular, verticalSizeClass: .compact)
        XCTAssertFalse(nested.isRatio())
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

