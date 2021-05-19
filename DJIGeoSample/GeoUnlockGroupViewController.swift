//
//  GeoUnlockGroupViewController.swift
//  DJIGeoSample
//
//  Created by Samuel Scherer on 5/18/21.
//  Copyright © 2021 DJI. All rights reserved.
//

import Foundation
import UIKit

class GeoUnlockGroupViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
//    @property (weak, nonatomic) IBOutlet UITableView *userUnlockingTableView;
//    @property (strong, nonatomic) NSArray <DJIUnlockedZoneGroup *> *unlockedZoneGroups;
    var unlockedZoneGroups = [DJIUnlockedZoneGroup]() //TODO: use optional?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadUserUnlockGroupInfo()
    }

    func loadUserUnlockGroupInfo() {
//        __weak typeof(self) target = self;
//        [[DJISDKManager flyZoneManager] reloadUnlockedZoneGroupsFromServerWithCompletion:^(NSError * _Nullable error) {
//            if (target ==nil) return;
//            if (!error) {
//                [[DJISDKManager flyZoneManager] getLoadedUnlockedZoneGroupsWithCompletion:^(NSArray<DJIUnlockedZoneGroup *> * _Nullable groups, NSError * _Nullable error) {
//                    if (!error) {
//                        target.unlockZoneGroups = groups;
//                        [target.userUnlockingTableView reloadData];
//                    }
//                }];
//            }
//        }];
    }
    
    //TODO: class conforms to UITableView Delegate, DataSource protocols but doesn't declare it? Remove declaration when done?
//    - (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

//    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserUnlockingGroup"];
        let nullableCell = tableView.dequeueReusableCell(withIdentifier: "UserUnlockingGroup")
        let cell = nullableCell ?? UITableViewCell(style: .subtitle, reuseIdentifier: "UserUnlockingGroup")
        //        DJIUnlockedZoneGroup *group = self.unlockZoneGroups[indexPath.row];
        //        cell.textLabel.text = group.SN;
        //        cell.detailTextLabel.text = [NSString stringWithFormat:@"self-unlocking: %tu, custom-unlocking: %tu", group.selfUnlockedFlyZones.count, group.customUnlockZones.count];
        //
        let group = self.unlockedZoneGroups[indexPath.row]
        cell.textLabel?.text = group.sn
        cell.detailTextLabel?.text = "self-unlocking: \(group.selfUnlockedFlyZones.count), custom-unlocking: \(group.customUnlockZones.count)"
        
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.unlockedZoneGroups.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        DJIUnlockedZoneGroup *unlockedZoneGroup = self.unlockZoneGroups[indexPath.row];
        //        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //        DJIGeoGroupInfoViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"DJIGeoGroupInfoViewController"];
        //        vc.unlockedZoneGroup = unlockedZoneGroup;
        //        [self.navigationController pushViewController:vc animated:YES];
        let unlockedZoneGroup = self.unlockedZoneGroups[indexPath.row]
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if #available(iOS 13.0, *) {
            let vc : GeoGroupInfoViewController = mainStoryboard.instantiateViewController(identifier: "GeoGroupInfoViewController")
            vc.unlockedZoneGroup = unlockedZoneGroup
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            print("TODO")//TODO: docs say instantiateViewController is iOS 5.0+ not 13
        }
    }
}
