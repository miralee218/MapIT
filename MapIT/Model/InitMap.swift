//
//  InitMap.swift
//  MapIT
//
//  Created by Mira on 2019/5/7.
//  Copyright © 2019 AppWork. All rights reserved.
//

import Foundation
import MapKit

class InitMap {
    static func addAnnotations(on mapView: MKMapView, travel: Travel?) {
        guard let travel = travel else {
            return
        }
        guard let locationPost = travel.locationPosts else {
            return
        }
        mapView.removeAnnotations(mapView.annotations)
        var pointAnnotations = [MKPointAnnotation]()
        let coordinates = getAllLocationPostCoordinates(from: locationPost)
        for coordinate in coordinates {
            let point = MKPointAnnotation()
            point.coordinate = coordinate
            pointAnnotations.append(point)
        }
        mapView.addAnnotations(pointAnnotations)
    }
    static func removeAnnotations(on mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
    }
    class func getAllLocationPostCoordinates(from locationPost: NSSet) -> [CLLocationCoordinate2D] {
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

    static func setPolylineStyle(mapView: MKMapView, overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let overlayRenderer = MKPolylineRenderer(polyline: polyline)
        overlayRenderer.strokeColor = UIColor.StartPink
        overlayRenderer.alpha = 0.5
        overlayRenderer.lineWidth = 10
        return overlayRenderer
//        let gradientColors = [UIColor.green, UIColor.blue, UIColor.yellow, UIColor.red]
//        let renderer = GradientPathRenderer(polyline: polyline, colors: gradientColors)
//        renderer.lineWidth = 10
//        return renderer
    }
}
