//
//  DJILimitSpaceOverlay.m
//  Phantom3
//
//  Created by DJISoft on 2017/1/19.
//  Copyright © 2017年 DJIDevelopers.com. All rights reserved.
//

#import "DJILimitSpaceOverlay.h"
#import "DJIPolygon.h"
#import "DJICircle.h"
#import "DJIMapPolygon.h"
#import "DJIFlyZoneCircle.h"
#define kDJILimitFlightSpaceBufferHeight (5)

@interface DJILimitSpaceOverlay()

@property (nonatomic, strong) DJIFlyZoneInformation *limitSpaceInfo;

@end

@implementation DJILimitSpaceOverlay

- (id)initWithLimitSpace:(DJIFlyZoneInformation *)limitSpaceInfo
{
    self = [super init];
    if (self) {
        _limitSpaceInfo = limitSpaceInfo;
        [self createOverlays];
    }
    
    return self;
}

- (NSArray<id<MKOverlay>> *)overlysForSubFlyZoneSpace:(DJISubFlyZoneInformation *)aSpace
{
       
    if (aSpace.shape == DJISubFlyZoneShapeCylinder) {
        CLLocationCoordinate2D coordinateInMap = aSpace.center;
        DJICircle *circle = [DJICircle circleWithCenterCoordinate:coordinateInMap
                                                           radius:aSpace.radius];
        circle.lineWidth = [self strokLineWidthWithHeight:aSpace.maximumFlightHeight];
        circle.fillColor = [self fillColorForLimitHeight:aSpace.maximumFlightHeight];
        circle.strokeColor = [self strokColorForLimitHeight:aSpace.maximumFlightHeight];
        return @[circle];

    } else if(aSpace.shape == DJISubFlyZoneShapePolygon) {
        if (aSpace.vertices.count <= 0) {
            return @[];
        }
        
        CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D *)malloc(sizeof(CLLocationCoordinate2D) * aSpace.vertices.count);
        
        int i = 0;
        for (i = 0; i < aSpace.vertices.count; i++) {
            NSValue *aPointValue = aSpace.vertices[i];
            CLLocationCoordinate2D coordinate = [aPointValue MKCoordinateValue];
            CLLocationCoordinate2D coordinateInMap = coordinate;
            coordinates[i] = coordinateInMap;
            NSLog(@"coordiantes: %lf, %lf", coordinate.latitude, coordinate.longitude);
        }
        DJIMapPolygon *polygon = [DJIMapPolygon polygonWithCoordinates:coordinates count:aSpace.vertices.count];
        polygon.lineWidth = [self strokLineWidthWithHeight:aSpace.maximumFlightHeight];
        polygon.strokeColor = [self strokColorForLimitHeight:aSpace.maximumFlightHeight];
        polygon.fillColor = [self fillColorForLimitHeight:aSpace.maximumFlightHeight];
        free(coordinates);
        return @[polygon];
    }
    return nil;
}

- (NSArray<id<MKOverlay>> *)overlysForFlyZoneSpace:(DJIFlyZoneInformation *)aSpace
{
    if (!aSpace) {
        return @[];
    }
    if (aSpace.subFlyZones.count <= 0) {
        CLLocationCoordinate2D coordinateInMap = aSpace.center;
        CGFloat radius = aSpace.radius;
        
        DJIFlyZoneCircle* circle = [DJIFlyZoneCircle circleWithCenterCoordinate:coordinateInMap radius:radius];
        circle.category = aSpace.category;
        circle.flyZoneID = aSpace.flyZoneID;
        circle.name = aSpace.name;
        return @[circle];
    } else {
        NSMutableArray *results = [NSMutableArray array];
        for (DJISubFlyZoneInformation *aSubSpace in aSpace.subFlyZones) {
            NSArray *subOverlays = [self overlysForSubFlyZoneSpace:aSubSpace];
            [results addObjectsFromArray:subOverlays];
        }
        
        return results;
    }
    return @[];
}

- (void)createOverlays
{
    self.subOverlays = [NSMutableArray array];
    NSArray *overlays = [self overlysForFlyZoneSpace:self.limitSpaceInfo];
    [self.subOverlays addObjectsFromArray:overlays];
}

- (UIColor *)strokColorForLimitHeight:(NSInteger)height
{
    if (height <= 0 + kDJILimitFlightSpaceBufferHeight) {
        return nil;
    } else if (height <= 30 + kDJILimitFlightSpaceBufferHeight) {
        return nil;
    }else if (height <= 60 + kDJILimitFlightSpaceBufferHeight) {
        return UIColorFromRGBA(0x000000, 0.4);
    }
    
    return UIColorFromRGBA(0x000000, 0.4);
}

- (UIColor *)fillColorForLimitHeight:(NSInteger)height
{
    if (height <= 0 + kDJILimitFlightSpaceBufferHeight) {
        return UIColorFromRGBA(0xE70102, 0.4);
    } else if (height <= 30 + kDJILimitFlightSpaceBufferHeight) {
        return UIColorFromRGBA(0xE70102, 0.2);
    }else if (height <= 60 + kDJILimitFlightSpaceBufferHeight) {
        return UIColorFromRGBA(0x000000, 0.2);
    }
    
    return UIColorFromRGBA(0x000000, 0.1);
}

-(CGFloat)strokLineWidthWithHeight:(NSInteger)height
{
    if (height <= 30 + kDJILimitFlightSpaceBufferHeight) {
        return 0;
    }
    return 1.0;
}

@end