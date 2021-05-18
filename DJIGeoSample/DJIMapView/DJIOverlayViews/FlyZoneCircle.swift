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
    @objc public var flyZoneCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)//TODO: use optional?
    //@property (nonatomic, assign) CGFloat flyZoneRadius;
    @objc public var flyZoneRadius : CGFloat = 0.0 //TODO: use Optional?
    //@property (nonatomic, assign) uint8_t category;
    @objc public var category : DJIFlyZoneCategory = DJIFlyZoneCategory.unknown
    //@property (nonatomic, assign) NSUInteger flyZoneID;
    @objc public var flyZoneID : UInt = 0
    //@property (nonatomic, copy) NSString* name;
    @objc public var name : String?
    //@property (nonatomic, assign) CGFloat limitHeight
    @objc public var limitHeight : CGFloat = 0.0//TODO: rename to heightLimit
}
