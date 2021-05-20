//
//  Circle.swift
//  DJIGeoSample
//
//  Created by Samuel Scherer on 5/6/21.
//  Copyright © 2021 DJI. All rights reserved.
//

import Foundation
import MapKit

class Circle : MKCircle {
     var strokeColor : UIColor?
     var fillColor : UIColor?
     var lineWidth : Float = 1.0 //TODO: Reconsider initial value
}
