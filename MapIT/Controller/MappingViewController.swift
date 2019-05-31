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
import CoreData

class MappingViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var buttonView: MapOptionalButtonView!

    @IBOutlet weak var puaseShadowView: UIView!

    @IBOutlet weak var authorizationView: UIView!
    
    let locationManager = CLLocationManager()

    //route
    private var locationList: [ShortRoute] = []
    var initLoaction: CLLocation?
    var travel: Travel?
    var isEditting: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarColor(self.navigationController)
        setUserTrackingButton()
        addNotificationCenter()
        
        buttonView.addRecordButton.addTarget(nil, action: #selector(addNewRecord), for: .touchUpInside)
        buttonView.checkInButton.addTarget(nil, action: #selector(checkInLocation), for: .touchUpInside)
        buttonView.pauseButton.addTarget(nil, action: #selector(pauseRecord), for: .touchUpInside)
        buttonView.listRecordButton.addTarget(nil, action: #selector(listRecord), for: .touchUpInside)
        buttonView.stopButton.addTarget(nil, action: #selector(toSaveRecord), for: .touchUpInside)
        
    }
    func setUserTrackingButton() {
        let button = MKUserTrackingButton(mapView: mapView)
        button.tintColor = UIColor.StartPink
        button.backgroundColor = UIColor.white
        button.frame = CGRect(origin: CGPoint(x: 16, y: 25), size: CGSize(width: 40, height: 40))
        self.mapView.addSubview(button)
    }
    func addNotificationCenter() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(newTravel),
                                               name: Notification.Name.newTravel,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(addAnnotations),
                                               name: Notification.Name.addAnnotations,
                                               object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (isEditting, travel) = MapManager.checkEditStatusAndGetCurrentTravel()
        authorizationView.isHidden = true
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.pausesLocationUpdatesAutomatically = false
        MapManager.addAnnotations(on: mapView, travel: self.travel)
        reloadView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.showsUserLocation = true
        locationService()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.travel?.locations = NSOrderedSet(array: locationList)
//        CoreDataStack.saveContext()
        NotificationCenter.default.removeObserver(self, name: .newTravel, object: nil)
        NotificationCenter.default.removeObserver(self, name: .addAnnotations, object: nil)
        
    }
    @objc func newTravel() {
        
        reloadView()
        let pullUpController = makeSearchViewControllerIfNeeded()
        removePullUpController(pullUpController, animated: true)
        isViewList = false
        mapView.removeOverlays(self.mapView.overlays)
        locationManager.stopUpdatingLocation()
        locationList.removeAll()
        MapManager.removeAnnotations(on: mapView)
        self.puaseShadowView.isHidden = true
        buttonView.pauseButton.setImage(UIImage(named: ImageAsset.Icons_Puase.rawValue)!, for: .normal)
    }
    @objc func addAnnotations(_ notification: NSNotification) {
        MapManager.addAnnotations(on: mapView, travel: self.travel)
    }

    func reloadView() {
        (isEditting, travel) = MapManager.checkEditStatusAndGetCurrentTravel()
        buttonView.checkInButton.alpha = 0
        buttonView.listRecordButton.alpha = 0
        buttonView.pauseButton.alpha = 0
        buttonView.stopButton.alpha = 0
        changeWithEditStatus()
        buttonView.moreOptionButton.setImage(UIImage(named: ImageAsset.Icons_StartRecord.rawValue), for: .normal)
    }
    func changeWithEditStatus() {
        if self.isEditting == true {
            if self.puaseShadowView.isHidden == true {
                MRProgressHUD.coutinueRecord(view: self.view)
            }
            buttonView.addRecordButton.alpha = 0
            buttonView.moreOptionButton.alpha = 1
            locationManager.startUpdatingLocation()
            MapManager.addOverlaysAll(mapView: mapView, travel: travel)
        } else {
            buttonView.addRecordButton.alpha = 1
            buttonView.moreOptionButton.alpha = 0
            MapManager.removeAnnotations(on: mapView)
            locationManager.stopUpdatingLocation()
        }
    }
    private func addPullUpController() {
        let pullUpController = makeSearchViewControllerIfNeeded()
        _ = pullUpController.view // call pullUpController.viewDidLoad()
        addPullUpController(pullUpController,
                            initialStickyPointOffset: pullUpController.initialPointOffset,
                            animated: true)

    }

    func locationService() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
        changeWithEditStatus()
        DispatchQueue.main.async {
            self.mapView.delegate = self
            self.mapView.mapType = .standard
            self.mapView.userTrackingMode = MKUserTrackingMode.follow
            self.mapView.isZoomEnabled = true
            self.mapView.isScrollEnabled = true
            self.mapView.showsUserLocation = true
            self.mapView.showsCompass = false
            if let coor = self.mapView.userLocation.location?.coordinate {
                self.mapView.setCenter(coor, animated: true)
            }
        }

        locationManager.startUpdatingHeading()
    }
    @objc func addNewRecord() {
        MRProgressHUD.startRecord(view: self.view)
        buttonView.addRecordButton.alpha = 0
        buttonView.moreOptionButton.alpha = 1
        startNewRun()
        locationManager.startUpdatingLocation()
    }

    private func startNewRun() {
        locationList.removeAll()
        initLoaction = nil
        
        startLocationUpdates()
        
        let newTravel = Travel(context: CoreDataManager.shared.viewContext)
        newTravel.createTimestamp = Date()
        newTravel.isEditting = true

        CoreDataManager.shared.saveContext()
        self.travel = newTravel
    }
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
    }
    @objc func checkInLocation() {
        if let vc = storyboard?.instantiateViewController(
            withIdentifier: "AddLocationCViewController") as? AddLocationCViewController {
            vc.mapView = self.mapView
            vc.travel = self.travel
            present(vc, animated: true, completion: nil)
        }
    }
    @objc func pauseRecord() {

        if buttonView.pauseButton.currentImage == UIImage(named: ImageAsset.Icons_Puase.rawValue)! {
            self.initLoaction = nil
            self.puaseShadowView.isHidden = false
            MRProgressHUD.puase(view: self.puaseShadowView)
            buttonView.pauseButton.setImage(UIImage(named: ImageAsset.Icons_Play.rawValue)!, for: .normal)
            locationManager.stopUpdatingLocation()
        } else {
            self.puaseShadowView.isHidden = true
            buttonView.pauseButton.setImage(UIImage(named: ImageAsset.Icons_Puase.rawValue)!, for: .normal)
            startLocationUpdates()
            locationManager.startUpdatingLocation()
        }
    }
    var isViewList = false
    @objc func listRecord() {
        if isViewList == false {
            addPullUpController()
            isViewList = true
        } else {
            let pullUpController = makeSearchViewControllerIfNeeded()
            removePullUpController(pullUpController, animated: true)
            isViewList = false
        }
    }
    @objc func toSaveRecord() {
        self.saveRun()

        if let vc = storyboard?.instantiateViewController(
            withIdentifier: "StoredMapCViewController") as? StoredMapCViewController {
            vc.travel = self.travel
            present(vc, animated: true, completion: nil)
        }
    }
    @IBAction func setAuthorizaiton(_ sender: UIButton) {
        if CLLocationManager.authorizationStatus() != .denied {
        } else {
            let alertController = UIAlertController(title: "定位請求",
                                                    message: "定位服務尚未啟用，請允許取用位置，以便紀錄您的旅行蹤跡。",
                                                    preferredStyle: .alert)
            let denyAction = UIAlertAction(title: "暫不啟用", style: .cancel) { _ in
            }
            let setAction = UIAlertAction(title: "立即設定", style: .default) { _ in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        self.authorizationView.isHidden = true
                    })
                }
            }
            alertController.addAction(denyAction)
            alertController.addAction(setAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    private func saveRun() {

        self.travel?.endTimestamp = Date()
        self.travel?.locations = NSOrderedSet(array: locationList)
        CoreDataManager.shared.saveContext()

        reloadView()
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
        pullUpController.travel = self.travel
        return pullUpController
    }
    // MARK: - CLLocationManager Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        authorizationView.isHidden = true

        guard locations[0].horizontalAccuracy < 20 else {
            return
        }

        guard let start = initLoaction else {

            return initLoaction = locations.first
        }

        guard let end = locations.last else {

            return
        }

        if end.distance(from: start) > 10 {

            let coordinates = [start.coordinate, end.coordinate]

            mapView.addOverlay(MKPolyline(coordinates: coordinates, count: 2))

            let region = MKCoordinateRegion(center: end.coordinate,
                                            latitudinalMeters: 500,
                                            longitudinalMeters: 500)

            let date = Date()

            let mira = ShortRoute(context: CoreDataManager.shared.viewContext)

            let startLocation = Location(context: CoreDataManager.shared.viewContext)

            startLocation.latitude = start.coordinate.latitude

            startLocation.longitude = start.coordinate.longitude

            startLocation.timestamp = date

            let endLocation = Location(context: CoreDataManager.shared.viewContext)

            endLocation.latitude = end.coordinate.latitude

            endLocation.longitude = end.coordinate.longitude

            endLocation.timestamp = date

            mira.start = startLocation

            mira.end = endLocation

            locationList.append(mira)

            initLoaction = end

            mapView.setRegion(region, animated: true)

            self.travel?.locations = NSOrderedSet(array: locationList)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        authorizationView.isHidden = false
    }
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        authorizationView.isHidden = true
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            authorizationView.isHidden = false
        case .authorizedAlways:
            authorizationView.isHidden = true
            locationService()
            changeWithEditStatus()
        case .notDetermined, .authorizedWhenInUse :
            break
        @unknown default:
            fatalError()
        }
    }

}

extension MappingViewController {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return MapManager.setPolylineStyle(mapView: mapView, overlay: overlay)
    }
}
