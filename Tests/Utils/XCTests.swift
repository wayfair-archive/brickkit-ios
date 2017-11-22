//
//  XCTests.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest
@testable import BrickKit

let frameSort: (CGRect, CGRect) -> Bool = {
    if $0.origin.y != $1.origin.y {
        return $0.origin.y < $1.origin.y
    } else if $0.origin.x != $1.origin.x {
        return $0.origin.x < $1.origin.x
    } else if $0.maxY != $1.maxY{
        return $0.maxY < $1.maxY
    } else {
        return $0.maxX < $1.maxX
    }
}

public func XCTAssertEqual(_ expression1: CGRect?, _ expression2: CGRect?, accuracy: CGRect, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {

    guard let argument1 = expression1, let argument2 = expression2 else {
        XCTAssertEqual(expression1, CGRect(x: 0, y: 0, width: 320, height: 54), message, file: file, line: line)
        XCTAssertEqual(expression2, CGRect(x: 0, y: 0, width: 305, height: 39), message, file: file, line: line)
        return
    }
    XCTAssertEqual(argument1.origin.x, argument2.origin.x, accuracy: accuracy.origin.x, message, file: file, line: line)
    XCTAssertEqual(argument1.origin.y, argument2.origin.y, accuracy: accuracy.origin.y, message, file: file, line: line)
    XCTAssertEqual(argument1.size.width, argument2.size.width, accuracy: accuracy.size.width, message, file: file, line: line)
    XCTAssertEqual(argument1.size.height, argument2.size.height, accuracy: accuracy.size.height, message, file: file, line: line)
}

public func XCTAssertEqual(_ expression1: CGSize?, _ expression2: CGSize?, accuracy: CGSize, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {

    guard let argument1 = expression1, let argument2 = expression2 else {
//        XCTAssertEqual(expression1, CGRectMake(0, 0, 320, 54), message, file: file, line: line)
//        XCTAssertEqual(expression2, CGRectMake(0, 0, 305, 39), message, file: file, line: line)
        return
    }
    XCTAssertEqual(argument1.width, argument2.width, accuracy: accuracy.width, message, file: file, line: line)
    XCTAssertEqual(argument1.height, argument2.height, accuracy: accuracy.height, message, file: file, line: line)
}

extension XCTest {
    //MARK: - Utils
    func verifyAttributesToExpectedResult(_ attributes: [UICollectionViewLayoutAttributes], expectedResult: [Int: [CGRect]]) -> Bool {
        let frameMap: (_ attribute: UICollectionViewLayoutAttributes) -> CGRect = { $0.frame }
        return verifyAttributesToExpectedResult(attributes, map: frameMap , expectedResult: expectedResult, sort: frameSort)
    }

    func verifyAttributesToExpectedResult<T: Equatable>(_ attributes: [UICollectionViewLayoutAttributes], map: @escaping ((_ attribute: UICollectionViewLayoutAttributes) -> T), expectedResult: [Int: [T]], sort: ((T, T) -> Bool)? = nil) -> Bool {

        let array = simpleArrayWithFramesForCollectionViewAttributes(attributes, map: map)
        BrickLogger.logVerbose("Actual: \(array)")
        BrickLogger.logVerbose("Expected: \(expectedResult)")
        guard Array(expectedResult.keys.sorted()) == Array(array.keys.sorted()) else {
            BrickLogger.logVerbose("Keys are not the same")
            BrickLogger.logVerbose("Keys: \(Array(array.keys.sorted()))")
            BrickLogger.logVerbose("Expected Keys: \(Array(expectedResult.keys.sorted()))")
            return false
        }

        for (section, var frames) in array {
            guard var expectedFrames = expectedResult[section] else {
                return false
            }
            if let s = sort {
                frames.sort(by: s)
                expectedFrames.sort(by: s)
            }

            if frames != expectedFrames {
                BrickLogger.logVerbose("\(section) not equal")
                BrickLogger.logVerbose("Frames: \(frames)")
                BrickLogger.logVerbose("ExpectedFrames: \(expectedFrames)")
                return false
            } else {
                BrickLogger.logVerbose("\(section) equal")
            }
        }
        return true
    }

    func simpleArrayWithFramesForCollectionViewAttributes<T>(_ attributes: [UICollectionViewLayoutAttributes], map: @escaping ((_ attribute: UICollectionViewLayoutAttributes) -> T)) -> [Int: [T]] {
        var result = [Int: [T]]()

        let categorised = attributes.categorise { (attribute) -> Int in
            return attribute.indexPath.section
        }

        for (index, attributes) in categorised {
            result[index] = attributes.map { map($0) }
        }

        return result
    }

}

extension Sequence {

    /// Categorises elements of self into a dictionary, with the keys given by keyFunc

    func categorise<U>(_ keyFunc: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        var dict: [U:[Iterator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}

extension XCTest {

    var isRunningOnA32BitDevice: Bool {
        return MemoryLayout<Int>.size == MemoryLayout<Int32>.size
    }
}

extension BrickCollectionView {

    func setupSingleBrickAndLayout(_ brick: Brick) {
        setupSectionAndLayout(BrickSection(bricks: [brick]))
    }

    func setupSectionAndLayout(_ section: BrickSection) {
        self.setSection(section)
        self.layoutSubviews()
        self.layoutIfNeeded() // We need to do this layoutIfNeeded, because of the new invalidation on height calculation
    }
}
