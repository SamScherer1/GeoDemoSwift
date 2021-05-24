//
//  MapOverlay.swift
//  DJIGeoSample
//
//  Created by Samuel Scherer on 5/6/21.
//  Copyright © 2021 DJI. All rights reserved.
//

import Foundation
import MapKit

//Subclass NSObject to make MapOverlay Equatable
class MapOverlay: NSObject {
    var subOverlays = [MKOverlay]()
}
