//
//  MapManager.swift
//  MapIT
//
//  Created by Mira on 2019/5/9.
//  Copyright © 2019 AppWork. All rights reserved.
//

import Foundation
import MapKit

class MapManager {
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
    static func setMapRegion(mapView: MKMapView, travel: Travel?) -> MKCoordinateRegion? {
        guard let locations = travel?.locations, locations.count > 0 else {
            return nil
        }
        let startLatitudes = locations.map { location -> Double in
            guard let location = location as? ShortRoute else { return 0.0 }
            return location.start!.latitude
        }
        let startLongitudes = locations.map { location -> Double in
            guard let location = location as? ShortRoute else { return 0.0 }
            return location.start!.longitude
        }
        let maxLat = startLatitudes.max()!
        let minLat = startLatitudes.min()!
        let maxLong = startLongitudes.max()!
        let minLong = startLongitudes.min()!
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                            longitude: (minLong + maxLong) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 2,
                                    longitudeDelta: (maxLong - minLong) * 2)
        return MKCoordinateRegion(center: center, span: span)
    }
    static func addOverlays(mapView: MKMapView, travel: Travel?) {
        guard let locations = travel?.locations, locations.count > 0,
            let region = setMapRegion(mapView: mapView, travel: travel) else {
                return
        }
        var startCoordinates = locations.map { coordinate -> CLLocationCoordinate2D in
            guard let location = coordinate as? ShortRoute else {return CLLocationCoordinate2D()}
            let coordinate = CLLocationCoordinate2D(
                latitude: location.start!.latitude,
                longitude: location.start!.longitude)
            return coordinate
        }
        var endCoordinates = locations.map { coordinate -> CLLocationCoordinate2D in
            guard let location = coordinate as? ShortRoute else {return CLLocationCoordinate2D()}
            let coordinate = CLLocationCoordinate2D(
                latitude: location.end!.latitude,
                longitude: location.end!.longitude)
            return coordinate
        }
        for coordinate in 0...startCoordinates.count - 1 {
            let coordinates = [startCoordinates[coordinate], endCoordinates[coordinate]]
            mapView.addOverlay(MKPolyline(coordinates: coordinates, count: 2))
        }
        mapView.setRegion(region, animated: true)
        
    }
    static func viewNearByLocationName(mapView: MKMapView,
                                       collectionView: UICollectionView) -> [MKMapItem] {
        let keywords: [String] = ["bar", "shop", "restaurant", "cinema"]
        var mapItemList: [MKMapItem] = []
        var places: [MKMapItem] = []
        let searchRequest = MKLocalSearch.Request()
        searchRequest.region = mapView.region
        for place in keywords {
            searchRequest.naturalLanguageQuery = place
            let search = MKLocalSearch(request: searchRequest)
            search.start { response, _ in
                guard let response = response else {
                    return
                }
                mapItemList = response.mapItems.shuffled()
                for item in mapItemList {
                    places.append(item)
                }
            }
        }
        collectionView.reloadData()
        return places
    }

}
class NearByLocation {
}
