//
//  StoredMapCViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/6.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class StoredMapCViewController: UIViewController {

    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    var travel = [Travel]()
    var long = [Double]()
    var lat = [Double]()

    var startCoordinates: [CLLocationCoordinate2D] = []
    var endCoordinates: [CLLocationCoordinate2D] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        toolBarView.layer.cornerRadius
            = 10.0
        tableView.separatorStyle = .none
        tableView.mr_registerCellWithNib(identifier: String(describing: EditArticleTableViewCell.self), bundle: nil)
        tableView.mr_registerCellWithNib(identifier: String(describing: MapTableViewCell.self), bundle: nil)

        getTravel()
    }

    @IBAction func cancelStore(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func store(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)

    }
    func getTravel() {
        //Core Data - Fetch Data
        let fetchRequest: NSFetchRequest<Travel> = Travel.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Travel.timestamp), ascending: false)]
        do {
            let travel = try CoreDataStack.context.fetch(fetchRequest)
            self.travel = travel
        } catch {

        }
    }

    private func mapRegion(mapView: MKMapView) -> MKCoordinateRegion? {
        guard
            let locations = travel.first?.locations,
            locations.count > 0
            else {
                return nil
        }
        let startLatitudes = locations.map { location -> Double in
            guard let location = location as? ShortRoute else { return 0.0 }
            lat.append(location.start!.latitude)
            return location.start!.latitude
        }
        let startLongitudes = locations.map { location -> Double in
            guard let location = location as? ShortRoute else { return 0.0 }
            long.append(location.self.start!.longitude)
            return location.start!.longitude
        }
        let maxLat = startLatitudes.max()!
        let minLat = startLatitudes.min()!
        let maxLong = startLongitudes.max()!
        let minLong = startLongitudes.min()!

        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                            longitude: (minLong + maxLong) / 2)

        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 4,
                                    longitudeDelta: (maxLong - minLong) * 4)
        return MKCoordinateRegion(center: center, span: span)

    }
    private func loadMap(mapView: MKMapView) {
        guard
            let locations = travel.first?.locations,
            locations.count > 0,
            let region = mapRegion(mapView: mapView)
            else {
                let alert = UIAlertController(title: "Error",
                                              message: "Sorry, this run has no locations saved",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                present(alert, animated: true)
                return
        }

        var startCoordinates = locations.map { coordinate -> CLLocationCoordinate2D in
            guard let location = coordinate as? ShortRoute else {return CLLocationCoordinate2D()}
            let coordinate = CLLocationCoordinate2D(
                latitude: location.start!.latitude,
                longitude: location.start!.longitude)
            self.startCoordinates.append(coordinate)
            return coordinate
        }

        var endCoordinates = locations.map { coordinate -> CLLocationCoordinate2D in
            guard let location = coordinate as? ShortRoute else {return CLLocationCoordinate2D()}
            let coordinate = CLLocationCoordinate2D(
                latitude: location.end!.latitude,
                longitude: location.start!.longitude)
            self.endCoordinates.append(coordinate)
            return coordinate
        }
        for coordinate in 0...startCoordinates.count - 1 {

            let coordinates = [startCoordinates[coordinate], endCoordinates[coordinate]]

            mapView.addOverlay(MKPolyline(coordinates: coordinates, count: 2))

        }

        mapView.setRegion(region, animated: true)
    }
}
struct Coord {
    let latitude: Double
    let longitude: Double
}

extension StoredMapCViewController: UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch  indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: MapTableViewCell.self),
                for: indexPath
            )
            guard let mapCell = cell as? MapTableViewCell else { return cell }
            mapCell.mapView.delegate = self
            mapCell.mapView.isZoomEnabled = true
            mapCell.mapView.isScrollEnabled = true
            loadMap(mapView: mapCell.mapView)
            return mapCell

        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: EditArticleTableViewCell.self),
                for: indexPath
            )
            return cell
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 400
        case 1:
            return UITableView.automaticDimension
        default:
            return 0
        }
    }
}

// MARK: - Map View Delegate

extension StoredMapCViewController {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 10
        return renderer
    }
}
