//
//  MapPolygon.swift
//  DJIGeoSample
//
//  Created by Samuel Scherer on 5/6/21.
//  Copyright © 2021 DJI. All rights reserved.
//

import Foundation
import MapKit

class MapPolygon : MKPolygon {
    //@property (copy, nonatomic) UIColor *strokeColor;
     public var strokeColor : UIColor?
    //@property (nonatomic, strong) UIColor *fillColor;
     public var fillColor : UIColor?
    //@property (nonatomic, assign) CGFloat lineWidth;
     public var lineWidth : Float = 0.0
    //@property (nonatomic, assign) CGFloat lineDashPhase;
     public var lineDashPhase = 0.0 //TODO: use optional?
    //@property (nonatomic, assign) CGLineCap lineCap;
     public var lineCap : CGLineCap = CGLineCap(rawValue: 0)!//TODO: use optional?
    //@property (nonatomic, assign) CGLineJoin lineJoin;
     public var lineJoin : CGLineJoin = CGLineJoin(rawValue: 0)!//TODO: use optional?
    //@property (nonatomic, strong) NSArray<NSNumber*> *lineDashPattern;
     public var lineDashPattern : [NSNumber]?
}
