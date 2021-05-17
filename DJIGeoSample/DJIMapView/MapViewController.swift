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


@objc class MapViewController : NSObject, MKMapViewDelegate {//TODO: consider not subclassing NSObject
    //@property (nonatomic, strong) NSMutableArray *flyZones;
    @objc public var flyZones = [Any]()//TODO: specify array type?
//    @property (nonatomic) CLLocationCoordinate2D aircraftCoordinate;
    var aircraftCoordinate : CLLocationCoordinate2D
//    @property (weak, nonatomic) MKMapView *mapView;
    var mapView : MKMapView
//    @property (nonatomic, strong) AircraftAnnotation* aircraftAnnotation;
    var aircraftAnnotation : AircraftAnnotation?
//    @property (nonatomic, strong) NSMutableArray<DJIMapOverlay *> *mapOverlays;
    var mapOverlays = [MapOverlay]()//TODO: should be DJILimitSpaceOverlay?
//    @property (nonatomic, strong) NSMutableArray<DJIMapOverlay *> *customUnlockOverlays;
    var customUnlockOverlays : [MapOverlay]?
//    @property (nonatomic, assign) NSTimeInterval lastUpdateTime;
    var lastUpdateTime : TimeInterval?
    
    @objc init(map:MKMapView) {
        self.aircraftCoordinate = CLLocationCoordinate2DMake(0.0, 0.0)
        self.mapView = map
        
        super.init()
        
        self.mapView.delegate = self
        self.forceUpdateFlyZones()
    }
    
    @objc deinit {
        self.aircraftAnnotation = nil
        self.mapView.delegate = nil
    }
    
    @objc func updateAircraft(coordinate:CLLocationCoordinate2D, heading:Float) {
        if CLLocationCoordinate2DIsValid(coordinate) {
            self.aircraftCoordinate = coordinate
            if let _ = self.aircraftAnnotation {
                self.aircraftAnnotation?.coordinate = coordinate
                let annotationView = (self.mapView.view(for: self.aircraftAnnotation!)) as? AircraftAnnotationView
                annotationView?.update(heading: heading)
            } else {
                let aircraftAnnotation = AircraftAnnotation(coordinate: coordinate, heading: heading)
                self.aircraftAnnotation = aircraftAnnotation
                self.mapView.addAnnotation(aircraftAnnotation)
                let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                let adjustedRegion = self.mapView.regionThatFits(viewRegion)
                self.mapView.setRegion(adjustedRegion, animated: true)
            }
            self.updateFlyZones()
        }
    }
    
    //MARK: - MKMapViewDelegate Methods
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) { return nil }
        if annotation.isKind(of: AircraftAnnotation.self) {
            let aircraftAnno = self.mapView.dequeueReusableAnnotationView(withIdentifier: "DJI_AIRCRAFT_ANNOTATION_VIEW")
            return aircraftAnno ?? AircraftAnnotationView(annotation: annotation, reuseIdentifier: "DJI_AIRCRAFT_ANNOTATION_VIEW")
            
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? FlyZoneCircle {
            return FlyZoneCircleView(circle: overlay)
        } else if let polygon = overlay as? Polygon {
            return FlyLimitPolygonView(polygon: polygon)
//        } else if overlay.isKind(of: DJIMapPolygon.self) {
        } else if let polygon = overlay as? MapPolygon {
            let polygonRender = MKPolygonRenderer(polygon: polygon)
            polygonRender.strokeColor = polygon.strokeColor
            polygonRender.lineWidth = CGFloat(polygon.lineWidth)
            polygonRender.lineDashPattern = polygon.lineDashPattern
            if let polygonLineJoin = polygon.lineJoin {
                polygonRender.lineJoin = polygonLineJoin
            }
            if let polygonLineCap = polygon.lineCap {
                polygonRender.lineCap = polygonLineCap
            }
            polygonRender.fillColor = polygon.fillColor
            return polygonRender
        } else if let circle = overlay as? Circle {
            let circleRenderer = MKCircleRenderer(circle: circle)
            circleRenderer.strokeColor = circle.strokeColor
            circleRenderer.lineWidth = CGFloat(circle.lineWidth)
            circleRenderer.fillColor = circle.fillColor
            return circleRenderer;
        }
        fatalError("error generating overlay renderer")
    }

    //MARK: - Update Fly Zones in Surrounding Area
    @objc func updateFlyZones() {
        if self.canUpdateLimitFlyZoneWithCoordinate() {
            self.updateFlyZonesInSurroundingArea()
            self.updateCustomUnlockZone()
        }
    }
    
    @objc func forceUpdateFlyZones() {//TODO: unnecessary method?
        self.updateFlyZonesInSurroundingArea()
    }
    
    @objc func canUpdateLimitFlyZoneWithCoordinate() -> Bool {
        guard let lastUpdateTime = self.lastUpdateTime else { return false }
        let currentTime = Date.timeIntervalSinceReferenceDate
        if (currentTime - lastUpdateTime) < kUpdateTimeStamp {
            return false
        }
        self.lastUpdateTime = currentTime
        return true
    }
    
    @objc func updateFlyZonesInSurroundingArea() {
        DJISDKManager.flyZoneManager()?.getFlyZonesInSurroundingArea(completion: { [weak self] (infos:[DJIFlyZoneInformation]?, error:Error?) in
            if let infos = infos, error == nil {
                self?.updateFlyZoneOverlayWith(flyZoneInfos: infos)
            } else {
                if let mapOverlays = self?.mapOverlays {
                    if mapOverlays.count > 0 {
                        self?.removeMapOverlays(objects: mapOverlays)
                    }
                }
                if let flyZones = self?.flyZones {
                    if flyZones.count > 0 {
                        self?.flyZones.removeAll()
                    }
                }
            }
        })
    }
    
    @objc func updateFlyZoneOverlayWith(flyZoneInfos:[DJIFlyZoneInformation]?) {
        guard let flyZoneInfos = flyZoneInfos else { return }
        if flyZoneInfos.count > 0 {
            //TODO: rename closure something descriptive
            let closure = {
                var overlays = [DJILimitSpaceOverlay]()
                var flyZones = [DJIFlyZoneInformation]()
                
                for flyZoneLimitInfo in flyZoneInfos {
                    var anOverlay : DJILimitSpaceOverlay?
                    for aMapOverlay in self.mapOverlays as! [DJILimitSpaceOverlay] {
                        if (aMapOverlay.limitSpaceInfo.flyZoneID == flyZoneLimitInfo.flyZoneID) && (aMapOverlay.limitSpaceInfo.subFlyZones?.count == flyZoneLimitInfo.subFlyZones?.count) {
                            anOverlay = aMapOverlay
                            break
                        }
                    }
                    if anOverlay == nil {
                        anOverlay = DJILimitSpaceOverlay(limitSpace: flyZoneLimitInfo)
                    }
                    overlays.append(anOverlay!)
                    flyZones.append(flyZoneLimitInfo)
                }
            }
            
            if Thread.current.isMainThread {
                closure()
            } else {
                DispatchQueue.main.sync {
                    closure()
                }
            }
        }
    }
    
    @objc func updateCustomUnlockZone() { //TODO: test this method... it's a mess!
//        WeakRef(target);
//        NSArray* zones = [[DJISDKManager flyZoneManager] getCustomUnlockZonesFromAircraft];
//
//        if (zones.count > 0) {

//        } else {
//            if (target.customUnlockOverlays.count > 0) {
//                [target removeMapOverlays:self.customUnlockOverlays];
//            }
//        }
        if let zones = DJISDKManager.flyZoneManager()?.getCustomUnlockZonesFromAircraft() {
            if zones.count > 0 {
                //            [[DJISDKManager flyZoneManager] getEnabledCustomUnlockZoneWithCompletion:^(DJICustomUnlockZone * _Nullable zone, NSError * _Nullable error) {
                //                if (!error && zone) {
                //                    [target updateCustomUnlockWithSpaces:@[zone] andEnabledZone:zone];
                //                }
                //            }];
                DJISDKManager.flyZoneManager()?.getEnabledCustomUnlockZone(completion: { [weak self] (zone:DJICustomUnlockZone?, error:Error?) in
                    if (error == nil) && (zone != nil) {
                        self?.updateCustomUnlockWith(spaceInfos: [zone!], enabledZone: zone!)//TODO: reconsider force unwrap
                    }
                })
            } else {
                removeCustomUnlocks()
            }
        }
    }
    
    @objc func removeCustomUnlocks() {
        guard let _ = self.customUnlockOverlays else { return }
        if self.customUnlockOverlays!.count > 0 {
            self.removeMapOverlays(objects: self.customUnlockOverlays!)
        }
    }
    
    @objc func updateCustomUnlockWith(spaceInfos:[DJICustomUnlockZone]?, enabledZone:DJICustomUnlockZone) {
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
    @objc func set(mapType:MKMapType) {
        self.mapView.mapType = mapType
    }
    
    @objc func addMapOverlays(objects:[MapOverlay]) {//TODO: rename to add(mapOverlays:)
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
        if objects.count <= 0 { return }
        let overlays = self.subOverlaysFor(objects)
        self.performOnMainThread {
            self.customUnlockOverlays?.append(contentsOf: objects)
            self.mapView.addOverlays(overlays)
        }
    }
    
    @objc func removeMapOverlays(objects:[MapOverlay]) {//TODO:Rename
        if objects.count <= 0 { return }
        let overlays = self.subOverlaysFor(objects)
        
    //    if ([NSThread isMainThread]) {
    //        [self.mapOverlays removeObjectsInArray:objects];
    //        [self.mapView removeOverlays:overlays];
    //    } else {
    //        dispatch_sync(dispatch_get_main_queue(), ^{
    //            [self.mapOverlays removeObjectsInArray:objects];
    //            [self.mapView removeOverlays:overlays];
    //        });
    //    }
        self.performOnMainThread {
            self.mapOverlays.removeAll(where: { objects.contains($0) } )
            self.mapView.removeOverlays(overlays)
        }
    }
    
    @objc func addCustomUnlockOverlays(objects:[MapOverlay]) {//TODO: rename
        if objects.count <= 0 { return }
        let overlays = self.subOverlaysFor(objects)
        
//        if Thread.isMainThread {
//            self.customUnlockOverlays?.append(contentsOf: objects)
//            self.mapView.addOverlays(overlays)
//        } else {
//            DispatchQueue.main.async {
//                self.customUnlockOverlays?.append(contentsOf: objects)
//                self.mapView.addOverlays(overlays)
//            }
//        }
        self.performOnMainThread {
            self.customUnlockOverlays?.append(contentsOf: objects)
            self.mapView.addOverlays(overlays)
        }
    }
    
    @objc func removeCustomUnlockOverlays(objects:[MapOverlay]) {//TODO: rename
        if objects.count <= 0 { return }

        let overlays = self.subOverlaysFor(objects)
        
//        if Thread.isMainThread {
//            self.customUnlockOverlays?.removeAll(where: { objects.contains($0) })
//            self.mapView.removeOverlays(overlays)
//        } else {
//            DispatchQueue.main.async {
//                self.customUnlockOverlays?.removeAll(where: { objects.contains($0) })
//                self.mapView.removeOverlays(overlays)
//            }
//        }
        self.performOnMainThread {
            self.customUnlockOverlays?.removeAll(where: { objects.contains($0) })
            self.mapView.removeOverlays(overlays)
        }
    }
    
    @objc func subOverlaysFor(_ overlays:[MapOverlay]) -> [MKOverlay] {
        var subOverlays = [MKOverlay]()
        for aMapOverlay in overlays {
            for aOverlay in aMapOverlay.subOverlays! {//TODO: force unwrap
                if let aOverlay = aOverlay as? MKOverlay {
                    subOverlays.append(aOverlay)
                }
            }
        }
        return subOverlays
    }
    
    @objc func performOnMainThread(closure: @escaping () -> ()) {
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async {
                closure()
            }
        }
    }

    @objc func refreshMapViewRegion() {
        let viewRegion = MKCoordinateRegion(center: self.aircraftCoordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        let adjustedRegion = self.mapView.regionThatFits(viewRegion)
        self.mapView.setRegion(adjustedRegion, animated: true)
    }
}
