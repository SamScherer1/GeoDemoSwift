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
    @objc public var flyZones = [DJIFlyZoneInformation]()
    var aircraftCoordinate : CLLocationCoordinate2D
    var mapView : MKMapView
    var aircraftAnnotation : AircraftAnnotation?
    var mapOverlays = [MapOverlay]()
//    @property (nonatomic, strong) NSMutableArray<MapOverlay *> *customUnlockOverlays;
    var customUnlockOverlays : [MapOverlay]?
    var lastUpdateTime = Date.timeIntervalSinceReferenceDate
    
    @objc public init(map: MKMapView) {
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
    
    @objc public func updateAircraft(coordinate:CLLocationCoordinate2D, heading:Float) {
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
        } else if let polygon = overlay as? MapPolygon {
            let polygonRender = MKPolygonRenderer(polygon: polygon)
            polygonRender.strokeColor = polygon.strokeColor
            polygonRender.lineWidth = CGFloat(polygon.lineWidth)
            polygonRender.lineDashPattern = polygon.lineDashPattern
            let polygonLineJoin = polygon.lineJoin
            polygonRender.lineJoin = polygonLineJoin
            let polygonLineCap = polygon.lineCap
            polygonRender.lineCap = polygonLineCap
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
        let currentTime = Date.timeIntervalSinceReferenceDate
        if (currentTime - self.lastUpdateTime) < kUpdateTimeStamp {
            return false
        }
        self.lastUpdateTime = currentTime
        return true
    }
    
    @objc public func updateFlyZonesInSurroundingArea() {
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
        guard let flyZoneInfos = flyZoneInfos, flyZoneInfos.count > 0 else { return }
        //TODO: rename closure something descriptive
        let closure = {
            var overlays = [LimitSpaceOverlay]()
            var flyZones = [DJIFlyZoneInformation]()
            
            for flyZoneLimitInfo in flyZoneInfos {
                var anOverlay : LimitSpaceOverlay?
                for aMapOverlay in self.mapOverlays as! [LimitSpaceOverlay] {
                    if (aMapOverlay.limitSpaceInfo?.flyZoneID == flyZoneLimitInfo.flyZoneID) && (aMapOverlay.limitSpaceInfo?.subFlyZones?.count == flyZoneLimitInfo.subFlyZones?.count) {
                        anOverlay = aMapOverlay
                        break
                    }
                }
                if anOverlay == nil {
                    anOverlay = LimitSpaceOverlay(limitSpaceInfo: flyZoneLimitInfo)
                }
                overlays.append(anOverlay!)
                flyZones.append(flyZoneLimitInfo)
            }

            self.removeMapOverlays(objects: self.mapOverlays)
            self.flyZones.removeAll()
            self.addMapOverlays(objects: overlays)
            self.flyZones.append(contentsOf: flyZones)
        }
        
        if Thread.current.isMainThread {
            closure()
        } else {
            DispatchQueue.main.sync {
                closure()
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
        if objects.count <= 0 { return }
        let overlays = self.subOverlaysFor(objects)
        self.performOnMainThread {
            self.mapOverlays.append(contentsOf: objects)
            self.mapView.addOverlays(overlays)
        }
    }
    
    @objc func removeMapOverlays(objects:[MapOverlay]) {//TODO:Rename
        if objects.count <= 0 { return }
        
        self.performOnMainThread {
            self.mapOverlays.removeAll(where: { objects.contains($0) } )
            self.mapView.removeOverlays(self.subOverlaysFor(objects))
        }
    }
    
    @objc func addCustomUnlockOverlays(objects:[MapOverlay]) {//TODO: rename
        if objects.count <= 0 { return }
        
        let overlays = self.subOverlaysFor(objects)
        self.performOnMainThread {
            self.customUnlockOverlays?.append(contentsOf: objects)
            self.mapView.addOverlays(overlays)
        }
    }
    
    @objc func removeCustomUnlockOverlays(objects:[MapOverlay]) {//TODO: rename
        if objects.count <= 0 { return }

        let overlays = self.subOverlaysFor(objects)
        self.performOnMainThread {
            self.customUnlockOverlays?.removeAll(where: { objects.contains($0) })
            self.mapView.removeOverlays(overlays)
        }
    }
    
    @objc func subOverlaysFor(_ overlays:[MapOverlay]) -> [MKOverlay] {
        var subOverlays = [MKOverlay]()
        for aMapOverlay in overlays {
            subOverlays.append(contentsOf: aMapOverlay.subOverlays)
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

    @objc public func refreshMapViewRegion() {
        let viewRegion = MKCoordinateRegion(center: self.aircraftCoordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        let adjustedRegion = self.mapView.regionThatFits(viewRegion)
        self.mapView.setRegion(adjustedRegion, animated: true)
    }
}
