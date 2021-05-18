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
    @objc public var strokeColor : UIColor?
    //@property (nonatomic, strong) UIColor *fillColor;
    @objc public var fillColor : UIColor?
    //@property (nonatomic, assign) CGFloat lineWidth;
    @objc public var lineWidth : Float = 0.0
    //@property (nonatomic, assign) CGFloat lineDashPhase;
    @objc public var lineDashPhase = 0.0 //TODO: use optional?
    //@property (nonatomic, assign) CGLineCap lineCap;
    @objc public var lineCap : CGLineCap = CGLineCap(rawValue: 0)!//TODO: use optional?
    //@property (nonatomic, assign) CGLineJoin lineJoin;
    @objc public var lineJoin : CGLineJoin = CGLineJoin(rawValue: 0)!//TODO: use optional?
    //@property (nonatomic, strong) NSArray<NSNumber*> *lineDashPattern;
    @objc public var lineDashPattern : [NSNumber]?
}
