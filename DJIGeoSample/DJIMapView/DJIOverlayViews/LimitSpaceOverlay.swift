//
//  LimitSpaceOverlay.swift
//  DJIGeoSample
//
//  Created by Samuel Scherer on 5/6/21.
//  Copyright © 2021 DJI. All rights reserved.
//

import Foundation
import DJISDK
import MapKit

let kDJILimitFlightSpaceBufferHeight = 5

class LimitSpaceOverlay : MapOverlay {
    
    var limitSpaceInfo : DJIFlyZoneInformation?
    
    init(limitSpaceInfo:DJIFlyZoneInformation) {
        self.limitSpaceInfo = limitSpaceInfo
        super.init()
        self.createOverlays()
    }
    
    //TODO: if this only ever returns a single value, why have an array?
    func overlaysFor(aSubFlyZoneSpace:DJISubFlyZoneInformation) -> [MKOverlay] {
        let isHeightLimit = aSubFlyZoneSpace.maximumFlightHeight > 0 && aSubFlyZoneSpace.maximumFlightHeight < UINT16_MAX
        if aSubFlyZoneSpace.shape == .cylinder {
            let circle = Circle(center: aSubFlyZoneSpace.center, radius: aSubFlyZoneSpace.radius)
            circle.lineWidth = self.strokeLineWidthWith(height: aSubFlyZoneSpace.maximumFlightHeight)
            circle.fillColor = FlyZoneColorProvider.getFlyZoneOverlayColorFor(category: self.limitSpaceInfo!.category,
                                                                              isHeightLimit: isHeightLimit,
                                                                              isFill: true)//TODO: reconsider force unwrap
            circle.strokeColor = FlyZoneColorProvider.getFlyZoneOverlayColorFor(category: self.limitSpaceInfo!.category,
                                                                                isHeightLimit: isHeightLimit,
                                                                                isFill: false)
            return [circle]
        } else if aSubFlyZoneSpace.shape == .polygon {
            if aSubFlyZoneSpace.vertices.count <= 0 { return [MKOverlay]() }//TODO: better to return nil here?
//            CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D *)malloc(sizeof(CLLocationCoordinate2D) * aSpace.vertices.count);
            //TODO: dangling pointer?
            var coordinates = UnsafePointer<CLLocationCoordinate2D>(OpaquePointer.init(aSubFlyZoneSpace.vertices))
//
//            int i = 0;
//            for (i = 0; i < aSpace.vertices.count; i++) {
//                NSValue *aPointValue = aSpace.vertices[i];
//                CLLocationCoordinate2D coordinate = [aPointValue MKCoordinateValue];
//                CLLocationCoordinate2D coordinateInMap = coordinate;
//                coordinates[i] = coordinateInMap;
//            }
            
            let polygon = MapPolygon(coordinates: coordinates, count: aSubFlyZoneSpace.vertices.count)
            polygon.lineWidth = self.strokeLineWidthWith(height: aSubFlyZoneSpace.maximumFlightHeight)
            polygon.strokeColor = FlyZoneColorProvider.getFlyZoneOverlayColorFor(category: self.limitSpaceInfo!.category, isHeightLimit: isHeightLimit, isFill: false)//TODO: reconsider force unwrap
            polygon.fillColor = FlyZoneColorProvider.getFlyZoneOverlayColorFor(category: self.limitSpaceInfo!.category, isHeightLimit: isHeightLimit, isFill: true)
            return [polygon]
        }
        return [MKOverlay]()
    }

    func overlaysFor(aFlyZoneSpace:DJIFlyZoneInformation) -> [MKOverlay]? {//TODO: instead of optional return type, return empty array?
        guard let subFlyZones = aFlyZoneSpace.subFlyZones else {
            print("subFlyZones Nil- perhaps should enter the <=0 if check?")
            fatalError()
        }
        
        if subFlyZones.count <= 0 {
            let circle = FlyZoneCircle(center: aFlyZoneSpace.center, radius: aFlyZoneSpace.radius)
            circle.category = aFlyZoneSpace.category
            circle.flyZoneID = aFlyZoneSpace.flyZoneID
            circle.name = aFlyZoneSpace.name
            circle.limitHeight = 0
            return [circle]
        } else {
            //TODO: use map...
            var results = [MKOverlay]()
            for aSubSpace in subFlyZones {
                results.append(contentsOf: self.overlaysFor(aSubFlyZoneSpace: aSubSpace))
            }
            return results
        }
    }

    func createOverlays() {
        self.subOverlays = [MKOverlay]()
        if let overlays = self.overlaysFor(aFlyZoneSpace: self.limitSpaceInfo!) {//TODO:force unwrap
            self.subOverlays.append(contentsOf: overlays)
        }
    }
    
    func strokeLineWidthWith(height:NSInteger) -> Float {
        if height <= (30 + kDJILimitFlightSpaceBufferHeight) {
            return 0.0
        }
        return 1.0
    }
}
