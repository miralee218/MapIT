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
    
    var checkInButtonCenter: CGPoint!
    var puaseButtonCenter: CGPoint!
    var stopButtonCenter: CGPoint!
    var checkListButtonCenter: CGPoint!
    
    @IBOutlet weak var puaseShadowView: UIView!
    
    
    let locationManager = CLLocationManager()
    
    var lat = Double()
    var lon = Double()
    
    
    //MARK:- View AddLocationCViewController
    private func makeSearchViewControllerIfNeeded() -> RecordListCViewController {
        let currentPullUpController = children
            .filter({ $0 is RecordListCViewController })
            .first as? RecordListCViewController
        let pullUpController: RecordListCViewController = currentPullUpController ?? UIStoryboard(name: "Mapping",bundle: nil).instantiateViewController(withIdentifier: "RecordListCViewController") as! RecordListCViewController

        return pullUpController
    }
    

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
        
        
        setupLayout()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        //back current location
        
        let buttonItem = MKUserTrackingButton(mapView: mapView)
        buttonItem.tintColor = UIColor.StartPink
        buttonItem.backgroundColor = UIColor.white
        buttonItem.frame = CGRect(origin: CGPoint(x:5, y: 25), size: CGSize(width: 40, height: 40))
        
        mapView.addSubview(buttonItem)

        
        
        
        locationService()
        setMapview()
        
        
        


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
            
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied ||  CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        } else {
            print("PLease turn on location services or GPS")
        }
        
    }
    
    //MARK:- CLLocationManager Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
        self.mapView.setRegion(region, animated: true)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "Icons_Mapping_Selected"
        var result = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if result == nil {
            result = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }else {
            result?.annotation = annotation
        }
        result?.canShowCallout = false
        
        let image = UIImage (named: "Icons_Mapping_Selected")
        result?.image = image
        
        return result
    }

    private func setupLayout() {
        
        navigationController?.navigationBar.setGradientBackground(colors: UIColor.mainColor as! [UIColor])
        
    }
    
    @IBAction func addRecordClick(_ sender: UIButton) {
        
        MRProgressHUD.startRecord(view: self.view)
        recordButton.alpha = 0
        moreButton.alpha = 1

    }
    
    @IBAction func moreClicked(_ sender: UIButton) {
        if moreButton.currentImage == UIImage(named: ImageAsset.Icons_StartRecord.rawValue)!{
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
            )! , offImage: UIImage(named: ImageAsset.Icons_StartRecord.rawValue)!)
    }
    
    @IBAction func checkInClicked(_ sender: UIButton) {
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AddLocationCViewController") as? AddLocationCViewController{
            present(vc, animated: true, completion: nil)
        }
    }
    @IBAction func puaseClicked(_ sender: UIButton) {
        if sender.currentImage == UIImage(named: ImageAsset.Icons_Puase.rawValue)!
        {
            self.puaseShadowView.isHidden = false
            MRProgressHUD.puase(view: self.puaseShadowView)
            sender.setImage(UIImage(named: ImageAsset.Icons_Play.rawValue)!, for: .normal)
        } else {
            self.puaseShadowView.isHidden = true
            sender.setImage(UIImage(named: ImageAsset.Icons_Puase.rawValue)!, for: .normal)
            }
    }
    var isViewList = false
    @IBAction func ListClicked(_ sender: UIButton) {
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
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "StoredMapCViewController") as? StoredMapCViewController{
            present(vc, animated: true, completion: nil)
        }
    }
    
}

extension MappingViewController: UIGestureRecognizerDelegate {
    
    func setMapview(){
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureReconizer:)))
        lpgr.minimumPressDuration = 0.1
        lpgr.delaysTouchesBegan = false
        lpgr.delegate = self
        self.mapView.addGestureRecognizer(lpgr)
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        //4
        if gestureReconizer.state != UIGestureRecognizer.State.ended {
            return
        }
        //1
        if gestureReconizer.state != UIGestureRecognizer.State.began {
            //2
            let touchLocation = gestureReconizer.location(in: mapView)
            let locationCoordinate = mapView.convert(touchLocation,toCoordinateFrom: mapView)
            lat = locationCoordinate.latitude
            lon = locationCoordinate.longitude
            print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
            
            //3
            let allAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(allAnnotations)
            
            if lat != 0.0 {
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = lat
                annotation.coordinate.longitude = lon
                
                //delay 0.5s
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    self.mapView.addAnnotation(annotation)
                }
            }
            return
        }
    }
}

extension MappingViewController {
    
    func toggleButton(button: UIButton, onImage: UIImage, offImage: UIImage) {
        if button.currentImage == offImage{
            button.setImage(onImage, for: .normal)
        } else {
            button.setImage(offImage, for: .normal)
        }
    }
    
}

