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
    var fillColor : UIColor?
    //@property (nonatomic, assign) CGFloat lineWidth;
    public var lineWidth : Float = 0.0
    //@property (nonatomic, assign) CGFloat lineDashPhase;
    var lineDashPhase : Float?
    //@property (nonatomic, assign) CGLineCap lineCap;
    var lineCap : CGLineCap?
    //@property (nonatomic, assign) CGLineJoin lineJoin;
    var lineJoin : CGLineJoin?
    //@property (nonatomic, strong) NSArray<NSNumber*> *lineDashPattern;
    var lineDashPattern : [NSNumber]?
}
