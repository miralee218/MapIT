//
//  MapITTests.swift
//  MapITTests
//
//  Created by Mira on 2019/5/10.
//  Copyright © 2019 AppWork. All rights reserved.
//

import XCTest
import UIKit

class MapITTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func add(aaa: Int, bbb: Int) -> Int {
        return aaa + bbb
    }

    func testMira() {
        print("Hi")

        //3A - Arrange 準備素材與預期結果, Action 執行 function, Assert

        // - Arrange
        let aaa = 10
        let bbb = 20
        let expectedResult = aaa + bbb

        // - Action
        let actualResult = add(aaa: aaa, bbb: bbb)

        // - Assert
        XCTAssertEqual(actualResult, expectedResult)
    }
    func fibonacci1(num: Int) -> Int {
        if num <= 1 {
            return 1
        } else {
            return fibonacci(num: num - 1) + fibonacci(num: num - 2)
        }
    }

    func fibonacci(num: Int) -> Int {

        if num <= 1 {
            return 1
        }
        var array: [Int] = Array(repeating: 1, count: num + 1)
        for index in 0...array.count - 1 {
            if index <= 1 {
                array[index] = 1
                print(array[index])
            } else {
                array[index] = array[index - 1] + array[index - 2]
                print(array[index])
            }
        }
        return array[num]
    }

    func testFibonacci() {
        XCTAssert(fibonacci(num: 5) == 8)
    }
    func testFibonacciCorrect() {
        let n10 = fibonacci(num: 10)
        let n11 = fibonacci(num: 11)
        let n12 = fibonacci(num: 12)
        XCTAssert(n12 == n11 + n10)
    }
}
