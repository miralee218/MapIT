//
//  MapITTests.swift
//  MapITTests
//
//  Created by Mira on 2019/5/13.
//  Copyright © 2019 AppWork. All rights reserved.
//

import XCTest
import UIKit
import MapKit
import CoreData
@testable import MapIT

class MapITTests: XCTestCase {
    var mapManager: MapManager!
    var formatDisplayTest: FormatDisplay!
    let mapView = MKMapView()
    var allTravel: [Travel]?
    
    override func setUp() {
        super.setUp()
        formatDisplayTest = FormatDisplay()
    }
    override func tearDown() {
        
        formatDisplayTest = nil
        
        super.tearDown()
    }
    func test_numberOfDates_whenSecondLessThanSixty() {
        
        // arrange
        let seconds = 50
        
        // act
        let time = FormatDisplay.time(seconds)
        
        // assert
        XCTAssertEqual(time, "0:00:\(seconds)")
    }
    func test_numberOfDates_whenSecond() {
        
        // arrange
        let inputSeconds = 4261
        let secondsOfMinute = 60
        let secondsOfHours = 3600
        let munites = inputSeconds.quotientAndRemainder(dividingBy: secondsOfMinute)
        let hours = inputSeconds.quotientAndRemainder(dividingBy: secondsOfHours)
        
        // act
        let time = FormatDisplay.time(inputSeconds)

        // assert
        if inputSeconds > secondsOfMinute && inputSeconds < 600 {
            XCTAssertEqual(time, "0:0\(munites.quotient):\(munites.remainder)")
        } else if inputSeconds < secondsOfMinute {
            XCTAssertEqual(time, "0:00:\(inputSeconds)")
        } else if inputSeconds >= 600 && inputSeconds < secondsOfHours {
            XCTAssertEqual(time, "0:\(munites.quotient):\(munites.remainder)")
        } else if inputSeconds > secondsOfHours {
            if hours.remainder / secondsOfMinute < 10 && munites.remainder < 10 {
                XCTAssertEqual(time, "\(hours.quotient):0\(hours.remainder / secondsOfMinute):0\(munites.remainder)")
            } else if hours.remainder / secondsOfMinute < 10 {
                XCTAssertEqual(time, "\(hours.quotient):0\(hours.remainder / secondsOfMinute):\(munites.remainder + 1)")
            } else if munites.remainder < 10 {
                    XCTAssertEqual(time, "\(hours.quotient):\(hours.remainder / secondsOfMinute):0\(munites.remainder)")
            } else {
                XCTAssertEqual(time, "\(hours.quotient):\(hours.remainder / secondsOfMinute):\(munites.remainder)")
            }
        }
    }
    
    func test_Add() {
        let result = MapManager.addTest(xxx: 2, yyy: 2)
        XCTAssert(result == 4)
    }
    func test_contentInit() {
        // Arrange
        let title = "Hello"
        let time = "World"
        let content = "!"
        let tableView = UITableView()
        tableView.mr_registerCellWithNib(identifier: String(describing: RecordTableViewCell.self), bundle: nil)
        guard let tableViewCell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: RecordTableViewCell.self)) as? RecordTableViewCell else {
                return
        }
        
        // Act
        tableViewCell.contentInit(name: title, time: time, content: content)
        
        // Assert
        XCTAssertEqual(tableViewCell.travelNameLabel.text, "Hello")
        XCTAssertEqual(tableViewCell.travelTimeLabel.text, "World")
        XCTAssertEqual(tableViewCell.travelContentLabel.text, "!")
    }
    
//    func test_formatDisplay_travelDate() {
//        // Arrange
//        allTravel = MapManager.getAllTravel(noDataAction: {
//            }, hadDataAction: {
//        })
//        let timestamp: Date = (allTravel?.first!.createTimestamp)!
//        // Act
//        let formatted = FormatDisplay.travelDate(timestamp)
//        // Assert
//        XCTAssertEqual(formatted, "2019/05/15 ")
//    }
    
    func testFetchRequestWithMockedManagedObjectContext() {
        
        let mockContext = MockNSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "isEditting")
        fetchRequest.predicate  = NSPredicate(format: "isEditting == %@", "1")
        fetchRequest.fetchLimit = 1
        
        fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType
//        var results: [AnyObject]? = nil
        var results: [AnyObject]?
        do {
            try results = mockContext.fetch(fetchRequest) as [AnyObject]
        } catch {
            results = nil
        }
        XCTAssertEqual(results?.count, 3, "fetch request just only 2")
        
        let result = results![0] as? [String?: String?]
        XCTAssertEqual(result?["title"], "travel1", "title should be travel1")
        XCTAssertEqual(result?["content"], "hello", "content should be hello")
    }

}
class MockNSManagedObjectContext: NSManagedObjectContext {
    override func fetch(_ request: NSFetchRequest<NSFetchRequestResult>) throws -> [Any] {
        return [["isEditting": "1", "title": "travel1", "content": "hello"],
                ["isEditting": "0", "title": "travel2", "content": "weeeee"],
                ["isEditting": "0", "title": "travel3", "content": "yoooo"]]
    }
    
}
