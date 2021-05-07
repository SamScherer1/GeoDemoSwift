//
//  FlyZoneCircleView.swift
//  DJIGeoSample
//
//  Created by Samuel Scherer on 5/6/21.
//  Copyright © 2021 DJI. All rights reserved.
//

import Foundation

class FlyZoneCircleView : MKCircleRenderer {

    init(circle: FlyZoneCircle) {
        super.init(circle: circle as MKCircle)
        // self.fillColor = [DJIFlyZoneColorProvider getFlyZoneOverlayColorWithCategory:circle.category isHeightLimit:NO isFill:YES];
        // self.strokeColor = [DJIFlyZoneColorProvider getFlyZoneOverlayColorWithCategory:circle.category isHeightLimit:NO isFill:NO];
        self.lineWidth = 1.0
    }
    
}
