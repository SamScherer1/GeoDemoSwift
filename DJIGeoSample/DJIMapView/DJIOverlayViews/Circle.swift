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
    @objc var strokeColor : UIColor?
    @objc var fillColor : UIColor?
    @objc var lineWidth = 1.0 //TODO: Reconsider initial value
}
