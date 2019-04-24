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

    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var puaseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var checkListButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!

    @IBOutlet weak var puaseShadowView: UIView!

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

    lazy var isEditting = isEdittingTravel()
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
        print(isEditting)

        if isEditting == true {
            MRProgressHUD.coutinueRecord(view: self.view)
            recordButton.alpha = 0
            moreButton.alpha = 1
        } else {
            recordButton.alpha = 1
            moreButton.alpha = 0
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        reloadView()
        mapView.showsUserLocation = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        mapView.showsUserLocation = false

        reloadView()
    }

    func reloadView() {

        self.checkInButton.alpha = 0
        self.puaseButton.alpha = 0
        self.stopButton.alpha = 0
        self.checkListButton.alpha = 0

        self.checkInButton.center = self.moreButton.center
        self.puaseButton.center = self.moreButton.center
        self.stopButton.center = self.moreButton.center
        self.checkListButton.center = self.moreButton.center
        self.moreButton.setImage(UIImage(named: ImageAsset.Icons_StartRecord.rawValue)!, for: .normal)

        if self.travel?.isEditting == true {
            MRProgressHUD.coutinueRecord(view: self.view)
            recordButton.alpha = 0
            moreButton.alpha = 1
        } else {
            recordButton.alpha = 1
            moreButton.alpha = 0
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

        if CLLocationManager.locationServicesEnabled() == true {

            let status = CLLocationManager.authorizationStatus()
            if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
                locationManager.requestAlwaysAuthorization()
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
        mapView.userTrackingMode = MKUserTrackingMode.follow
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        if let coor = mapView.userLocation.location?.coordinate {
            mapView.setCenter(coor, animated: true)
        }
        locationManager.startUpdatingHeading()
        locationManager.stopUpdatingLocation()
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
        DispatchQueue.global().async {
            self.startNewRun()
            self.locationManager.startUpdatingLocation()
        }
//        MRProgressHUD.startRecord(view: self.view)
//        recordButton.alpha = 0
//        moreButton.alpha = 1
//
//        startNewRun()
//        locationManager.startUpdatingLocation()

    }

    func isEdittingTravel() -> Bool {
        let fetchRequest: NSFetchRequest<Travel> = Travel.fetchRequest()
        let isEditting = "1"
        fetchRequest.predicate  = NSPredicate(format: "isEditting == %@", isEditting)
        fetchRequest.fetchLimit = 0
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
        locationManager.stopUpdatingLocation()
        self.initLoaction = nil

        if let vc = storyboard?.instantiateViewController(
            withIdentifier: "StoredMapCViewController") as? StoredMapCViewController {
            present(vc, animated: true, completion: nil)
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

        guard locations[0].horizontalAccuracy < 20 else {
            locationManager.stopUpdatingLocation()
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

            let region = MKCoordinateRegion(center: end.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)

            mapView.setRegion(region, animated: true)

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
        }
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
