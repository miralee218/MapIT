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
import PopupDialog
import SwiftMessages

class RecordDetailViewController: MapSearchViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    var travel: Travel?
    lazy var locationPost = travel?.locationPosts?.allObjects as? [LocationPost]
    var sortedLocationPost: [LocationPost]?
    var changePositionHandler: ((CLLocationCoordinate2D) -> Void)?
    var originalPositionHandler: (() -> Void)?
    var deleteHandler: (() -> Void)?

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
        let shareOption = UIAlertAction(title: "分享旅程", style: .default) { [weak self] (_) in
            self?.shareContentOfWholeTravel(with: self?.tableView)
        }
        let editOption = UIAlertAction(title: "編輯旅程內容", style: .default) { [weak self] (_) in

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
        let cancelOption = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        sheet.addAction(shareOption)
        sheet.addAction(editOption)
        sheet.addAction(cancelOption)

        self.present(sheet, animated: true, completion: nil)
    }
}

extension RecordDetailViewController: UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return RecordDetailSeciton.allCases.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let recordDetailSeciton = RecordDetailSeciton(rawValue: section) else { return 0 }
        switch recordDetailSeciton {
        case .map:
            return 1
        case .description:
            return 1
        case .route:
            guard let locations = travel?.locationPosts,
            locations.count > 0 else {
                return 0
            }
            return locations.count
        }

    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
        guard let recordDetailSeciton = RecordDetailSeciton(rawValue:
            indexPath.section) else {
                return UITableViewCell() }
        switch recordDetailSeciton {
        case .map:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: MapTableViewCell.self),
                for: indexPath
            )
            guard let mapCell = cell as? MapTableViewCell else { return cell }
            mapCell.mapView.delegate = self
            mapCell.mapView.isZoomEnabled = true
            mapCell.mapView.isScrollEnabled = true
            MapManager.addOverlays(mapView: mapCell.mapView, travel: self.travel)
            MapManager.addAnnotations(on: mapCell.mapView, travel: self.travel)
            originalPositionHandler = {[weak self] in
                MapManager.addOverlays(mapView: mapCell.mapView, travel: self?.travel)
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

        case .description:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: RecordDescriptionTableViewCell.self),
                for: indexPath
            )
            guard let recordCell = cell as? RecordDescriptionTableViewCell else { return cell }

            recordCell.travelContentLabel.text = self.travel?.content
            recordCell.selectionStyle = .none
            return recordCell
        case .route:
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
                        launchOptions:
                        [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                         MKLaunchOptionsShowsTrafficKey: true])
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

                let option2 = UIAlertAction(title: "刪除", style: .destructive) {[weak self] _ in
                    guard let strongSelf = self else { return }
                    MiraDialog.showDeleteDialog(animated: true, deleteHandler: { [weak self] in
                        guard let removeOrder = self?.sortedLocationPost?[indexPath.row] else { return }

                        CoreDataManager.shared.delete(removeOrder)
                        self?.sortedLocationPost?.remove(at: indexPath.row)
                        self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                        self?.tableView.reloadData()
                        MiraMessage.deleteSuccessfully()
                        }, vc: strongSelf)
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

            if currentLocationPost.photo?.count == nil {
                routeCell.collectionView.isHidden = true
            }
            routeCell.locationPost = currentLocationPost
            let formattedDate = FormatDisplay.postDate(sortedLocationPost[indexPath.row].timestamp)
            routeCell.pointRecordTimeLabel.text = formattedDate
            return routeCell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let recordDetailSeciton = RecordDetailSeciton(rawValue: indexPath.section) else { return CGFloat.zero}
        switch recordDetailSeciton {
        case .map:
            return 350
        case .description:
            return UITableView.automaticDimension
        case .route:
            guard (sortedLocationPost?[indexPath.row].photo?.count) != nil else {
                return 100
            }
            return 195
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let recordDetailSeciton = RecordDetailSeciton(rawValue: indexPath.section) else { return }
        switch recordDetailSeciton {
        case .map:
            return
        case .description:
            originalPositionHandler?()
            return
        case .route:
            guard let lat = sortedLocationPost?[indexPath.row].latitude,
                let long = sortedLocationPost?[indexPath.row].longitude else {
                return
            }
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            changePositionHandler?(coordinate)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

}

// MARK: - Map View Delegate

extension RecordDetailViewController {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return MapManager.setPolylineStyle(mapView: mapView, overlay: overlay)
    }
}
