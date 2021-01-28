//
//  ArrayTests.swift
//  QuickshaReTests
//
//  Created by 史 翔新 on 2021/01/29.
//  Copyright © 2021 Crazism. All rights reserved.
//

import XCTest
@testable import QuickshaRe

class ArrayTests: XCTestCase {

    func testKeepFirst() {
        
        typealias SUT = (originalArray: [Int], requiredCount: Int, expected: [Int])
        let suts: [SUT] = [
            ([1, 2, 3], 0, []),
            ([1, 2, 3], 1, [1]),
            ([1, 2, 3], 2, [1, 2]),
            ([1, 2, 3], 3, [1, 2, 3]),
            ([1, 2, 3], 4, [1, 2, 3]),
        ]
        
        for sut in suts {
            var array = sut.originalArray
            array.keep(first: sut.requiredCount)
            XCTAssertEqual(array, sut.expected)
        }
        
    }

}
