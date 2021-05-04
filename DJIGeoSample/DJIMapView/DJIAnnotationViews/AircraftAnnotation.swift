//
//  AircraftAnnotation.swift
//  DJIGeoSample
//
//  Created by Samuel Scherer on 5/4/21.
//  Copyright © 2021 DJI. All rights reserved.
//

import Foundation
import MapKit

class AircraftAnnotation : NSObject, MKAnnotation {
    var coordinate : CLLocationCoordinate2D//TODO: readonly vars in swift? public but not open?
    var annotationView : AircraftAnnotationView?
    
    @objc init(coordinate:CLLocationCoordinate2D, heading:CGFloat) {//TODO: use Float for heading...
        self.coordinate = coordinate
        self.annotationView?.update(heading: Float(heading))
        super.init()
    }
}
