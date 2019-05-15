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
    let mapView = MKMapView()
    var allTravel: [Travel]?
    
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
    
    func test_formatDisplay_travelDate() {
        // Arrange
        allTravel = MapManager.getAllTravel(noDataAction: {
            }, hadDataAction: {
        })
        let timestamp: Date = (allTravel?.first!.createTimestamp)!
        // Act
        let formatted = FormatDisplay.travelDate(timestamp)
        // Assert
        XCTAssertEqual(formatted, "2019/05/15 ")
    }
    
    func testFetchRequestWithMockedManagedObjectContext() {
        class MockNSManagedObjectContext: NSManagedObjectContext {
            override func fetch(_ request: NSFetchRequest<NSFetchRequestResult>) throws -> [Any] {
                return [["isEditting": "1", "title": "travel1", "content": "hello"],
                        ["isEditting": "0", "title": "travel2", "content": "weeeee"],
                        ["isEditting": "0", "title": "travel3", "content": "yoooo"]]
            }
            
        }
        let mockContext = MockNSManagedObjectContext()

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "isEditting")
        fetchRequest.predicate  = NSPredicate(format: "isEditting == %@", "1")
        fetchRequest.fetchLimit = 1
        
        fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType
        var results: [AnyObject]? = nil
        do {
            try results = mockContext.fetch(fetchRequest) as [AnyObject]
        } catch {
            results = nil
        }
//        XCTAssertEqual(results?.count, 1, "fetch request just only 1")
        
        let result = results![0] as? [String?: String?]
        XCTAssertEqual(result?["title"], "travel1", "title should be travel1")
        XCTAssertEqual(result?["content"], "hello", "content should be hello")
    }

}
