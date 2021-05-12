//
//  FlyLimitPolygonView.swift
//  DJIGeoSample
//
//  Created by Samuel Scherer on 5/6/21.
//  Copyright © 2021 DJI. All rights reserved.
//

import Foundation

class FlyLimitPolygonView : MKPolygonRenderer {
    
    //MARK: - life cycle
    
    init(polygon: Polygon) {
        super.init(polygon: polygon)
        // self.fillColor = [DJIFlyZoneColorProvider getFlyZoneOverlayColorWithCategory:polygon.level isHeightLimit:NO isFill:NO];
        // self.strokeColor = [DJIFlyZoneColorProvider getFlyZoneOverlayColorWithCategory:polygon.level isHeightLimit:NO isFill:YES];
        self.fillColor = FlyZoneColorProvider.getFlyZoneOverlayColorFor(category: polygon.level, isHeightLimit: false, isFill: false)
        self.strokeColor = FlyZoneColorProvider.getFlyZoneOverlayColorFor(category: polygon.level, isHeightLimit: false, isFill: true)
        self.lineWidth = 1.0
        self.lineJoin = CGLineJoin.bevel
        self.lineCap = CGLineCap.butt
    }
    
    //TODO: unnecessary??? Looks like it just passes to the super implementation.
    //- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    //    [super drawMapRect:mapRect zoomScale:zoomScale inContext:context];
    //
    //}
}
