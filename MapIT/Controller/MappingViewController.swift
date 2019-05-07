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

// swiftlint:disable type_body_length
// swiftlint:disable file_length

class MappingViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var puaseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var checkListButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!

    @IBOutlet weak var puaseShadowView: UIView!

    @IBOutlet weak var authorizationView: UIView!
    let locationManager = CLLocationManager()
    var checkInButtonCenter: CGPoint!
    var puaseButtonCenter: CGPoint!
    var stopButtonCenter: CGPoint!
    var checkListButtonCenter: CGPoint!
    //route
    private var locationList: [ShortRoute] = []
    var initLoaction: CLLocation?
    private var locationManagerShared = LocationManager.shared
    var travel: Travel?
    var allCoordinates: [[CLLocationCoordinate2D]] = [[]]
    lazy var locationPost = (travel?.locationPosts?.allObjects as? [LocationPost])

    lazy var isEditting = isEdittingTravel()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        let buttonItem = MKUserTrackingButton(mapView: mapView)
        buttonItem.tintColor = UIColor.StartPink
        buttonItem.backgroundColor = UIColor.white
        buttonItem.frame = CGRect(origin: CGPoint(x: 16, y: 25), size: CGSize(width: 40, height: 40))

        mapView.addSubview(buttonItem)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(newTravel),
                                               name: Notification.Name.newTravel,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(addMark),
                                               name: Notification.Name.addMark,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(removeMark),
                                               name: Notification.Name.removeMark,
                                               object: nil)
        print(isEditting)

    }
    @objc func newTravel() {
        reloadView()
        let pullUpController = makeSearchViewControllerIfNeeded()
        removePullUpController(pullUpController, animated: true)
        isViewList = false
        mapView.removeOverlays(self.mapView.overlays)
        locationManager.stopUpdatingLocation()
        locationList.removeAll()
        mapView.removeAnnotations(self.mapView.annotations)
    }
    @objc func addMark(_ notification: NSNotification) {
        addAnnotation()
    }
    @objc func removeMark(_ notification: NSNotification) {
        mapView.removeAnnotations(mapView.annotations)
        addAnnotation()
    }
    func addAnnotation() {
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        authorizationView.isHidden = true
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        mapView.removeAnnotations(mapView.annotations)
        addAnnotation()
        reloadView()
    }
    private func loadMap(mapView: MKMapView) {
        guard
            let locations = self.travel?.locations,
            locations.count > 0 else {
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
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkInButtonCenter = offset(byDistance: 100, inDirection: 270)
        puaseButtonCenter = offset(byDistance: 100, inDirection: 240)
        checkListButtonCenter = offset(byDistance: 100, inDirection: 210)
        stopButtonCenter = offset(byDistance: 100, inDirection: 180)
        checkInButton.center = recordButton.center
        puaseButton.center = recordButton.center
        checkListButton.center = recordButton.center
        stopButton.center = recordButton.center
        mapView.showsUserLocation = true
        locationService()

    }
    public func offset(byDistance distance: CGFloat, inDirection degrees: CGFloat) -> CGPoint {
        let radians = degrees * .pi / 180
        let vertical = sin(radians) * distance
        let horizontal = cos(radians) * distance
        let position = CGPoint(x: recordButton.center.x + horizontal, y: recordButton.center.y + vertical)
        return position
    }
//    override func viewDidDisappear(_ animated: Bool) {
//        self.viewDidDisappear(true)
//        if self.travel?.isEditting == true {
//            self.travel?.locations = NSOrderedSet(array: locationList)
//
//        } else {
//            locationManager.stopUpdatingLocation()
//        }
//    }

    func reloadView() {
        self.checkInButton.alpha = 0
        self.puaseButton.alpha = 0
        self.stopButton.alpha = 0
        self.checkListButton.alpha = 0
        if self.travel?.isEditting == true {
            MRProgressHUD.coutinueRecord(view: self.view)
            recordButton.alpha = 0
            moreButton.alpha = 1
            loadMap(mapView: mapView)
            locationManager.startUpdatingLocation()
        } else {
            recordButton.alpha = 1
            moreButton.alpha = 0
            mapView.removeAnnotations(mapView.annotations)
            locationManager.stopUpdatingLocation()
        }

        self.moreButton.setImage(UIImage(named: ImageAsset.Icons_StartRecord.rawValue)!, for: .normal)
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
        if self.travel?.isEditting == true {
            MRProgressHUD.coutinueRecord(view: self.view)
            recordButton.alpha = 0
            moreButton.alpha = 1
            locationManager.startUpdatingLocation()
        } else {
            recordButton.alpha = 1
            moreButton.alpha = 0
            mapView.removeAnnotations(mapView.annotations)
            locationManager.stopUpdatingLocation()
        }
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

    private func setupLayout() {

        navigationController?.navigationBar.setGradientBackground(
            colors: UIColor.mainColor
        )

    }

    @IBAction func addRecordClick(_ sender: UIButton) {

        MRProgressHUD.startRecord(view: self.view)
        recordButton.alpha = 0
        moreButton.alpha = 1

        startNewRun()
        locationManager.startUpdatingLocation()

    }

    func isEdittingTravel() -> Bool {
        let fetchRequest: NSFetchRequest<Travel> = Travel.fetchRequest()
        let isEditting = "1"
        fetchRequest.predicate  = NSPredicate(format: "isEditting == %@", isEditting)
        fetchRequest.fetchLimit = 1
        do {
            let context = CoreDataStack.context
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                // no matching object
                print("no present")
                return false
            } else if count == 1 {
                // at least one matching object exists
                let edittingTravel = try? context.fetch(fetchRequest).first
                self.travel = edittingTravel
                print("only:\(count) continue editing...")
                return true
            } else {
                print("matching items found:\(count)")
                return false
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return false
    }
    private func startNewRun() {
        startLocationUpdates()

        let newTravel = Travel(context: CoreDataStack.context)
        newTravel.createTimestamp = Date()
        newTravel.isEditting = true

        CoreDataStack.saveContext()
        travel = newTravel
    }
    private func continueRun() {
        startLocationUpdates()
    }

    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
    }

    @IBAction func moreClicked(_ sender: UIButton) {
        if moreButton.currentImage == UIImage(named: ImageAsset.Icons_StartRecord.rawValue)! {
            UIView.animate(withDuration: 0.15, animations: {
                self.checkInButton.alpha = 1
                self.checkInButton.center = self.checkInButtonCenter
            })
            UIView.animate(withDuration: 0.3, animations: {
                self.puaseButton.alpha = 1
                self.puaseButton.center = self.puaseButtonCenter
            })
            UIView.animate(withDuration: 0.45, animations: {
                self.checkListButton.alpha = 1
                self.checkListButton.center = self.checkListButtonCenter
            })
            UIView.animate(withDuration: 0.6, animations: {

                self.stopButton.alpha = 1
                self.stopButton.center = self.stopButtonCenter

            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.checkInButton.alpha = 0
                self.checkInButton.center = self.recordButton.center
            })
            UIView.animate(withDuration: 0.4, animations: {
                self.puaseButton.alpha = 0
                self.puaseButton.center = self.recordButton.center
            })
            UIView.animate(withDuration: 0.6, animations: {
                self.checkListButton.alpha = 0
                self.checkListButton.center = self.recordButton.center
            })
            UIView.animate(withDuration: 0.8, animations: {
                self.stopButton.alpha = 0
                self.stopButton.center = self.recordButton.center
            })
        }
        toggleButton(button: sender, onImage: UIImage(named: ImageAsset.Icons_Mapping_Selected.rawValue
            )!, offImage: UIImage(named: ImageAsset.Icons_StartRecord.rawValue)!)
    }

    @IBAction func checkInClicked(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(
            withIdentifier: "AddLocationCViewController") as? AddLocationCViewController {
            vc.mapView = self.mapView
            present(vc, animated: true, completion: nil)
        }
    }

    @IBAction func puaseClicked(_ sender: UIButton) {
        if sender.currentImage == UIImage(named: ImageAsset.Icons_Puase.rawValue)! {
            self.puaseShadowView.isHidden = false
            MRProgressHUD.puase(view: self.puaseShadowView)
            sender.setImage(UIImage(named: ImageAsset.Icons_Play.rawValue)!, for: .normal)
            locationManager.stopUpdatingLocation()
            self.initLoaction = nil
        } else {
            self.puaseShadowView.isHidden = true
            sender.setImage(UIImage(named: ImageAsset.Icons_Puase.rawValue)!, for: .normal)
            continueRun()
            locationManager.startUpdatingLocation()
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

        self.saveRun()
        self.initLoaction = nil

        if let vc = storyboard?.instantiateViewController(
            withIdentifier: "StoredMapCViewController") as? StoredMapCViewController {
            present(vc, animated: true, completion: nil)
        }

    }
    @IBAction func setAuthorizaiton(_ sender: UIButton) {
        if CLLocationManager.authorizationStatus() != .denied {
        } else {
            let alertController = UIAlertController(title: "定位請求",
                                                    message: "定位服務尚未啟用，請允許取用位置，以便紀錄您的旅行蹤跡。",
                                                    preferredStyle: .alert)
            let tempAction = UIAlertAction(title: "暫不啟用", style: .cancel) { _ in
            }
            let callAction = UIAlertAction(title: "立即設定", style: .default) { _ in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                        self.authorizationView.isHidden = true
                    })
                }
            }
            alertController.addAction(tempAction)
            alertController.addAction(callAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    private func saveRun() {

        self.travel?.endTimestamp = Date()
        self.travel?.locations = NSOrderedSet(array: locationList)
        CoreDataStack.saveContext()

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

            allCoordinates.append(coordinates)

            mapView.addOverlay(MKPolyline(coordinates: coordinates, count: 2))

            let region = MKCoordinateRegion(center: end.coordinate,
                                            latitudinalMeters: 500,
                                            longitudinalMeters: 500)

            let date = Date()

            let mira = ShortRoute(context: CoreDataStack.context)

            let startLocation = Location(context: CoreDataStack.context)

            startLocation.latitude = start.coordinate.latitude

            startLocation.longitude = start.coordinate.longitude

            startLocation.timestamp = date

            let endLocation = Location(context: CoreDataStack.context)

            endLocation.latitude = end.coordinate.latitude

            endLocation.longitude = end.coordinate.longitude

            endLocation.timestamp = date

            mira.start = startLocation

            mira.end = endLocation

            locationList.append(mira)

            initLoaction = end

            mapView.setRegion(region, animated: true)

        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        authorizationView.isHidden = false
        print("Unable to access your current location")
    }
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        authorizationView.isHidden = true
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            authorizationView.isHidden = false
        case .authorizedWhenInUse, .authorizedAlways:
            authorizationView.isHidden = true
            print("Access")
            locationService()
            if self.travel?.isEditting == true {
                MRProgressHUD.coutinueRecord(view: self.view)
                recordButton.alpha = 0
                moreButton.alpha = 1
                locationManager.startUpdatingLocation()
            } else {
                recordButton.alpha = 1
                moreButton.alpha = 0
            }
        case .notDetermined :
            break
        @unknown default:
            fatalError()
        }
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

extension MappingViewController {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .red
                renderer.lineWidth = 10
                return renderer
//        let gradientColors = [UIColor.green, UIColor.blue, UIColor.yellow, UIColor.red]
//        let renderer = GradientPathRenderer(polyline: polyline, colors: gradientColors)
//        renderer.lineWidth = 10
//        return renderer
    }
}

// swiftlint:enable type_body_length
// swiftlint:enable file_length
