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
    var sortedLocationPost: [LocationPost]?
    var changePositionHandler: ((CLLocationCoordinate2D) -> Void)?
    var originalPositionHandler: (() -> Void)?

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
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapNavBar))
        self.navigationController?.navigationBar.addGestureRecognizer(tap)
    }
    @objc func didTapNavBar() {
        originalPositionHandler?()
    }
    @IBAction func articleMoreButton(_ sender: UIBarButtonItem) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let option3 = UIAlertAction(title: "編輯旅程內容", style: .default) { [weak self] (_) in

            let vc = UIStoryboard.mapping.instantiateViewController(
                withIdentifier: String(describing: EditTravelCViewController.self))

            guard let editTravelVC = vc as? EditTravelCViewController else { return }
            editTravelVC.saveHandler = {
                self?.navigationItem.title = self?.travel?.title
                self?.tableView.reloadData()
            }
            editTravelVC.travel = self?.travel
            self?.present(editTravelVC, animated: true, completion: nil)

        }
        let option1 = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        sheet.addAction(option3)
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

        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 2,
                                    longitudeDelta: (maxLong - minLong) * 2)
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
                longitude: location.end!.longitude)
            self.endCoordinates.append(coordinate)
            return coordinate
        }
        for coordinate in 0...startCoordinates.count - 1 {

            let coordinates = [startCoordinates[coordinate], endCoordinates[coordinate]]

            mapView.addOverlay(MKPolyline(coordinates: coordinates, count: 2))

        }

        mapView.setRegion(region, animated: true)
    }
    func addAnnotation(mapView: MKMapView) {
        guard
            let locationPost = self.travel?.locationPosts,
            locationPost.count > 0 else {
                return
        }
        let coordinates = locationPost.map { coordinate -> CLLocationCoordinate2D in
            guard let locaitonPost = coordinate as? LocationPost else {
                return CLLocationCoordinate2D()
            }
            let coordinate = CLLocationCoordinate2D(
                latitude: locaitonPost.latitude, longitude: locaitonPost.longitude)
            return coordinate
        }
        var pointAnnotations = [MKPointAnnotation]()
        for coordinate in coordinates {
            let point = MKPointAnnotation()
            point.coordinate = coordinate
//            point.title = "\(coordinate.latitude), \(coordinate.longitude)"
            pointAnnotations.append(point)
        }
        mapView.addAnnotations(pointAnnotations)
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
            mapCell.mapView.removeAnnotations(mapCell.mapView.annotations)
            addAnnotation(mapView: mapCell.mapView)
            originalPositionHandler = {[weak self] in
                self?.loadMap(mapView: mapCell.mapView)
                self?.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            }
            changePositionHandler = { [weak self] coordinate in
                let region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.0025, longitudeDelta: 0.0025))
                mapCell.mapView.setRegion(region, animated: true)
                self?.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            }
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: RecordDescriptionTableViewCell.self),
                for: indexPath
            )
            guard let recordCell = cell as? RecordDescriptionTableViewCell else { return cell }

            recordCell.travelContentLabel.text = self.travel?.content
            recordCell.selectionStyle = .none
            return recordCell
        case 2:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: RouteTableViewCell.self),
                for: indexPath
            )
            //sort LocationPost by timestamp
            let sortDate = NSSortDescriptor.init(key: "timestamp", ascending: true)
            guard let sortedLocationPost = travel?.locationPosts?.sortedArray(
                using: [sortDate]) as? [LocationPost] else {
                return cell
            }
            self.sortedLocationPost = sortedLocationPost

            guard let routeCell = cell as? RouteTableViewCell else { return cell }

            routeCell.actionBlock = { [weak self] in

                let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

                let option4 = UIAlertAction(title: "地圖導航", style: .default) { (_) in
                    print("To Apple Map")
                    let lat = sortedLocationPost[indexPath.row].latitude
                    let long = sortedLocationPost[indexPath.row].longitude
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    let targetPlacemark = MKPlacemark(coordinate: coordinate)
                    let targetItem = MKMapItem(placemark: targetPlacemark)
                    let userMapItem = MKMapItem.forCurrentLocation()
                    let routes = [userMapItem, targetItem]

                    MKMapItem.openMaps(
                        with: routes,
                        launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsShowsTrafficKey: true])
                }

                let option3 = UIAlertAction(title: "編輯", style: .default) { [weak self] (_) in

                    let vc = UIStoryboard.mapping.instantiateViewController(
                        withIdentifier: String(describing: EditLocationCViewController.self))

                    guard let editVC = vc as? EditLocationCViewController else { return }

                    editVC.saveHandler = {

                        self?.tableView.reloadData()
                    }

                    editVC.seletedPost = self?.sortedLocationPost?[indexPath.row]
                    self?.present(editVC, animated: true, completion: nil)
                }

                let option2 = UIAlertAction(title: "刪除", style: .destructive) { (_) in
                    guard let removeOrder = self?.sortedLocationPost?[indexPath.row] else { return }
                    CoreDataStack.delete(removeOrder)

                    self?.sortedLocationPost?.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
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
            routeCell.pointTitleLabel.text = sortedLocationPost[indexPath.row].title
            routeCell.pointDescriptionLabel.text = sortedLocationPost[indexPath.row].content

            guard let currentLocationPost = self.sortedLocationPost?[indexPath.row] else {
                return cell
            }
            print(currentLocationPost.photo?.count)

            if currentLocationPost.photo?.count == nil {
                routeCell.collectionView.isHidden = true
            }
            routeCell.locationPost = currentLocationPost
            let formattedDate = FormatDisplay.postDate(sortedLocationPost[indexPath.row].timestamp)
            routeCell.pointRecordTimeLabel.text = formattedDate
            return routeCell

        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 350
        case 1:
            return UITableView.automaticDimension
        case 2:
            guard (sortedLocationPost?[indexPath.row].photo?.count) != nil else {
                return 100
            }

            return 195
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.section {
        case 0:
            return
        case 1:
            originalPositionHandler?()
            return
        case 2:
            guard let lat = sortedLocationPost?[indexPath.row].latitude,
                let long = sortedLocationPost?[indexPath.row].longitude else {
                return
            }
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            changePositionHandler?(coordinate)
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            return
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
