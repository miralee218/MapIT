//
//  PlaceAnnotation.swift
//  MapIT
//
//  Created by Mira on 2019/4/17.
//  Copyright © 2019 AppWork. All rights reserved.
//

import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    var title: String?
    
    var url: URL?
    
    var detailAddress: String?
    
}
