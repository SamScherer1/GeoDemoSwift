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

//#import "DJILimitSpaceOverlay.h"
//#import "DJIPolygon.h"
//#import "DJICircle.h"
//#import "DJIMapPolygon.h"
//#import "DJIFlyZoneCircle.h"
//#import "DJIFlyZoneColorProvider.h"

let kDJILimitFlightSpaceBufferHeight = 5

class LimitSpaceOverlay : DJIMapOverlay {
    
    var limitSpaceInfo : DJIFlyZoneInformation?
    
    init(limitSpaceInfo:DJIFlyZoneInformation) {
        self.limitSpaceInfo = limitSpaceInfo
        super.init()
    }
    
    //TODO: if this only ever returns a single value, why have an array?
    func overlaysFor(aSubFlyZoneSpace:DJISubFlyZoneInformation) -> [MKOverlay]? {
        let isHeightLimit = aSubFlyZoneSpace.maximumFlightHeight > 0 && aSubFlyZoneSpace.maximumFlightHeight < UINT16_MAX
        if aSubFlyZoneSpace.shape == .cylinder {
        //        CLLocationCoordinate2D coordinateInMap = aSpace.center;
        //        DJICircle *circle = [DJICircle circleWithCenterCoordinate:coordinateInMap
        //                                                           radius:aSpace.radius];
        //        circle.lineWidth = [self strokLineWidthWithHeight:aSpace.maximumFlightHeight];
        //        circle.fillColor = [DJIFlyZoneColorProvider getFlyZoneOverlayColorWithCategory:_limitSpaceInfo.category isHeightLimit:isHeightLimit isFill:YES];
        //        circle.strokeColor = [DJIFlyZoneColorProvider getFlyZoneOverlayColorWithCategory:_limitSpaceInfo.category isHeightLimit:isHeightLimit isFill:NO];
        //        return @[circle];
        //
        } else if aSubFlyZoneSpace.shape == .polygon {
        //        if (aSpace.vertices.count <= 0) {
        //            return @[];
        //        }
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
            
        //        DJIMapPolygon *polygon = [DJIMapPolygon polygonWithCoordinates:coordinates count:aSpace.vertices.count];
            //var polygon = MapPolygon(coordinates: coordinates, count: UInt(aSubFlyZoneSpace.vertices.count))
            var polygon = MapPolygon(coordinates: coordinates, count: aSubFlyZoneSpace.vertices.count)
        //        polygon.lineWidth = [self strokLineWidthWithHeight:aSpace.maximumFlightHeight];
            polygon.lineWidth = self.strokeLineWidthWith(height: aSubFlyZoneSpace.maximumFlightHeight)
        //        polygon.strokeColor = [DJIFlyZoneColorProvider getFlyZoneOverlayColorWithCategory:_limitSpaceInfo.category isHeightLimit:isHeightLimit isFill:NO];
            
            //TODO: RESUME HERE!!
            
            //polygon.strokeColor = FlyZoneColorProvider.getFlyZoneOverlayColorWith(category:self.limitSpaceInfo?.category, isHeightLimit:isHeightLimit, isFill:false)
        //        polygon.fillColor = [DJIFlyZoneColorProvider getFlyZoneOverlayColorWithCategory:_limitSpaceInfo.category isHeightLimit:isHeightLimit isFill:YES];;
        //        return @[polygon];
        }
        return nil
    }

    
//- (NSArray<id<MKOverlay>> *)overlysForFlyZoneSpace:(DJIFlyZoneInformation *)aSpace
//{
//    if (!aSpace) {
//        return @[];
//    }
//    if (aSpace.subFlyZones.count <= 0) {
//        CLLocationCoordinate2D coordinateInMap = aSpace.center;
//        CGFloat radius = aSpace.radius;
//        
//        DJIFlyZoneCircle* circle = [DJIFlyZoneCircle circleWithCenterCoordinate:coordinateInMap radius:radius];
//        circle.category = aSpace.category;
//        circle.flyZoneID = aSpace.flyZoneID;
//        circle.name = aSpace.name;
//        circle.limitHeight = 0;
//        return @[circle];
//    } else {
//        NSMutableArray *results = [NSMutableArray array];
//        for (DJISubFlyZoneInformation *aSubSpace in aSpace.subFlyZones) {
//            NSArray *subOverlays = [self overlysForSubFlyZoneSpace:aSubSpace];
//            [results addObjectsFromArray:subOverlays];
//        }
//        
//        return results;
//    }
//    return @[];
//}
//
//- (void)createOverlays
//{
//    self.subOverlays = [NSMutableArray array];
//    NSArray *overlays = [self overlysForFlyZoneSpace:self.limitSpaceInfo];
//    [self.subOverlays addObjectsFromArray:overlays];
//}
    
    func strokeLineWidthWith(height:NSInteger) -> CGFloat {
        //    if (height <= 30 + kDJILimitFlightSpaceBufferHeight) {
        //        return 0;
        //    }
        return 1.0
    }
}
