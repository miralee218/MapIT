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
            for _ in 0...500 {
                let _ = UIView()
            }
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

}
