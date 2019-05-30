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
    var isEditting: Bool?
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
        guard let locations = travel?.locations, locations.count > 0 else {
            MiraMessage.noRouteRecord()
            return                                                     
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        (isEditting, travel) = MapManager.checkEditStatusAndGetCurrentTravel()
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
    @IBAction func deleteStore(_ sender: UIButton) {
        self.showDeleteDialog()
        self.deleteHandler = { [weak self] in
            guard let removeOrder = self?.travel else {
                return
            }
            CoreDataManager.shared.delete(removeOrder)
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

    func saveTravelContent() {
        self.travel?.isEditting = false
        self.travel?.endTimestamp = Date()
        self.travel?.content = self.contentTextView.text
        
//        if self.travelNameTextField.text == "" {
//            self.travelNameTextField.text = "未命名"
//            self.travel?.title = self.travelNameTextField.text
//        } else {
//            self.travel?.title = self.travelNameTextField.text
//        }

        self.travel?.title = name(inputTextField: &self.travelNameTextField.text)
    
        CoreDataManager.shared.saveContext()

    }
    func name(inputTextField: inout String?) -> String? {
        guard inputTextField != "" else {
            inputTextField = "未命名"
            return inputTextField
        }
        return inputTextField
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
        MapManager.addOverlaysAll(mapView: mapCell.mapView, travel: travel)
        MapManager.addAnnotations(on: mapCell.mapView, travel: travel)
        return mapCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.bounds.height / 2
    }
}

// MARK: - Map View Delegate

extension StoredMapCViewController {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return MapManager.setPolylineStyle(mapView: mapView, overlay: overlay)
    }
}
