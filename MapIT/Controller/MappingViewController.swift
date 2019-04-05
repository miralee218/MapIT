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

class MappingViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var puaseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var checkListButton: UIButton!
    
    
    let locationManager = CLLocationManager()
    
    var lat = Double()
    var lon = Double()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        //back current location
        let buttonItem = MKUserTrackingBarButtonItem(mapView: mapView)
        self.navigationItem.rightBarButtonItem = buttonItem
        
        
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
        
        setMapview()
    

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

