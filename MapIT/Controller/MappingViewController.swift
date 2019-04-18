//
//  MappingViewController.swift
//  MapIT
//
//  Created by Mira on 2019/4/3.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import MBProgressHUD
import PullUpController

class MappingViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var puaseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var checkListButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!

    @IBOutlet weak var puaseShadowView: UIView!

    let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var checkInButtonCenter: CGPoint!
    var puaseButtonCenter: CGPoint!
    var stopButtonCenter: CGPoint!
    var checkListButtonCenter: CGPoint!
    var places: [MKMapItem] = []
    var mapItemList: [MKMapItem] = []
    let params: [String] = ["bar", "shop", "restaurant", "cinema"]
    override func viewDidLoad() {
        super.viewDidLoad()

        checkInButtonCenter = checkInButton.center
        puaseButtonCenter = puaseButton.center
        stopButtonCenter = stopButton.center
        checkListButtonCenter = checkListButton.center

        checkInButton.center = moreButton.center
        puaseButton.center = moreButton.center
        stopButton.center = moreButton.center
        checkListButton.center = moreButton.center
        locationService()

        setupLayout()
        //back current location

        let buttonItem = MKUserTrackingButton(mapView: mapView)
        buttonItem.tintColor = UIColor.StartPink
        buttonItem.backgroundColor = UIColor.white
        buttonItem.frame = CGRect(origin: CGPoint(x: 16, y: 25), size: CGSize(width: 40, height: 40))

        mapView.addSubview(buttonItem)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        mapView.showsUserLocation = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        mapView.showsUserLocation = false
        self.places.removeAll()
    }

    private func addPullUpController() {
        let pullUpController = makeSearchViewControllerIfNeeded()
        _ = pullUpController.view // call pullUpController.viewDidLoad()
        addPullUpController(pullUpController,
                            initialStickyPointOffset: pullUpController.initialPointOffset,
                            animated: true)

    }

    func locationService() {

        if CLLocationManager.locationServicesEnabled() == true {

            if CLLocationManager.authorizationStatus() == .restricted ||
                CLLocationManager.authorizationStatus() == .denied ||
                CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
            locationManager.startUpdatingLocation()

        } else {
            print("PLease turn on location services or GPS")
        }
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        if let coor = mapView.userLocation.location?.coordinate {
            mapView.setCenter(coor, animated: true)
        }

    }

    private func setupLayout() {

        navigationController?.navigationBar.setGradientBackground(
            colors: UIColor.mainColor
        )

    }
    func nearByLocation() {
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        for param in params {
            request.naturalLanguageQuery = param
            let search = MKLocalSearch(request: request)
            search.start { [unowned self] response, error in
                guard let response = response else { return }
                self.mapItemList = response.mapItems
                for item in self.mapItemList {
                    let annotation = PlaceAnnotation()
                    annotation.coordinate = item.placemark.location!.coordinate
                    annotation.title = item.name
                    annotation.url = item.url
                    annotation.detailAddress = item.placemark.title
//                    self.mapView!.addAnnotation(annotation)
                    self.places.append(item)
                }
                self.places.shuffle()
            }
        }
    }

    @IBAction func addRecordClick(_ sender: UIButton) {

        MRProgressHUD.startRecord(view: self.view)
        recordButton.alpha = 0
        moreButton.alpha = 1

    }

    @IBAction func moreClicked(_ sender: UIButton) {
        nearByLocation()
        if moreButton.currentImage == UIImage(named: ImageAsset.Icons_StartRecord.rawValue)! {
            UIView.animate(withDuration: 0.3, animations: {
                self.checkInButton.alpha = 1
                self.puaseButton.alpha = 1
                self.stopButton.alpha = 1
                self.checkListButton.alpha = 1

                self.checkInButton.center = self.checkInButtonCenter
                self.puaseButton.center = self.puaseButtonCenter
                self.stopButton.center = self.stopButtonCenter
                self.checkListButton.center = self.checkListButtonCenter
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.checkInButton.alpha = 0
                self.puaseButton.alpha = 0
                self.stopButton.alpha = 0
                self.checkListButton.alpha = 0

                self.checkInButton.center = self.moreButton.center
                self.puaseButton.center = self.moreButton.center
                self.stopButton.center = self.moreButton.center
                self.checkListButton.center = self.moreButton.center
            })

        }
        toggleButton(button: sender, onImage: UIImage(named: ImageAsset.Icons_Mapping_Selected.rawValue
            )!, offImage: UIImage(named: ImageAsset.Icons_StartRecord.rawValue)!)
    }

    @IBAction func checkInClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "AddLocationCViewController", sender: sender)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddLocationCViewController" {
            guard let controller = segue.destination as? AddLocationCViewController else { return }
            controller.places = self.places
        }
    }
    @IBAction func puaseClicked(_ sender: UIButton) {
        if sender.currentImage == UIImage(named: ImageAsset.Icons_Puase.rawValue)! {
            self.puaseShadowView.isHidden = false
            MRProgressHUD.puase(view: self.puaseShadowView)
            sender.setImage(UIImage(named: ImageAsset.Icons_Play.rawValue)!, for: .normal)
        } else {
            self.puaseShadowView.isHidden = true
            sender.setImage(UIImage(named: ImageAsset.Icons_Puase.rawValue)!, for: .normal)
            }
    }
    var isViewList = false
    @IBAction func listClicked(_ sender: UIButton) {
        //        guard
        //            children.filter({ $0 is RecordListCViewController }).count == 1
        //            else { return }
        if isViewList == false {
            addPullUpController()
            isViewList = true
        } else {
            let pullUpController = makeSearchViewControllerIfNeeded()
            removePullUpController(pullUpController, animated: true)
            isViewList = false
        }

    }

    @IBAction func stopClicked(_ sender: UIButton) {

        if let vc = storyboard?.instantiateViewController(
            withIdentifier: "StoredMapCViewController") as? StoredMapCViewController {
            present(vc, animated: true, completion: nil)
        }
    }
    // MARK: - View AddLocationCViewController
    private func makeSearchViewControllerIfNeeded() -> RecordListCViewController {
        let currentPullUpController = children
            .filter({ $0 is RecordListCViewController })
            .first as? RecordListCViewController
        guard let pullUpController: RecordListCViewController =
            currentPullUpController ?? UIStoryboard(
                name: "Mapping", bundle: nil).instantiateViewController(
                    withIdentifier: "RecordListCViewController") as? RecordListCViewController
            else {
                return RecordListCViewController()
        }
        return pullUpController
    }
    // MARK: - CLLocationManager Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
        self.mapView.setRegion(region, animated: true)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }

}

extension MappingViewController {

    func toggleButton(button: UIButton, onImage: UIImage, offImage: UIImage) {
        if button.currentImage == offImage {
            button.setImage(onImage, for: .normal)
        } else {
            button.setImage(offImage, for: .normal)
        }
    }

}
