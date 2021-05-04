//
//  MapViewController.swift
//  DJIGeoSample
//
//  Created by Samuel Scherer on 5/4/21.
//  Copyright © 2021 DJI. All rights reserved.
//

import Foundation
import UIKit
import MapKit

let kUpdateTimeStamp = 10.0


class MapController : NSObject, MKMapViewDelegate {
    //@property (nonatomic, strong) NSMutableArray *flyZones;
    var flyZones = [Any]()//TODO: specify type?
//    @property (nonatomic) CLLocationCoordinate2D aircraftCoordinate;
    var aircraftCoordinate : CLLocationCoordinate2D
//    @property (weak, nonatomic) MKMapView *mapView;
    var mapView : MKMapView?
//    @property (nonatomic, strong) AircraftAnnotation* aircraftAnnotation;
    var aircraftAnnotation : AircraftAnnotation?
//    @property (nonatomic, strong) NSMutableArray<DJIMapOverlay *> *mapOverlays;
    var mapOverlays = [DJIMapOverlay]()
//    @property (nonatomic, strong) NSMutableArray<DJIMapOverlay *> *customUnlockOverlays;
    var customUnlockOverlays : [DJIMapOverlay]?
//    @property (nonatomic, assign) NSTimeInterval lastUpdateTime;
    var lastUpdateTime : TimeInterval?
    
    init(map:MKMapView) {
        self.aircraftCoordinate = CLLocationCoordinate2DMake(0.0, 0.0)
        self.mapView = map
        
        super.init()
        
        self.mapView?.delegate = self
        //self.forceUpdateFlyZones()
    }
    
    deinit {
        self.aircraftAnnotation = nil
        self.mapView?.delegate = nil
        self.mapView = nil
    }
    
    func updateAircraft(coordinate:CLLocationCoordinate2D, heading:CGFloat) {
    //    if (CLLocationCoordinate2DIsValid(coordinate)) {
    //
    //        self.aircraftCoordinate = coordinate;
    //
    //        if (self.aircraftAnnotation == nil) {
    //            self.aircraftAnnotation =  [[AircraftAnnotation alloc] initWithCoordinate:coordinate heading:heading];
    //            [self.mapView addAnnotation:self.aircraftAnnotation];
    //            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 500, 500);
    //            MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    //            [self.mapView setRegion:adjustedRegion animated:YES];
    //            [self updateFlyZones];
    //        }
    //        else
    //        {
    //            [self.aircraftAnnotation setCoordinate:coordinate];
    //            AircraftAnnotationView *annotationView = (AircraftAnnotationView *)[_mapView viewForAnnotation:self.aircraftAnnotation];
    //            [annotationView updateWithHeading:heading];
    //            [self updateFlyZones];
    //        }
    //
    //    }
    }
    
    //MARK: - MKMapViewDelegate Methods
    
    func viewFor(mapView:MKMapView, annotation:MKAnnotation) -> MKAnnotationView? {
    //
    //    if ([annotation isKindOfClass:[MKUserLocation class]]) {
    //        return nil;
    //    }else if ([annotation isKindOfClass:[AircraftAnnotation class]])
    //    {
    //
    //        static NSString* aircraftReuseIdentifier = @"DJI_AIRCRAFT_ANNOTATION_VIEW";
    //        AircraftAnnotationView* aircraftAnno = (AircraftAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:aircraftReuseIdentifier];
    //        if (aircraftAnno == nil) {
    //            aircraftAnno = [[AircraftAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:aircraftReuseIdentifier];
    //        }
    //
    //        return aircraftAnno;
    //    }
    //
        return nil
    }
    //
    func rendererFor(mapView:MKMapView, overlay:MKOverlay) -> MKOverlayRenderer? {
    //   if ([overlay isKindOfClass:[DJIFlyZoneCircle class]]) {
    //
    //       DJIFlyZoneCircleView* circleView = [[DJIFlyZoneCircleView alloc] initWithCircle:overlay];
    //       return circleView;
    //   }else if([overlay isKindOfClass:[DJIPolygon class]]){
    //       DJIFlyLimitPolygonView *polygonRender = [[DJIFlyLimitPolygonView alloc] initWithPolygon:(DJIPolygon *)overlay];
    //       return polygonRender;
    //   }else if ([overlay isKindOfClass:[DJIMapPolygon class]]) {
    //       MKPolygonRenderer *polygonRender = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon *)overlay];
    //       DJIMapPolygon *polygon = (DJIMapPolygon *)overlay;
    //       polygonRender.strokeColor = polygon.strokeColor;
    //       polygonRender.lineWidth = polygon.lineWidth;
    //       polygonRender.lineDashPattern = polygon.lineDashPattern;
    //       polygonRender.lineJoin = polygon.lineJoin;
    //       polygonRender.lineCap = polygon.lineCap;
    //       polygonRender.fillColor = polygon.fillColor;
    //       return polygonRender;
    //   } else if ([overlay isKindOfClass:[DJICircle class]]) {
    //       DJICircle *circle = (DJICircle *)overlay;
    //       MKCircleRenderer *circleRender = [[MKCircleRenderer alloc] initWithCircle:circle];
    //       circleRender.strokeColor = circle.strokeColor;
    //       circleRender.lineWidth = circle.lineWidth;
    //       circleRender.fillColor = circle.fillColor;
    //       return circleRender;
    //   }
    //
        return nil;
    }

    //MARK: - Update Fly Zones in Surrounding Area
    
    func updateFlyZones() {
    //{
    //    if ([self canUpdateLimitFlyZoneWithCoordinate]) {
    //        [self updateFlyZonesInSurroundingArea];
    //        [self updateCustomUnlockZone];
    //    }
    }
    
    func forceUpdateFlyZones() {
        //self.updateFlyZonesInSurroundingArea()
    }
    
    func canUpdateLimitFlyZoneWithCoordinate() -> Bool {
        guard let lastUpdateTime = self.lastUpdateTime else { return false }
        let currentTime = Date.timeIntervalSinceReferenceDate
        if (currentTime - lastUpdateTime) < kUpdateTimeStamp {
            return false
        }
        self.lastUpdateTime = currentTime
        return true
    }
    
    func updateFlyZonesInSurroundingArea() {
//        WeakRef(target);
//        [[DJISDKManager flyZoneManager] getFlyZonesInSurroundingAreaWithCompletion:^(NSArray<DJIFlyZoneInformation *> * _Nullable infos, NSError * _Nullable error) {
//            WeakReturn(target);
//            if (nil == error && nil != infos) {
//                [target updateFlyZoneOverlayWithInfos:infos];
//            }else{
//                if (target.mapOverlays.count > 0) {
//                    [target removeMapOverlays:target.mapOverlays];
//                }
//                if (target.flyZones.count > 0) {
//                    [target.flyZones removeAllObjects];
//                }
//            }
//        }];
    }
    
    func updateFlyZoneOverlayWith(flyZoneInfos:[DJIFlyZoneInformation]?) {
//        if (flyZoneInfos && flyZoneInfos.count > 0) {
//            dispatch_block_t block = ^{
//                NSMutableArray *overlays = [NSMutableArray array];
//                NSMutableArray *flyZones = [NSMutableArray array];
//
//                for (int i = 0; i < flyZoneInfos.count; i++) {
//                    DJIFlyZoneInformation *flyZoneLimitInfo = [flyZoneInfos objectAtIndex:i];
//                    DJILimitSpaceOverlay *aOverlay = nil;
//                    for (DJILimitSpaceOverlay *aMapOverlay in _mapOverlays) {
//                        if (aMapOverlay.limitSpaceInfo.flyZoneID == flyZoneLimitInfo.flyZoneID &&
//                            (aMapOverlay.limitSpaceInfo.subFlyZones.count == flyZoneLimitInfo.subFlyZones.count)) {
//                            aOverlay = aMapOverlay;
//                            break;
//                        }
//                    }
//                    if (!aOverlay) {
//                        aOverlay = [[DJILimitSpaceOverlay alloc] initWithLimitSpace:flyZoneLimitInfo];
//                    }
//                    [overlays addObject:aOverlay];
//                    [flyZones addObject:flyZoneLimitInfo];
//                }
//                [self removeMapOverlays:self.mapOverlays];
//                [self.flyZones removeAllObjects];
//                [self addMapOverlays:overlays];
//                [self.flyZones addObjectsFromArray:flyZones];
//            };
//            if ([NSThread currentThread].isMainThread) {
//                block();
//            } else {
//                dispatch_sync(dispatch_get_main_queue(), ^{
//                    block();
//                });
//            }
//        }
    }
    
    func updateCustomUnlockZone() {
//        WeakRef(target);
//        NSArray* zones = [[DJISDKManager flyZoneManager] getCustomUnlockZonesFromAircraft];
//
//        if (zones.count > 0) {
//            [[DJISDKManager flyZoneManager] getEnabledCustomUnlockZoneWithCompletion:^(DJICustomUnlockZone * _Nullable zone, NSError * _Nullable error) {
//                if (!error && zone) {
//                    [target updateCustomUnlockWithSpaces:@[zone] andEnabledZone:zone];
//                }
//            }];
//        } else {
//            if (target.customUnlockOverlays.count > 0) {
//                [target removeMapOverlays:self.customUnlockOverlays];
//            }
//        }
    }
    
    func updateCustomUnlockWith(spaceInfos:[DJICustomUnlockZone]?, enabledZone:DJICustomUnlockZone) {
//        if (spaceInfos && spaceInfos.count > 0) {
//            NSMutableArray *overlays = [NSMutableArray array];
//
//            for (int i = 0; i < spaceInfos.count; i++) {
//                DJICustomUnlockZone *flyZoneLimitInfo = [spaceInfos objectAtIndex:i];
//                DJICustomUnlockOverlay *aOverlay = nil;
//                for (DJICustomUnlockOverlay *aCustomUnlockOverlay in _customUnlockOverlays) {
//                    if (aCustomUnlockOverlay.customUnlockInformation.ID == flyZoneLimitInfo.ID) {
//                        //&& aCustomUnlockOverlay.CustomUnlockInformation.license.enabled == flyZoneLimitInfo.license.enabled) {
//                        aOverlay = aCustomUnlockOverlay;
//                        break;
//                    }
//                }
//                if (!aOverlay) {
//                    //TODO
//                    BOOL enabled = [flyZoneLimitInfo isEqual:enabledZone];
//                    aOverlay = [[DJICustomUnlockOverlay alloc] initWithCustomUnlockInformation:flyZoneLimitInfo andEnabled:enabled];
//                }
//                [overlays addObject:aOverlay];
//            }
//            [self removeCustomUnlockOverlays:self.customUnlockOverlays];
//            [self addCustomUnlockOverlays:overlays];
//        }
    }
    
    //TODO: Turn this into a computed property (set)...
    func set(mapType:MKMapType) {
        self.mapView?.mapType = mapType
    }
    
    func addMapOverlays(objects:[DJIMapOverlay]) {//TODO: rename to add(mapOverlays:)
    //    if (objects.count <= 0) {
    //        return;
    //    }
    //    NSMutableArray *overlays = [NSMutableArray array];
    //    for (DJIMapOverlay *aMapOverlay in objects) {
    //        for (id<MKOverlay> aOverlay in aMapOverlay.subOverlays) {
    //            [overlays addObject:aOverlay];
    //        }
    //    }
    //
    //    if ([NSThread isMainThread]) {
    //        [self.mapOverlays addObjectsFromArray:objects];
    //        [self.mapView addOverlays:overlays];
    //    } else {
    //        dispatch_sync(dispatch_get_main_queue(), ^{
    //            [self.mapOverlays addObjectsFromArray:objects];
    //            [self.mapView addOverlays:overlays];
    //        });
    //    }
    }
    
    func removeMapOverlays(objects:[DJIMapOverlay]) {//TODO:Rename
    //{
    //    if (objects.count <= 0) {
    //        return;
    //    }
    //    NSMutableArray *overlays = [NSMutableArray array];
    //    for (DJIMapOverlay *aMapOverlay in objects) {
    //        for (id<MKOverlay> aOverlay in aMapOverlay.subOverlays) {
    //            [overlays addObject:aOverlay];
    //        }
    //    }
    //    if ([NSThread isMainThread]) {
    //        [self.mapOverlays removeObjectsInArray:objects];
    //        [self.mapView removeOverlays:overlays];
    //    } else {
    //        dispatch_sync(dispatch_get_main_queue(), ^{
    //            [self.mapOverlays removeObjectsInArray:objects];
    //            [self.mapView removeOverlays:overlays];
    //        });
    //    }
    }
    
    func addCustomUnlockOverlays(objects:[DJIMapOverlay]) {//TODO: rename
    //    if (objects.count <= 0) {
    //        return;
    //    }
    //    NSMutableArray *overlays = [NSMutableArray array];
    //    for (DJIMapOverlay *aMapOverlay in objects) {
    //        for (id<MKOverlay> aOverlay in aMapOverlay.subOverlays) {
    //            [overlays addObject:aOverlay];
    //        }
    //    }
    //
    //    if ([NSThread isMainThread]) {
    //        [self.customUnlockOverlays addObjectsFromArray:objects];
    //        [self.mapView addOverlays:overlays];
    //    } else {
    //        dispatch_sync(dispatch_get_main_queue(), ^{
    //            [self.customUnlockOverlays addObjectsFromArray:objects];
    //            [self.mapView addOverlays:overlays];
    //        });
    //    }
    }
    
    func removeCustomUnlockOverlays(objects:[DJIMapOverlay]) {
    //    if (objects.count <= 0) {
    //        return;
    //    }
    //    NSMutableArray *overlays = [NSMutableArray array];
    //    for (DJIMapOverlay *aMapOverlay in objects) {
    //        for (id<MKOverlay> aOverlay in aMapOverlay.subOverlays) {
    //            [overlays addObject:aOverlay];
    //        }
    //    }
    //    if ([NSThread isMainThread]) {
    //        [self.customUnlockOverlays removeObjectsInArray:objects];
    //        [self.mapView removeOverlays:overlays];
    //    } else {
    //        dispatch_sync(dispatch_get_main_queue(), ^{
    //            [self.customUnlockOverlays removeObjectsInArray:objects];
    //            [self.mapView removeOverlays:overlays];
    //        });
    //    }
    }
    //
    func refreshMapViewRegion() {
    //    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(_aircraftCoordinate, 500, 500);
    //    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    //    [self.mapView setRegion:adjustedRegion animated:YES];
    }
}
