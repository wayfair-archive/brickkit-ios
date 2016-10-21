//
//  XCTests.swift
//  BrickApp
//
//  Created by Ruben Cagnie on 5/25/16.
//  Copyright © 2016 Wayfair. All rights reserved.
//

import XCTest

let frameSort: (CGRect, CGRect) -> Bool = {
    if $0.origin.y != $1.origin.y {
        return $0.origin.y < $1.origin.y
    } else {
        return $0.origin.x < $1.origin.x
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

extension XCTest {
    //MARK: - Utils
    func verifyAttributesToExpectedResult(attributes: [UICollectionViewLayoutAttributes], expectedResult: [Int: [CGRect]]) -> Bool {
        let frameMap: (attribute: UICollectionViewLayoutAttributes) -> CGRect = { $0.frame }
        return verifyAttributesToExpectedResult(attributes, map: frameMap , expectedResult: expectedResult, sort: frameSort)
    }

    func verifyAttributesToExpectedResult<T: Equatable>(attributes: [UICollectionViewLayoutAttributes], map: ((attribute: UICollectionViewLayoutAttributes) -> T), expectedResult: [Int: [T]], sort: ((T, T) -> Bool)? = nil) -> Bool {

        let array = simpleArrayWithFramesForCollectionViewAttributes(attributes, map: map)
        print("Actual: \(array)")
        print("Expected: \(expectedResult)")
        guard Array(expectedResult.keys.sort()) == Array(array.keys.sort()) else {
            print("Keys are not the same")
            print("Keys: \(Array(array.keys.sort()))")
            print("Expected Keys: \(Array(expectedResult.keys.sort()))")
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
                print("\(section) not equal")
                print("Frames: \(frames)")
                print("ExpectedFrames: \(expectedFrames)")
                return false
            } else {
                print("\(section) equal")
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
