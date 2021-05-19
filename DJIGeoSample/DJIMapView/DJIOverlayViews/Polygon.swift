//
//  Polygon.swift
//  DJIGeoSample
//
//  Created by Samuel Scherer on 5/6/21.
//  Copyright © 2021 DJI. All rights reserved.
//

import Foundation
import MapKit
import DJISDK

@objc class Polygon : MKPolygon {
    var level : DJIFlyZoneCategory = DJIFlyZoneCategory.unknown
}
