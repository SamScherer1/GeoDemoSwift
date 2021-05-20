//
//  GeoGroupInfoViewController.swift
//  DJIGeoSample
//
//  Created by Samuel Scherer on 5/18/21.
//  Copyright © 2021 DJI. All rights reserved.
//

import Foundation
import UIKit
import DJISDK

class GeoGroupInfoViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    public var unlockedZoneGroup : DJIUnlockedZoneGroup?
    
    @IBOutlet weak var selfUnlockingTable: UITableView!
    @IBOutlet weak var customUnlockingTable: UITableView!
    fileprivate var flyZoneInfoView : DJIScrollView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.flyZoneInfoView = DJIScrollView.viewWith(viewController: self)//TODO: init method is more swifty
        self.flyZoneInfoView?.isHidden = true
        self.flyZoneInfoView?.setDefaultSize()
        
        self.selfUnlockingTable.reloadData()
        self.customUnlockingTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if ([tableView isEqual:self.selfUnlockingTable]) {
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelfUnlockingCell"];
//            if (cell == nil) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SelfUnlockingCell"];
//            }
//            DJIFlyZoneInformation *zone = self.unlockedZoneGroup.selfUnlockedFlyZones[indexPath.row];
//            cell.textLabel.text = zone.name;
//            cell.detailTextLabel.text = [NSString stringWithFormat:@"AreaID:%tu, Lat: %f, Long: %f",zone.flyZoneID, zone.center.latitude, zone.center.longitude];
//            return cell;
//
//        } else if ([tableView isEqual:self.customUnlockingTable]) {
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomUnlockCell"];
//            if (cell == nil) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CustomUnlockCell"];
//            }
//            DJICustomUnlockZone *zone = self.unlockedZoneGroup.customUnlockZones[indexPath.row];
//            cell.textLabel.text = zone.name;
//            cell.detailTextLabel.text = [NSString stringWithFormat:@"UnlockID:%tu, Lat: %f, Long: %f",zone.ID, zone.center.latitude, zone.center.longitude];
//            return cell;
//        }
//        return nil;
        if tableView === self.selfUnlockingTable {
            let nullableCell = tableView.dequeueReusableCell(withIdentifier: "SelfUnlockingCell")
            let cell = nullableCell ?? UITableViewCell(style: .subtitle, reuseIdentifier: "SelfUnlockingCell")
            if let zone = self.unlockedZoneGroup?.selfUnlockedFlyZones[indexPath.row] {
                cell.textLabel?.text = zone.name
//            cell.detailTextLabel.text = [NSString stringWithFormat:@"AreaID:%tu, Lat: %f, Long: %f",zone.flyZoneID, zone.center.latitude, zone.center.longitude];
                cell.detailTextLabel?.text = "AreaID:\(zone.flyZoneID), Lat: \(zone.center.latitude), Long: \(zone.center.longitude)"
            }
            return cell
            
        } else if tableView === self.customUnlockingTable {
            let nullableCell = tableView.dequeueReusableCell(withIdentifier: "CustomUnlockingCell")
            let cell = nullableCell ?? UITableViewCell(style: .subtitle, reuseIdentifier: "CustomUnlockingCell")
            if let zone = self.unlockedZoneGroup?.customUnlockZones[indexPath.row] {
                cell.textLabel?.text = zone.name
//            cell.detailTextLabel.text = [NSString stringWithFormat:@"UnlockID:%tu, Lat: %f, Long: %f",zone.ID, zone.center.latitude, zone.center.longitude];
                cell.detailTextLabel?.text = "AreaID:\(zone.id), Lat: \(zone.center.latitude), Long: \(zone.center.longitude)"
            }
            return cell
            
        }
        fatalError()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if ([tableView isEqual:self.selfUnlockingTable]) {
//            return self.unlockedZoneGroup.selfUnlockedFlyZones.count;
//        } else if ([tableView isEqual:self.customUnlockingTable]) {
//            return self.unlockedZoneGroup.customUnlockZones.count;
//        }
//        return 0;
        if tableView === self.selfUnlockingTable {
            return self.unlockedZoneGroup?.selfUnlockedFlyZones.count ?? 0
        } else if tableView.isEqual(self.customUnlockingTable) {
            return self.unlockedZoneGroup?.customUnlockZones.count ?? 0
        }
        return 0
    }
//
//    - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//        self.flyZoneInfoView.hidden = NO;
//        [self.flyZoneInfoView show];
//
//        if ([tableView isEqual:self.selfUnlockingTable]) {
//            DJIFlyZoneInformation *information = self.unlockedZoneGroup.selfUnlockedFlyZones[indexPath.row];
//
//        } else if ([tableView isEqual:self.customUnlockingTable]) {
//            DJICustomUnlockZone *customUnlockZone = self.unlockedZoneGroup.customUnlockZones[indexPath.row];
//        }
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.flyZoneInfoView?.isHidden = true
        self.flyZoneInfoView?.show()
        
        if tableView === self.selfUnlockingTable {
            if let information = self.unlockedZoneGroup?.selfUnlockedFlyZones[indexPath.row] {
                self.flyZoneInfoView?.write(status: self.formatFlyZoneInformtionString(for: information))
            }
        } else if tableView === self.customUnlockingTable {
            if let customUnlockZone = self.unlockedZoneGroup?.customUnlockZones[indexPath.row] {
                self.flyZoneInfoView?.write(status: self.formatCustomUnlockZoneInformtionString(customUnlockZone: customUnlockZone))
            }
        }
    }
//
//    - (NSString*)formatCustomUnlockZoneInformtionString:(DJICustomUnlockZone*)customUnlockZone
//    {
//        NSMutableString* infoString = [[NSMutableString alloc] init];
//        if (customUnlockZone) {
//            [infoString appendString:[NSString stringWithFormat:@"ID:%lu\n", (unsigned long)customUnlockZone.ID]];
//            [infoString appendString:[NSString stringWithFormat:@"Name:%@\n", customUnlockZone.name]];
//            [infoString appendString:[NSString stringWithFormat:@"Coordinate:(%f,%f)\n", customUnlockZone.center.latitude, customUnlockZone.center.longitude]];
//            [infoString appendString:[NSString stringWithFormat:@"Radius:%f\n", customUnlockZone.radius]];
//            [infoString appendString:[NSString stringWithFormat:@"StartTime:%@, EndTime:%@\n", customUnlockZone.startTime, customUnlockZone.endTime]];
//        }
//        NSString *result = [NSString stringWithString:infoString];
//        return result;
//    }
    func formatCustomUnlockZoneInformtionString(customUnlockZone:DJICustomUnlockZone) -> String {
        var infoString = ""
        infoString.append("ID:\(customUnlockZone.id)\n")
        infoString.append("Name\(customUnlockZone.name)\n")
//            [infoString appendString:[NSString stringWithFormat:@"Coordinate:(%f,%f)\n", customUnlockZone.center.latitude, customUnlockZone.center.longitude]];
        infoString.append("Coordinate:\(customUnlockZone.center.latitude),\(customUnlockZone.center.longitude)\n")
        infoString.append("Radius:\(customUnlockZone.radius)\n")
        infoString.append("StartTime:\(customUnlockZone.startTime), EndTime\(customUnlockZone.endTime)\n")
//            [infoString appendString:[NSString stringWithFormat:@"isExpired:%@\n", customUnlockZone.isExpired ? @"YES":@"NO"]];
        infoString.append("isExpired:\(customUnlockZone.isExpired)\n")//TODO: test boolean string interpolation
        return infoString
    }
//
//    - (NSString*)formatFlyZoneInformtionString:(DJIFlyZoneInformation*)information {
    func formatFlyZoneInformtionString(for information:DJIFlyZoneInformation) -> String {
//        NSMutableString* infoString = [[NSMutableString alloc] init];
        var infoString = ""
//        if (information) {
//            [infoString appendString:[NSString stringWithFormat:@"ID:%lu\n", (unsigned long)information.flyZoneID]];
//            [infoString appendString:[NSString stringWithFormat:@"Name:%@\n", information.name]];
//            [infoString appendString:[NSString stringWithFormat:@"Coordinate:(%f,%f)\n", information.center.latitude, information.center.longitude]];
//            [infoString appendString:[NSString stringWithFormat:@"Radius:%f\n", information.radius]];
//            [infoString appendString:[NSString stringWithFormat:@"StartTime:%@, EndTime:%@\n", information.startTime, information.endTime]];
//            [infoString appendString:[NSString stringWithFormat:@"unlockStartTime:%@, unlockEndTime:%@\n", information.unlockStartTime, information.unlockEndTime]];
//            [infoString appendString:[NSString stringWithFormat:@"GEOZoneType:%d\n", information.type]];
//            [infoString appendString:[NSString stringWithFormat:@"FlyZoneType:%@\n", information.shape == DJIFlyZoneShapeCylinder ? @"Cylinder" : @"Cone"]];
//            [infoString appendString:[NSString stringWithFormat:@"FlyZoneCategory:%@\n",[self getFlyZoneCategoryString:information.category]]];
//
//            if (information.subFlyZones.count > 0) {
//                NSString* subInfoString = [self formatSubFlyZoneInformtionString:information.subFlyZones];
//                [infoString appendString:subInfoString];
//            }
//        }
//        NSString *result = [NSString stringWithString:infoString];
        infoString.append("ID:\(information.flyZoneID)\n")
        infoString.append("Name:\(information.name)\n")
        infoString.append("Coordinate:(\(information.center.latitude),\(information.center.longitude)")
        infoString.append("Radius:\(information.radius)\n")
        //TODO: difference between startTime and unlockStartTime?
        infoString.append("StartTime:\(information.startTime), EndTime:\(information.endTime)\n")
        infoString.append("unlockStartTime:\(information.unlockStartTime), unlockEndTime:\(information.unlockEndTime)\n")
        infoString.append("GEOZoneType:\(information.type)")
        infoString.append("FlyZoneType:\(information.shape == .cylinder ? "Cylinder" : "Cone")")
        infoString.append("FlyZoneCategory:\(self.getFlyZoneCategoryString(category: information.category))\n")
        
        if let subFlyZones = information.subFlyZones {
            if subFlyZones.count > 0 {
                infoString.append(self.formatSubFlyZoneInformtionString(for: subFlyZones))
            }
        }
        
        return infoString
    }

    func formatSubFlyZoneInformtionString(for subFlyZoneInformations: [DJISubFlyZoneInformation]) -> String {
        //        NSMutableString *subInfoString = [NSMutableString string];
        var subInfoString = ""
        for subInformation in subFlyZoneInformations {
            subInfoString.append("-----------------\n")
//            [subInfoString appendString:[NSString stringWithFormat:@"SubAreaID:%@\n", @(subInformation.areaID)]];
            subInfoString.append("SubAreaID:\(subInformation.areaID)\n")
//            [subInfoString appendString:[NSString stringWithFormat:@"Graphic:%@\n", DJISubFlyZoneShapeCylinder == subInformation.shape ? @"Circle": @"Polygon"]];
            subInfoString.append("Graphic:\(subInformation.shape == .cylinder ? "Circle" : "Polygon")")
//            [subInfoString appendString:[NSString stringWithFormat:@"MaximumFlightHeight:%ld\n", (long)subInformation.maximumFlightHeight]];
            subInfoString.append("MaximumFlightHeight:\(subInformation.maximumFlightHeight)")
//            [subInfoString appendString:[NSString stringWithFormat:@"Radius:%f\n", subInformation.radius]];
            subInfoString.append("Radius:\(subInformation.radius)\n")
            
//            [subInfoString appendString:[NSString stringWithFormat:@"Coordinate:(%f,%f)\n", subInformation.center.latitude, subInformation.center.longitude]];
            subInfoString.append("Coordinate:(\(subInformation.center.latitude),\(subInformation.center.longitude)")
//            for (NSValue* point in subInformation.vertices) {
//                CLLocationCoordinate2D coordinate = [point MKCoordinateValue];
//                [subInfoString appendString:[NSString stringWithFormat:@"     (%f,%f)\n", coordinate.latitude, coordinate.longitude]];
//            }
            for point in subInformation.vertices {
                if let coordinate = point as? CLLocationCoordinate2D {
                    subInfoString.append("    (\(coordinate.latitude),\(coordinate.longitude)\n")
                }
            }
            subInfoString.append("-----------------\n")
        }
        return subInfoString
    }

    func getFlyZoneCategoryString(category:DJIFlyZoneCategory) -> String {
        switch category {
        case .warning:
            return "Warning"
        case .restricted:
            return "Restricted"
        case .authorization:
            return "Authorization"
        case .enhancedWarning:
            return "EnhancedWarning"
        default:
            return "Unknown"
        }
    }
}
