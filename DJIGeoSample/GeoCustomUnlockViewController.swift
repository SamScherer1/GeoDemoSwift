//
//  GeoCustomUnlockViewController.swift
//  DJIGeoSample
//
//  Created by Samuel Scherer on 5/3/21.
//  Copyright © 2021 DJI. All rights reserved.
//

import Foundation
import UIKit
import DJISDK


class GeoCustomUnlockViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
//    @property (weak, nonatomic) IBOutlet UITableView *customUnlockedZonesTableView;
    @IBOutlet weak var customUnlockedZonesTableView: UITableView!
    
//    @property (strong, nonatomic) NSArray <DJICustomUnlockZone *> *customUnlockZones;
    var customUnlockZones : [DJICustomUnlockZone]?
    
    required init?(coder: NSCoder) {
        //customUnlockZones = [DJICustomUnlockZone]()//TODO: uncomment? why's this here?
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadCustomUnlockInfo()
    }
    
    func loadCustomUnlockInfo() {
        guard let modelName = DJISDKManager.product()?.model else { return }
        if modelName == DJIAircraftModelNameInspire1 ||
           modelName == DJIAircraftModelNamePhantom3Professional ||
           modelName == DJIAircraftModelNameMatrice100 {
//            target.customUnlockZones = [[DJISDKManager flyZoneManager] getCustomUnlockZonesFromAircraft];
//            [target.customUnlockedZonesTableView reloadData];
            
            self.customUnlockZones = DJISDKManager.flyZoneManager()?.getCustomUnlockZonesFromAircraft()
            //self.customUnlockedZonesTableView.reloadData() //TODO: uncomment
            
        } else {
            DJISDKManager.flyZoneManager()?.syncUnlockedZoneGroupToAircraft(completion: { [weak self] (error:Error?) in
                if let error = error {
                    DemoUtility.show(result: "Sync custom unlock zones to aircraft failed: \(error.localizedDescription)")
                } else {
                    self?.customUnlockZones = DJISDKManager.flyZoneManager()?.getCustomUnlockZonesFromAircraft()
                    // [target.customUnlockedZonesTableView reloadData];//TODO: implement
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.customUnlockZones?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var optionalCell = tableView.dequeueReusableCell(withIdentifier: "CustomUnlock")
        if optionalCell == nil {
            optionalCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "CustomUnlock")
        }
        let cell = optionalCell!
        if let zone = self.customUnlockZones?[indexPath.row] {
            cell.textLabel?.text = zone.name
            cell.detailTextLabel?.text = "Lat: \(zone.center.latitude), Long: \(zone.center.longitude)"
        }
        return cell
    }
    
    
}
