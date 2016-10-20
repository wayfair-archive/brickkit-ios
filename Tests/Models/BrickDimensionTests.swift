//
//  BrickDimensionTests.swift
//  BrickKit
//
//  Created by Ruben Cagnie on 9/29/16.
//  Copyright © 2016 Wayfair LLC. All rights reserved.
//

import XCTest
@testable import BrickKit

struct TestDeviceInfo: BrickDimensionDeviceInfo {
    var isPortrait: Bool
    var horizontalSizeClass: UIUserInterfaceSizeClass
    var verticalSizeClass: UIUserInterfaceSizeClass
}

class BrickDimensionTests: XCTestCase {

    #if os(iOS)
    func testViewAsDeviceInfo() {
        let view = UIView()
        XCTAssertNotNil(view.horizontalSizeClass)
        XCTAssertNotNil(view.verticalSizeClass)
        XCTAssertEqual(view.isPortrait, UIDevice.currentDevice().orientation.isPortrait)
    }
    #else
    func testViewAsDeviceInfo() {
        let view = UIView()
        XCTAssertNotNil(view.horizontalSizeClass)
        XCTAssertNotNil(view.verticalSizeClass)
        XCTAssertFalse(view.isPortrait)
    }
    #endif

    func testFixed() {
        let fixed = BrickDimension.Fixed(size: 50)
        XCTAssertEqual(fixed.value(for: 1000, in: UIView()), 50)
        XCTAssertEqual(fixed.dimension(in: UIView()), fixed)
        XCTAssertFalse(fixed.isEstimate(in: UIView()))
        XCTAssertEqual(fixed, BrickDimension.Fixed(size: 50))
        XCTAssertNotEqual(fixed, BrickDimension.Fixed(size: 100))
    }

    func testRatio() {
        let ratio = BrickDimension.Ratio(ratio: 0.5)
        XCTAssertEqual(ratio.value(for: 1000, in: UIView()), 500)
        XCTAssertEqual(ratio.dimension(in: UIView()), ratio)
        XCTAssertFalse(ratio.isEstimate(in: UIView()))
        XCTAssertEqual(ratio, BrickDimension.Ratio(ratio: 0.5))
        XCTAssertNotEqual(ratio, BrickDimension.Fixed(size: 100))
    }

    func testAutoFixed() {
        let autoFixed = BrickDimension.Auto(estimate: BrickDimension.Fixed(size: 50))
        XCTAssertEqual(autoFixed.value(for: 1000, in: UIView()), 50)
        XCTAssertEqual(autoFixed.dimension(in: UIView()), autoFixed)
        XCTAssertTrue(autoFixed.isEstimate(in: UIView()))
        XCTAssertEqual(autoFixed, BrickDimension.Auto(estimate: BrickDimension.Fixed(size: 50)))
    }

    func testAutoRatio() {
        let autoRatio = BrickDimension.Auto(estimate: BrickDimension.Ratio(ratio: 0.5))
        XCTAssertEqual(autoRatio.value(for: 1000, in: UIView()), 500)
        XCTAssertEqual(autoRatio.dimension(in: UIView()), autoRatio)
        XCTAssertTrue(autoRatio.isEstimate(in: UIView()))
        XCTAssertEqual(autoRatio, BrickDimension.Auto(estimate: BrickDimension.Ratio(ratio: 0.5)))
    }

    func testOrientationPortrait() {
        let deviceInfo = TestDeviceInfo(isPortrait: true, horizontalSizeClass: .Compact, verticalSizeClass: .Compact)
        let orientation = BrickDimension.Orientation(landscape: BrickDimension.Fixed(size: 100), portrait: BrickDimension.Fixed(size: 50))
        XCTAssertEqual(orientation.value(for: 1000, in: deviceInfo), 50)
        XCTAssertEqual(orientation.dimension(in: deviceInfo), BrickDimension.Fixed(size: 50))
        XCTAssertEqual(orientation, BrickDimension.Orientation(landscape: BrickDimension.Fixed(size: 100), portrait: BrickDimension.Fixed(size: 50)))
    }

    func testOrientationLandscape() {
        let deviceInfo = TestDeviceInfo(isPortrait: false, horizontalSizeClass: .Compact, verticalSizeClass: .Compact)
        let orientation = BrickDimension.Orientation(landscape: BrickDimension.Fixed(size: 100), portrait: BrickDimension.Fixed(size: 50))
        XCTAssertEqual(orientation.value(for: 1000, in: deviceInfo), 100)
        XCTAssertEqual(orientation.dimension(in: deviceInfo), BrickDimension.Fixed(size: 100))
        XCTAssertEqual(orientation, BrickDimension.Orientation(landscape: BrickDimension.Fixed(size: 100), portrait: BrickDimension.Fixed(size: 50)))
    }

    func testHorizontalSizeClassCompact() {
        let deviceInfo = TestDeviceInfo(isPortrait: true, horizontalSizeClass: .Compact, verticalSizeClass: .Regular)
        let sizeClass = BrickDimension.HorizontalSizeClass(regular: BrickDimension.Fixed(size: 100), compact: BrickDimension.Fixed(size: 50))
        XCTAssertEqual(sizeClass.value(for: 1000, in: deviceInfo), 50)
        XCTAssertEqual(sizeClass.dimension(in: deviceInfo), BrickDimension.Fixed(size: 50))
        XCTAssertEqual(sizeClass, BrickDimension.HorizontalSizeClass(regular: BrickDimension.Fixed(size: 100), compact: BrickDimension.Fixed(size: 50)))

    }

    func testHorizontalSizeClassRegular() {
        let deviceInfo = TestDeviceInfo(isPortrait: true, horizontalSizeClass: .Regular, verticalSizeClass: .Compact)
        let sizeClass = BrickDimension.HorizontalSizeClass(regular: BrickDimension.Fixed(size: 100), compact: BrickDimension.Fixed(size: 50))
        XCTAssertEqual(sizeClass.value(for: 1000, in: deviceInfo), 100)
        XCTAssertEqual(sizeClass.dimension(in: deviceInfo), BrickDimension.Fixed(size: 100))
        XCTAssertEqual(sizeClass, BrickDimension.HorizontalSizeClass(regular: BrickDimension.Fixed(size: 100), compact: BrickDimension.Fixed(size: 50)))
    }

    func testVerticalSizeClassCompact() {
        let deviceInfo = TestDeviceInfo(isPortrait: true, horizontalSizeClass: .Regular, verticalSizeClass: .Compact)
        let sizeClass = BrickDimension.VerticalSizeClass(regular: BrickDimension.Fixed(size: 100), compact: BrickDimension.Fixed(size: 50))
        XCTAssertEqual(sizeClass.value(for: 1000, in: deviceInfo), 50)
        XCTAssertEqual(sizeClass.dimension(in: deviceInfo), BrickDimension.Fixed(size: 50))
        XCTAssertEqual(sizeClass, BrickDimension.VerticalSizeClass(regular: BrickDimension.Fixed(size: 100), compact: BrickDimension.Fixed(size: 50)))
    }

    func testVerticalSizeClassRegular() {
        let deviceInfo = TestDeviceInfo(isPortrait: true, horizontalSizeClass: .Compact, verticalSizeClass: .Regular)
        let sizeClass = BrickDimension.VerticalSizeClass(regular: BrickDimension.Fixed(size: 100), compact: BrickDimension.Fixed(size: 50))
        XCTAssertEqual(sizeClass.value(for: 1000, in: deviceInfo), 100)
        XCTAssertEqual(sizeClass.dimension(in: deviceInfo), BrickDimension.Fixed(size: 100))
        XCTAssertEqual(sizeClass, BrickDimension.VerticalSizeClass(regular: BrickDimension.Fixed(size: 100), compact: BrickDimension.Fixed(size: 50)))
    }

    func testNestedPortraitCompact() {
        let deviceInfo = TestDeviceInfo(isPortrait: true, horizontalSizeClass: .Compact, verticalSizeClass: .Regular)

        let nested = BrickDimension.Orientation(
            landscape: .Fixed(size: 50),
            portrait: .HorizontalSizeClass(
                regular: .Auto(estimate: .Fixed(size: 100)),
                compact: .Auto(estimate: .Fixed(size: 50))
            ))
        XCTAssertEqual(nested.value(for: 1000, in: deviceInfo), 50)
        XCTAssertEqual(nested.dimension(in: deviceInfo), BrickDimension.Auto(estimate: BrickDimension.Fixed(size: 50)))
        XCTAssertTrue(nested._isEstimate(in: deviceInfo))
        XCTAssertEqual(nested, BrickDimension.Orientation(
            landscape: .Fixed(size: 50),
            portrait: .HorizontalSizeClass(
                regular: .Auto(estimate: .Fixed(size: 100)),
                compact: .Auto(estimate: .Fixed(size: 50))
            )))
    }

    func testRawValue() {
        expectFatalError("Only Ratio and Fixed are allowed") { 
            let auto = BrickDimension.Auto(estimate: .Fixed(size: 30))
            BrickDimension._rawValue(for: 100, in: UIView(), with: auto)
        }
    }

}
