//
//  MapSearchViewController.swift
//  MapIT
//
//  Created by Mira on 2019/5/9.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapSearchViewController: UIViewController, CLLocationManagerDelegate {

    var places: [MKMapItem] = []
    var mapItemList: [MKMapItem] = []
    let params: [String] = ["bar", "shop", "restaurant", "cinema"]
    var mapView = MKMapView()
    var center = CLLocationCoordinate2D()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    func nearByLocation(region: MKCoordinateRegion, collectionView: UICollectionView) {
        let request = MKLocalSearch.Request()
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
    func shareContentOfWholeTravel(with tableView: UITableView?) {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: (tableView?.contentSize.width)!,
                                                      height: (tableView?.contentSize.height)!),
                                               false,
                                               0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.interpolationQuality = .high
        let previousFrame = tableView?.frame
        tableView?.frame = CGRect(x: (tableView?.frame.origin.x)!,
                                  y: (tableView?.frame.origin.y)!,
                                  width: (tableView?.contentSize.width)!,
                                  height: (tableView?.contentSize.height)!)
        tableView?.layer.render(in: context!)
        tableView?.frame = previousFrame!
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = {
            (activityType: UIActivity.ActivityType?,
            completed: Bool,
            returnedItems: [Any]?,
            error: Error?) in
            if error != nil {
                MiraMessage.shareFail()
                return
            }
            if completed {
                MiraMessage.shareSuccess()
            }
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
}
