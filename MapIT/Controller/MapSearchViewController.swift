//
//  MapSearchViewController.swift
//  MapIT
//
//  Created by Mira on 2019/5/9.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit
import MapKit

class MapSearchViewController: UIViewController, CLLocationManagerDelegate {

    var places: [MKMapItem] = []
    var mapItemList: [MKMapItem] = []
    let params: [String] = ["bar", "shop", "restaurant", "cinema"]
    var mapView = MKMapView()
    var center = CLLocationCoordinate2D()
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    func nearByLocation(region: MKCoordinateRegion,collectionView: UICollectionView) {
        let request = MKLocalSearch.Request()
//        request.region = MKCoordinateRegion(center: center, latitudinalMeters: 10, longitudinalMeters: 10)
        request.region = region
        for param in params {
            request.naturalLanguageQuery = param
            let search = MKLocalSearch(request: request)
            search.start { [weak self] response, _ in

                guard let strongSelf = self else { return }
                guard let response = response else { return }
                strongSelf.mapItemList = response.mapItems
                for item in strongSelf.mapItemList {
                    strongSelf.places.append(item)
                }
                strongSelf.places.shuffle()
                collectionView.reloadData()
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation: CLLocationCoordinate2D = manager.location?.coordinate else {
            return
        }
        self.center = currentLocation
    }
}
