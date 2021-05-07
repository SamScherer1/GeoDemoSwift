//
//  FlyZoneCircle.swift
//  DJIGeoSample
//
//  Created by Samuel Scherer on 5/6/21.
//  Copyright © 2021 DJI. All rights reserved.
//

import Foundation
import MapKit


class FlyZoneCircle : MKCircle {
    //@property (nonatomic, assign) CLLocationCoordinate2D flyZoneCoordinate;
    var flyZoneCoordinate : CLLocationCoordinate2D?
    //@property (nonatomic, assign) CGFloat flyZoneRadius;
    var flyZoneRadius : CGFloat?
    //@property (nonatomic, assign) uint8_t category;
    var category : UInt8 = 0
    //@property (nonatomic, assign) NSUInteger flyZoneID;
    var flyZoneID : UInt = 0
    //@property (nonatomic, copy) NSString* name;
    var name : String?
    //@property (nonatomic, assign) CGFloat limitHeight
    var limitHeight : CGFloat = 0.0//TODO: rename to heightLimit
}
