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
import RSKPlaceholderTextView
import PopupDialog
import SwiftMessages

class StoredMapCViewController: UIViewController {

    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    @IBOutlet weak var travelNameTextField: UITextField!
    @IBOutlet weak var contentTextView: RSKPlaceholderTextView!
    var travel: Travel?
    var long = [Double]()
    var lat = [Double]()
    var deleteHandler: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        contentTextView.placeholder = "旅程描述..."
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.cornerRadius = 4
        contentTextView.layer.borderColor = UIColor.B5?.cgColor

        toolBarView.layer.cornerRadius
            = 10.0
        tableView.separatorStyle = .none
        tableView.mr_registerCellWithNib(identifier: String(describing: MapTableViewCell.self), bundle: nil)
        getEdittingTravel()
    }
    func showDeleteDialog(animated: Bool = true) {
        // Prepare the popup
        let title = "確定捨棄紀錄?"
        let message = "若捨棄，你的心血都白費了喔QAQ"
        // Create the dialog
        let popup = PopupDialog(title: title,
                                message: message,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceUp,
                                tapGestureDismissal: true,
                                panGestureDismissal: true,
                                hideStatusBar: true) {
        }
        // Create first button
        let buttonOne = CancelButton(title: "取消") {
        }
        // Create second button
        let buttonTwo = DestructiveButton(title: "捨棄") { [weak self] in
            self?.deleteHandler?()
        }
        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo])
        // Present dialog
        DispatchQueue.main.async {
            self.present(popup, animated: animated, completion: nil)
        }
    }
    func showNoRouteDialog(animated: Bool = true) {
        let title = "提醒你"
        let message = "這趟旅程未錄製到任何路程喔！你想存還還是可以存啦.."
        let popup = PopupDialog(title: title,
                                message: message,
                                buttonAlignment: .horizontal,
                                transitionStyle: .zoomIn,
                                tapGestureDismissal: true,
                                panGestureDismissal: true,
                                hideStatusBar: true) {
        }
        let buttonOne = DefaultButton(title: "瞭解") {
        }
        popup.addButtons([buttonOne])
        DispatchQueue.main.async {
            self.present(popup, animated: animated, completion: nil)
        }
    }

    @IBAction func deleteStore(_ sender: UIButton) {
        self.showDeleteDialog()
        self.deleteHandler = { [weak self] in
            guard let removeOrder = self?.travel else {
                return
            }
            CoreDataStack.delete(removeOrder)
            MiraMessage.giveUpTravel()
            NotificationCenter.default.post(name: .newTravel, object: nil)
            self?.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func cancelStore(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func store(_ sender: UIButton) {
        saveTravelContent()
        NotificationCenter.default.post(name: .newTravel, object: nil)
        MiraMessage.saveTravel()
        dismiss(animated: true, completion: nil)

    }
    func getEdittingTravel() {
        let fetchRequest: NSFetchRequest<Travel> = Travel.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Travel.createTimestamp), ascending: true)]
        let isEditting = "1"
        fetchRequest.predicate  = NSPredicate(format: "isEditting == %@", isEditting)
        fetchRequest.fetchLimit = 1
        do {
            let context = CoreDataStack.context
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                // no matching object
                print("no present")

            } else if count == 1 {
                // at least one matching object exists
                let edittingTravel = try? context.fetch(fetchRequest).first
                self.travel = edittingTravel
                print("only:\(count) continue editing...")

            } else {
                print("matching items found:\(count)")
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

    }

    func saveTravelContent() {

        self.travel?.isEditting = false
        self.travel?.endTimestamp = Date()
        self.travel?.content = self.contentTextView.text
        self.travel?.title = self.travelNameTextField.text
        CoreDataStack.saveContext()

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
                DispatchQueue.main.async {
                    self.showNoRouteDialog()
                }
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
            pointAnnotations.append(point)
        }
        mapView.addAnnotations(pointAnnotations)
    }
}

extension StoredMapCViewController: UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: MapTableViewCell.self),
            for: indexPath
        )
        guard let mapCell = cell as? MapTableViewCell else { return cell }
        mapCell.mapView.delegate = self
        mapCell.mapView.isZoomEnabled = true
        mapCell.mapView.isScrollEnabled = true
        loadMap(mapView: mapCell.mapView)
        addAnnotation(mapView: mapCell.mapView)
        return mapCell

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.bounds.height / 2
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
