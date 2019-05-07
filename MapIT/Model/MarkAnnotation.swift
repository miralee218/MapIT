//
//  MarkAnnotation.swift
//  MapIT
//
//  Created by Mira on 2019/5/7.
//  Copyright © 2019 AppWork. All rights reserved.
//

import Foundation
import MapKit

class MarkAnnotation {
    static func addAnnotation(mapView: MKMapView, coordinates: [CLLocationCoordinate2D]) {
        //    guard
        //        let locationPost = self.travel?.locationPosts,
        //        locationPost.count > 0 else {
        //            return
        //    }
        //    let coordinates = locationPost.map { coordinate -> CLLocationCoordinate2D in
        //        guard let locaitonPost = coordinate as? LocationPost else {
        //            return CLLocationCoordinate2D()
        //        }
        //        let coordinate = CLLocationCoordinate2D(
        //            latitude: locaitonPost.latitude, longitude: locaitonPost.longitude)
        //        return coordinate
        //    }
        var pointAnnotations = [MKPointAnnotation]()
        for coordinate in coordinates {
            let point = MKPointAnnotation()
            point.coordinate = coordinate
            pointAnnotations.append(point)
        }
        mapView.addAnnotations(pointAnnotations)
    }
    static func getAllLocationPost(locationPost: NSSet) -> [CLLocationCoordinate2D] {
        guard locationPost.count > 0 else {
            return [CLLocationCoordinate2D]()
        }
        let coordinates = locationPost.map { coordinate -> CLLocationCoordinate2D in
            guard let locationPost = coordinate as? LocationPost else {
                return CLLocationCoordinate2D()
            }
            let coordinate = CLLocationCoordinate2D(
                latitude: locationPost.latitude, longitude: locationPost.longitude)
            return coordinate
        }
        return coordinates
    }
}
