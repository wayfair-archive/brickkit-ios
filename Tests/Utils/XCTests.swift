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

public func XCTAssertEqualWithAccuracy(expression1: CGRect?, _ expression2: CGRect?, accuracy: CGRect, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {

    guard let argument1 = expression1, let argument2 = expression2 else {
        XCTAssertEqual(expression1, CGRectMake(0, 0, 320, 54), message, file: file, line: line)
        XCTAssertEqual(expression2, CGRectMake(0, 0, 305, 39), message, file: file, line: line)
        return
    }
    XCTAssertEqualWithAccuracy(argument1.origin.x, argument2.origin.x, accuracy: accuracy.origin.x, message, file: file, line: line)
    XCTAssertEqualWithAccuracy(argument1.origin.y, argument2.origin.y, accuracy: accuracy.origin.y, message, file: file, line: line)
    XCTAssertEqualWithAccuracy(argument1.size.width, argument2.size.width, accuracy: accuracy.size.width, message, file: file, line: line)
    XCTAssertEqualWithAccuracy(argument1.size.height, argument2.size.height, accuracy: accuracy.size.height, message, file: file, line: line)
}

public func XCTAssertEqualWithAccuracy(expression1: CGSize?, _ expression2: CGSize?, accuracy: CGSize, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {

    guard let argument1 = expression1, let argument2 = expression2 else {
//        XCTAssertEqual(expression1, CGRectMake(0, 0, 320, 54), message, file: file, line: line)
//        XCTAssertEqual(expression2, CGRectMake(0, 0, 305, 39), message, file: file, line: line)
        return
    }
    XCTAssertEqualWithAccuracy(argument1.width, argument2.width, accuracy: accuracy.width, message, file: file, line: line)
    XCTAssertEqualWithAccuracy(argument1.height, argument2.height, accuracy: accuracy.height, message, file: file, line: line)
}

extension XCTest {
    //MARK: - Utils
    func verifyAttributesToExpectedResult(attributes: [UICollectionViewLayoutAttributes], expectedResult: [Int: [CGRect]]) -> Bool {
        let frameMap: (attribute: UICollectionViewLayoutAttributes) -> CGRect = { $0.frame }
        return verifyAttributesToExpectedResult(attributes, map: frameMap , expectedResult: expectedResult, sort: frameSort)
    }

    func verifyAttributesToExpectedResult<T: Equatable>(attributes: [UICollectionViewLayoutAttributes], map: ((attribute: UICollectionViewLayoutAttributes) -> T), expectedResult: [Int: [T]], sort: ((T, T) -> Bool)? = nil) -> Bool {

        let array = simpleArrayWithFramesForCollectionViewAttributes(attributes, map: map)
        BrickKit.print("Actual: \(array)")
        BrickKit.print("Expected: \(expectedResult)")
        guard Array(expectedResult.keys.sort()) == Array(array.keys.sort()) else {
            BrickKit.print("Keys are not the same")
            BrickKit.print("Keys: \(Array(array.keys.sort()))")
            BrickKit.print("Expected Keys: \(Array(expectedResult.keys.sort()))")
            return false
        }

        for (section, var frames) in array {
            guard var expectedFrames = expectedResult[section] else {
                return false
            }
            if let s = sort {
                frames.sortInPlace(s)
                expectedFrames.sortInPlace(s)
            }

            if frames != expectedFrames {
                BrickKit.print("\(section) not equal")
                BrickKit.print("Frames: \(frames)")
                BrickKit.print("ExpectedFrames: \(expectedFrames)")
                return false
            } else {
                BrickKit.print("\(section) equal")
            }
        }
        return true
    }

    func simpleArrayWithFramesForCollectionViewAttributes<T>(attributes: [UICollectionViewLayoutAttributes], map: ((attribute: UICollectionViewLayoutAttributes) -> T)) -> [Int: [T]] {
        var result = [Int: [T]]()

        let categorised = attributes.categorise { (attribute) -> Int in
            return attribute.indexPath.section
        }

        for (index, attributes) in categorised {
            result[index] = attributes.map { map(attribute: $0) }
        }

        return result
    }

}

extension SequenceType {

    /// Categorises elements of self into a dictionary, with the keys given by keyFunc

    func categorise<U : Hashable>(@noescape keyFunc: Generator.Element -> U) -> [U:[Generator.Element]] {
        var dict: [U:[Generator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}

extension XCTest {

    var isRunningOnA32BitDevice: Bool {
        return sizeof(Int) == sizeof(Int32)
    }
}

extension BrickCollectionView {

    func setupSingleBrickAndLayout(brick: Brick) {
        setupSectionAndLayout(BrickSection(bricks: [brick]))
    }

    func setupSectionAndLayout(section: BrickSection) {
        self.registerBrickClass(CollectionBrick.self)
        self.registerBrickClass(DummyBrick.self)
        self.registerBrickClass(LabelBrick.self)
        self.registerBrickClass(ButtonBrick.self)
        self.registerBrickClass(ImageBrick.self)

        self.registerBrickClass(GenericBrick<UILabel>.self)
        self.registerBrickClass(GenericBrick<UIButton>.self)
        self.registerBrickClass(GenericBrick<UIImageView>.self)

        self.setSection(section)
        self.layoutSubviews()
    }
}
