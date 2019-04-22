//
//  RecordDetailViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/9.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class RecordDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    var travel: Travel?
    lazy var locationPost = travel?.locationPosts?.allObjects as? [LocationPost]
    var long = [Double]()
    var lat = [Double]()
    var startCoordinates: [CLLocationCoordinate2D] = []
    var endCoordinates: [CLLocationCoordinate2D] = []

    override func viewDidLoad() {
        super.viewDidLoad()

       navigationItem.title = travel?.title

        tableView.separatorStyle = .none

        tableView.mr_registerCellWithNib(
            identifier: String(describing: MapTableViewCell.self), bundle: nil)
        tableView.mr_registerCellWithNib(
            identifier: String(describing: RecordDescriptionTableViewCell.self), bundle: nil)
        tableView.mr_registerCellWithNib(
            identifier: String(describing: RouteTableViewCell.self), bundle: nil)

    }

    @IBAction func articleMoreButton(_ sender: UIBarButtonItem) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let option4 = UIAlertAction(title: "地圖導航", style: .default) { (_) in
            print("To Apple Map")
        }

        let option3 = UIAlertAction(title: "編輯旅程內容", style: .default) { [weak self] (_) in

            let vc = UIStoryboard.mapping.instantiateViewController(
                withIdentifier: String(describing: StoredMapCViewController.self))

            self?.present(vc, animated: true, completion: nil)
        }

        let option2 = UIAlertAction(title: "刪除", style: .destructive) { (_) in
            print("YOU HAVE DELETED YOUR RECORD")
        }

        let option1 = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        sheet.addAction(option4)
        sheet.addAction(option3)
        sheet.addAction(option2)
        sheet.addAction(option1)

        self.present(sheet, animated: true, completion: nil)
    }

    private func mapRegion(mapView: MKMapView) -> MKCoordinateRegion? {
        guard
            let locations = travel?.locations,
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
            let locations = travel?.locations,
            locations.count > 0,
            let region = mapRegion(mapView: mapView)
            else {
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

extension RecordDetailViewController: UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            guard let locations = travel?.locationPosts,
            locations.count > 0 else {
                return 0
            }
            return locations.count
        default:
            return 0
        }

    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
        switch indexPath.section {
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

            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: RecordDescriptionTableViewCell.self),
                for: indexPath
            )
            guard let recordCell = cell as? RecordDescriptionTableViewCell else { return cell }

            recordCell.travelContentLabel.text = self.travel?.content

            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: RouteTableViewCell.self),
                for: indexPath
            )

            guard let routeCell = cell as? RouteTableViewCell else { return cell }

            routeCell.actionBlock = { [weak self] in

                let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

                let option4 = UIAlertAction(title: "地圖導航", style: .default) { (_) in
                    print("To Apple Map")
                }

                let option3 = UIAlertAction(title: "編輯", style: .default) { [weak self] (_) in

                    let vc = UIStoryboard.mapping.instantiateViewController(
                        withIdentifier: String(describing: EditLocationCViewController.self))

                    self?.present(vc, animated: true, completion: nil)
                }

                let option2 = UIAlertAction(title: "刪除", style: .destructive) { (_) in
                    guard let removeOrder = self?.locationPost?[indexPath.row] else { return }
                    CoreDataStack.delete(removeOrder)
                    tableView.reloadData()
                    print("YOU HAVE DELETED YOUR RECORD")
                }

                let option1 = UIAlertAction(title: "取消", style: .cancel, handler: nil)

                sheet.addAction(option4)
                sheet.addAction(option3)
                sheet.addAction(option2)
                sheet.addAction(option1)

                self?.present(sheet, animated: true, completion: nil)

            }
            routeCell.pointTitleLabel.text = locationPost?[indexPath.row].title
            routeCell.pointDescriptionLabel.text = locationPost?[indexPath.row].content
            let formattedDate = FormatDisplay.postDate(locationPost?[indexPath.row].timestamp)
            routeCell.pointRecordTimeLabel.text = formattedDate

            return routeCell

        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 420
        case 1:
            return UITableView.automaticDimension
        case 2:
            return 200
        default:
            return 0
        }
    }

}

// MARK: - Map View Delegate

extension RecordDetailViewController {
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
