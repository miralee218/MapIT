//
//  MapITTests.swift
//  MapITTests
//
//  Created by Mira on 2019/5/13.
//  Copyright © 2019 AppWork. All rights reserved.
//

import XCTest
import MapKit
@testable import MapIT

class MapITTests: XCTestCase {
    var mapManager: MapManager!
    let mapView = MKMapView()

    func testAdd() {
        let result = MapManager.addTest(xxx: 2, yyy: 2)
        XCTAssert(result == 4)
    }
//    func test_PolylineStyle() {
//        let annotations = MapManager.addAnnotations(on: mapView, travel: <#T##Travel?#>)
//    }
//
//    func testControllerAddsAnnotationsToMapView() {
//
//
//        XCTAssertGreaterThan(annotationsOnMap.count, 0)
//    }

}
