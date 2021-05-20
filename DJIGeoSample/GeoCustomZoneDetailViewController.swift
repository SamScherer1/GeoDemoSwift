//
//  GeoCustomZoneDetailViewController.swift
//  DJIGeoSample
//
//  Created by Samuel Scherer on 5/18/21.
//  Copyright © 2021 DJI. All rights reserved.
//

import Foundation
import DJISDK
import UIKit

class GeoCustomZoneDetailViewController : UIViewController {
    //public
    //@property (strong, nonatomic) DJICustomUnlockZone *customUnlockZone;
    var customUnlockZone : DJICustomUnlockZone? //TODO: make an initializer that uses the customUnlockZone
    //private
//    @property (weak, nonatomic) IBOutlet UILabel *nameLabel;
    @IBOutlet weak var nameLabel: UILabel!
    //    @property (weak, nonatomic) IBOutlet UILabel *idLabel;
    @IBOutlet weak var idLabel: UILabel!
    //    @property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
    @IBOutlet weak var latitudeLabel: UILabel!
    //    @property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
    @IBOutlet weak var longitudeLabel: UILabel!
    //    @property (weak, nonatomic) IBOutlet UILabel *radiusLabel;
    @IBOutlet weak var radiusLabel: UILabel!
    //    @property (weak, nonatomic) IBOutlet UILabel *startLabel;
    @IBOutlet weak var startLabel: UILabel!
    //    @property (weak, nonatomic) IBOutlet UILabel *endLabel;
    @IBOutlet weak var endLabel: UILabel!
    //    @property (weak, nonatomic) IBOutlet UILabel *expiredLabel;
    @IBOutlet weak var expiredLabel: UILabel!
    //    @property (weak, nonatomic) IBOutlet UIButton *enableZoneButton;
    @IBOutlet weak var enableZoneButton: UIButton!
    //    @property (strong, nonatomic) DJICustomUnlockZone *enabledCustomUnlockZone;
    var enabledCustomUnlockZone : DJICustomUnlockZone?
    
//    - (void)viewDidLoad {
    override func viewDidLoad() {
//        [super viewDidLoad];
        super.viewDidLoad()
        guard let customUnlockZone = self.customUnlockZone else { return }
//        self.nameLabel.text = self.customUnlockZone.name;
//        self.idLabel.text = [NSString stringWithFormat:@"%lu",self.customUnlockZone.ID];
//        self.latitudeLabel.text = [NSString stringWithFormat:@"%f",self.customUnlockZone.center.latitude];
//        self.longitudeLabel.text = [NSString stringWithFormat:@"%f",self.customUnlockZone.center.longitude];
//        self.radiusLabel.text = [NSString stringWithFormat:@"%f",self.customUnlockZone.radius];
//        self.startLabel.text = [NSString stringWithFormat:@"%@",self.customUnlockZone.startTime];
//        self.endLabel.text = [NSString stringWithFormat:@"%@",self.customUnlockZone.endTime];
        self.nameLabel.text = customUnlockZone.name
        self.idLabel.text = customUnlockZone.name
        self.latitudeLabel.text = "\(customUnlockZone)"
        self.longitudeLabel.text = "\(customUnlockZone.center.longitude)"
        self.radiusLabel.text = "\(customUnlockZone.radius)"
        self.startLabel.text = "\(customUnlockZone.startTime)"
        self.endLabel.text = "\(customUnlockZone.endTime)"

        if customUnlockZone.isExpired {
//            self.enableZoneButton.titleLabel.text = @"Expired";
//            self.expiredLabel.text = @"Yes";
//            self.enableZoneButton.enabled = NO;
            self.enableZoneButton.titleLabel?.text = "Expired"
            self.expiredLabel.text = "Yes"
            self.enableZoneButton.isEnabled = false
        } else {
//            self.expiredLabel.text = @"No";
//            __weak typeof(self) target = self;
//            [[DJISDKManager flyZoneManager] getEnabledCustomUnlockZoneWithCompletion:^(DJICustomUnlockZone * _Nullable zone, NSError * _Nullable error) {
//                if (target ==nil) return;
//                if (!error) {
//                    if (zone && zone.ID == target.customUnlockZone.ID) {
//                        [target.enableZoneButton setTitle:@"Disable" forState:UIControlStateNormal];
//                        target.enabledCustomUnlockZone = zone;
//                    } else {
//                        [target.enableZoneButton setTitle:@"Enable Zone" forState:UIControlStateNormal];
//                    }
//                    target.enableZoneButton.enabled = YES;
//                } else {
//                    //ShowResult(@"get enabled custom ulock zone failed:%@", error.description);
//                }
//            }];
            self.expiredLabel.text = "No"
            DJISDKManager.flyZoneManager()?.getEnabledCustomUnlockZone(completion: { [weak self] (zone:DJICustomUnlockZone?, error:Error?) in
                if let error = error {
                    showAlertWith(result: "get enabled custom ulock zone failed:\(error.localizedDescription)")
                    return
                }
                guard let self = self else { return }

                if let zone = zone, zone.id == self.customUnlockZone!.id {
                    self.enableZoneButton.setTitle("Disable", for: .normal)
                    self.enabledCustomUnlockZone = zone
                } else {
                    self.enableZoneButton.setTitle("Enable Zone", for: .normal)
                }
                self.enableZoneButton.isEnabled = true
            })
        }
    }

    @IBAction func enableZoneButtonPressed(_ sender: Any) {
//        __weak typeof(self) target = self;
//        if (self.enabledCustomUnlockZone) {
        if self.enabledCustomUnlockZone != nil{
//            [[DJISDKManager flyZoneManager] enableCustomUnlockZone:nil withCompletion:^(NSError * _Nullable error) {
//                if (error) {
//                    //ShowResult(@"Disable custom unlock zone failed:%@", error.description);
//                } else {
//                    [target.enableZoneButton setTitle:@"Enable Zone" forState:UIControlStateNormal];
//                    target.enabledCustomUnlockZone = nil;
//                    //ShowResult(@"Disable custom unlock zone succeed");
//                }
//            }];
            DJISDKManager.flyZoneManager()?.enable(nil, withCompletion: { [weak self](error:Error?) in
                if let error = error {
                    showAlertWith(result: "Disable custom unlock zone failed:\( error.localizedDescription)")
                    return
                }
                self?.enableZoneButton.setTitle("Enable Zone", for: .normal)
                self?.enabledCustomUnlockZone = nil
                showAlertWith(result: "Disable custom unlock zone success")
            })
        } else {
//            [[DJISDKManager flyZoneManager] enableCustomUnlockZone:self.customUnlockZone withCompletion:^(NSError * _Nullable error) {
//                if (target ==nil) return;
//                if (!error) {
//                    [target.enableZoneButton setTitle:@"Disable" forState:UIControlStateNormal];
//                    target.enabledCustomUnlockZone = self.customUnlockZone;
//                    //ShowResult(@"Enable custom unlock zone success");
//                } else {
//                    //ShowResult(@"Enable custom unlock zone Error: %@",error.description);
//                }
//            }];
            DJISDKManager.flyZoneManager()?.enable(self.customUnlockZone!, withCompletion: { [weak self](error:Error?) in
                if let error = error {
                    showAlertWith(result: "Enable custom unlock zone failed:\(error.localizedDescription)")
                    return
                }
                self?.enableZoneButton.setTitle("Disable", for: .normal)
                self?.enabledCustomUnlockZone = self?.customUnlockZone
                showAlertWith(result: "Enable custom unlock zone success")
            })
        }

    }
    
}
