//
//  GeoDemoViewController.swift
//  DJIGeoSample
//
//  Created by Samuel Scherer on 5/12/21.
//  Copyright © 2021 DJI. All rights reserved.
//

import Foundation
import MapKit
import DJISDK

class GeoDemoViewController : UIViewController, DJIFlyZoneDelegate, DJIFlightControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //    @property (weak, nonatomic) IBOutlet MKMapView *mapView;
    @IBOutlet weak var mapView: MKMapView!
    //    @property (weak, nonatomic) IBOutlet UIButton *loginBtn;
    @IBOutlet weak var loginBtn: UIButton!
    //    @property (weak, nonatomic) IBOutlet UIButton *logoutBtn;
    @IBOutlet weak var logoutBtn: UIButton!
    //    @property (weak, nonatomic) IBOutlet UILabel *loginStateLabel;
    @IBOutlet weak var loginStateLabel: UILabel!
    //    @property (weak, nonatomic) IBOutlet UIButton *unlockBtn;
    @IBOutlet weak var unlockBtn: UIButton!
    //    @property (weak, nonatomic) IBOutlet UILabel *flyZoneStatusLabel;
    @IBOutlet weak var flyZoneStatusLabel: UILabel!
    //    @property (weak, nonatomic) IBOutlet UIButton *getUnlockButton;
    @IBOutlet weak var getUnlockButton: UIButton!
    //    @property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
    @IBOutlet weak var pickerView: UIPickerView!
    //    @property (weak, nonatomic) IBOutlet UIView *pickerContainerView;
    @IBOutlet weak var pickerContainerView: UIView!
    //    @property (weak, nonatomic) IBOutlet UIButton *customUnlockButton;
    @IBOutlet weak var customUnlockButton: UIButton!
    //    @property (weak, nonatomic) IBOutlet UITableView *showFlyZoneMessageTableView;
    @IBOutlet weak var showFlyZoneMessageTableView: UITableView!
    
    //
    //    @property (nonatomic, strong) MapController* djiMapViewController;
    //    @property (nonatomic, strong) NSTimer* updateLoginStateTimer;
    //    @property (nonatomic, strong) NSTimer* updateFlyZoneDataTimer;
    //    @property (nonatomic, strong) NSMutableArray<NSNumber *> * unlockFlyZoneIDs;
    //    @property (nonatomic, strong) NSMutableArray<DJIFlyZoneInformation *> * unlockedFlyZoneInfos;
    //    @property (nonatomic, strong) DJIFlyZoneInformation *selectedFlyZoneInfo;
    //    @property (nonatomic) BOOL isUnlockEnable;
    //    @property(nonatomic, strong) DJIScrollView *flyZoneInfoView;
    var mapViewController: MapViewController?//TODO: rename to mapController
    var updateLoginStateTimer : Timer?
    var updateFlyZoneDataTimer : Timer?
    var unlockFlyZoneIDs = [NSNumber]()
    var unlockedFlyZoneInfos : [DJIFlyZoneInformation]?
    var selectedFlyZoneInfo : DJIFlyZoneInformation?
    var isUnlockEnable = false //TODO: consider initial value...
    var flyZoneInfoView : DJIScrollView?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        self.title = "DJI GEO Demo"
        self.pickerContainerView.isHidden = true
        
        guard let aircraft = DemoUtility.fetchAircraft() else { return }
        
        aircraft.flightController?.delegate = self
        DJISDKManager.flyZoneManager()?.delegate = self
        self.initUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let aircraft = DemoUtility.fetchAircraft() {
            aircraft.flightController?.simulator?.setFlyZoneLimitationEnabled(true, withCompletion: { (error:Error?) in
                if let error = error {
                    DemoUtility.show(result: "setFlyZoneLimitationEnabled failed:\(error.localizedDescription)")
                } else {
                    print("setFlyZoneLimitationEnabled success")
                }
            })
            //TODO: originally commented??
//    //        if (!DJISDKManager.flyZoneManager.isCustomUnlockZoneSupported) {
//    //            self.customUnlockButton.hidden = NO;
//    //        } else {
//    //            self.customUnlockButton.hidden = YES;
//    //        }
        }
//
//        self.updateLoginStateTimer = [NSTimer scheduledTimerWithTimeInterval:4.0f target:self selector:@selector(onUpdateLoginState) userInfo:nil repeats:YES];
//        self.updateFlyZoneDataTimer = [NSTimer scheduledTimerWithTimeInterval:4.0f target:self selector:@selector(onUpdateFlyZoneInfo) userInfo:nil repeats:YES];
//
//        [self.djiMapViewController updateFlyZonesInSurroundingArea];
        self.updateLoginStateTimer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(onUpdateLoginState), userInfo: nil, repeats: true)
        self.updateFlyZoneDataTimer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(onUpdateFlyZoneInfo), userInfo: nil, repeats: true)
        
        self.mapViewController?.updateFlyZonesInSurroundingArea()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //        DJIAircraft* aircraft = [DemoUtility fetchAircraft];
        //
        //        [aircraft.flightController.simulator setFlyZoneLimitationEnabled:NO withCompletion:^(NSError * _Nullable error) {
        //            if (error) {
        //                //ShowResult(@"setFlyZoneLimitationEnabled failed:%@", error.description);
        //            } else {
        //                NSLog(@"setFlyZoneLimitationEnabled success");
        //            }
        //        }];
        //
        //        if (self.updateLoginStateTimer)
        //            self.updateLoginStateTimer = nil;
        //        if (self.updateFlyZoneDataTimer)
        //            self.updateFlyZoneDataTimer = nil;
        if let aircraft = DemoUtility.fetchAircraft() {
            aircraft.flightController?.simulator?.setFlyZoneLimitationEnabled(false, withCompletion: { (error:Error?) in
                if let error = error {
                    DemoUtility.show(result: "setFlyZoneLimitationEnabled failed:\(error.localizedDescription)")
                } else {
                    print("setFlyZoneLimitationEnabled success")
                }
            })
            self.updateLoginStateTimer = nil
            self.updateFlyZoneDataTimer = nil
        }
    }

    func initUI() {
        //        self.title = @"DJI GEO Demo";
        //
        //        self.djiMapViewController = [[DJIMapViewController alloc] initWithMap:self.mapView];
        //        self.unlockFlyZoneIDs = [[NSMutableArray alloc] init];
        //        self.unlockedFlyZoneInfos = [[NSMutableArray alloc] init];
        //        self.flyZoneInfoView = [DJIScrollView viewWithViewController:self];
        //        self.flyZoneInfoView.hidden = YES;
        //        [self.flyZoneInfoView setDefaultSize];
        self.title = "DJI GEO Demo"
        
        self.mapViewController = MapViewController(map: self.mapView)
        self.unlockFlyZoneIDs = [NSNumber]()
        self.unlockedFlyZoneInfos = [DJIFlyZoneInformation]()
        self.flyZoneInfoView = DJIScrollView.viewWith(viewController: self)//TODO: make this an init method?
        self.flyZoneInfoView?.isHidden = true
        self.flyZoneInfoView?.setDefaultSize()
    }

    //MARK: IBAction Methods
    @IBAction func onLoginButtonClicked(_ sender: Any) {
//        [[DJISDKManager userAccountManager] logIntoDJIUserAccountWithAuthorizationRequired:YES withCompletion:^(DJIUserAccountState status, NSError * _Nullable error) {
//            if (error) {
//                //ShowResult([NSString stringWithFormat:@"GEO Login Error: %@", error.description]);
//
//            } else {
//                //ShowResult(@"GEO Login Success");
//            }
//        }];
        DJISDKManager.userAccountManager().logIntoDJIUserAccount(withAuthorizationRequired: true) { (_:DJIUserAccountState, error:Error?) in
            if let error = error {
                DemoUtility.show(result: "GEO Login Error: \(error.localizedDescription)")
            } else {
                DemoUtility.show(result: "GEO Login Success")
            }
        }
    }
    
    @IBAction func onLogoutButtonClicked(_ sender: Any) {
        //        [[DJISDKManager userAccountManager] logOutOfDJIUserAccountWithCompletion:^(NSError * _Nullable error) {
        //            if (error) {
        //                //ShowResult(@"Login out error:%@", error.description);
        //            } else {
        //                //ShowResult(@"Login out success");
        //            }
        //        }];
        DJISDKManager.userAccountManager().logOutOfDJIUserAccount { (error:Error?) in
            if let error = error {
                DemoUtility.show(result: "Logout error: \(error.localizedDescription)")
            } else {
                DemoUtility.show(result: "Logout success")
            }
        }
    }
    
    @IBAction func onUnlockButtonClicked(_ sender: Any) {
        self.showFlyZoneIDInputView()
    }
    
    @IBAction func onGetUnlockButtonClicked(_ sender: Any) {
//        [[DJISDKManager flyZoneManager] getUnlockedFlyZonesForAircraftWithCompletion:^(NSArray<DJIFlyZoneInformation *> * _Nullable infos, NSError * _Nullable error) {
        DJISDKManager.flyZoneManager()?.getUnlockedFlyZonesForAircraft(completion: { [weak self] (infos:[DJIFlyZoneInformation]?, error:Error?) in
            if let error = error {
                DemoUtility.show(result: "Get Unlock Error: \(error.localizedDescription)")
            } else {
                guard let infos = infos else { fatalError() }
                guard let self = self else { return }
//                NSString* unlockInfo = [NSString stringWithFormat:@"unlock zone count = %lu\n", infos.count];
//
//                if ([target.unlockedFlyZoneInfos count] > 0) {
//                    [target.unlockedFlyZoneInfos removeAllObjects];
//                }
//                [target.unlockedFlyZoneInfos addObjectsFromArray:infos];
//
//                for (DJIFlyZoneInformation* info in infos) {
//                    unlockInfo = [unlockInfo stringByAppendingString:[NSString stringWithFormat:@"ID:%lu Name:%@ Begin:%@ end:%@\n", (unsigned long)info.flyZoneID, info.name, info.unlockStartTime, info.unlockEndTime]];
//                };
//                //ShowResult(@"%@", unlockInfo);
                var unlockInfo = "unlock zone count = \(infos.count) \n"
                self.unlockedFlyZoneInfos?.removeAll()
                self.unlockedFlyZoneInfos?.append(contentsOf: infos)
                for info in infos {
                    unlockInfo = unlockInfo + "ID:\(info.flyZoneID) Name:\(info.name) Begin:\(info.unlockStartTime) end:\(info.unlockEndTime)\n"
                }
                DemoUtility.show(result: unlockInfo)
            }
        })
    }
    
    @IBAction func onStartSimulatorButtonClicked(_ sender: Any) {
//        DJIFlightController* flightController = [DemoUtility fetchFlightController];
//        if (!flightController) {
//            return;
//        }
        guard let flightController = DemoUtility.fetchFlightController() else { return }
//
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Input coordinate" preferredStyle:UIAlertControllerStyleAlert];
//
        let alertController = UIAlertController(title: "", message: "Input coordinate", preferredStyle: .alert)
        alertController.addTextField { (textField:UITextField) in
            textField.placeholder = "latitude"
            //TODO: remove when done testing...
            //textField.text = "27.7736" //Pier
            //textField.text = "28.0373219" //Another st.pete authorization zone
            textField.text = "37.841586" //Oakland
        }
        alertController.addTextField { (textField:UITextField) in
            textField.placeholder = "longitude"
            //textField.text = "-82.6222" //TODO: remove when done testing...
            //textField.text = "-82.7851948"
            textField.text = "-122.236164"
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        let startAction = UIAlertAction(title: "Start", style: .default) { (action:UIAlertAction) in
//            UITextField* latTextField = alertController.textFields[0];
//            UITextField* lngTextField = alertController.textFields[1];
            guard let latitudeString = alertController.textFields?[0].text else { return }
            guard let longitudeString = alertController.textFields?[1].text else { return }
            guard let latitude = Double(latitudeString) else { return }
            guard let longitude = Double(longitudeString) else { return }

            let location = CLLocationCoordinate2DMake(latitude, longitude)
            
            flightController.simulator?.start(withLocation: location,
                                              updateFrequency: 20,
                                              gpsSatellitesNumber: 10,
                                              withCompletion: { [weak self] (error:Error?) in
                if let error = error {
                    DemoUtility.show(result: "Start simulator error: \(error.localizedDescription)")
                } else {
                    DemoUtility.show(result: "Start simulator success")
                    self?.mapViewController?.refreshMapViewRegion()
                }
            })
        }

        alertController.addAction(cancelAction)
        alertController.addAction(startAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onStopSimulatorButtonClicked(_ sender: Any) {
        guard let flightController = DemoUtility.fetchFlightController() else { return }
        
        flightController.simulator?.stop(completion: { (error:Error?) in
            if let error = error {
                DemoUtility.show(result: "Stop simulator error:\(error.localizedDescription)")
            } else {
                DemoUtility.show(result: "Stop simulator success")
            }
        })
    }

    @IBAction func enableUnlocking(_ sender: Any) {
        self.pickerContainerView.isHidden = false
        self.pickerView.reloadAllComponents()
    }

    @IBAction func conformButtonAction(_ sender: Any) {
        //        if (self.selectedFlyZoneInfo) {
        //            [self.selectedFlyZoneInfo setUnlockingEnabled:self.isUnlockEnable withCompletion:^(NSError * _Nullable error) {
        //
        //                if (error) {
        //                    //ShowResult(@"Set unlocking enabled failed %@", error.description);
        //                }else
        //                {
        //                    //ShowResult(@"Set unlocking enabled success");
        //                }
        //            }];
        //        }
        guard let selectedInfo = self.selectedFlyZoneInfo else { return }
        
        selectedInfo.setUnlockingEnabled(self.isUnlockEnable) { (error:Error?) in
            if let error = error {
                DemoUtility.show(result: "Set unlocking enabled failed: \(error.localizedDescription)")
            } else {
                DemoUtility.show(result: "Set unlocking enabled success")
            }
        }
    }

    @IBAction func cancelButtonAction(_ sender: Any) {
        self.pickerContainerView.isHidden = true
    }

    //MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        NSInteger rowNum = 0;
//
//        if (component == 0) {
//            rowNum = [self.unlockedFlyZoneInfos count];
//        } else if (component == 1){
//            rowNum = 2;
//        }
//        return rowNum;
        if component == 0 {
            if let unlockedFlyZoneInfoCount = self.unlockedFlyZoneInfos?.count {
                return unlockedFlyZoneInfoCount
            }
        } else if component == 1 {
            return 2
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var title = ""
        
        if component == 0 {
//            DJIFlyZoneInformation *infoObject = [self.unlockedFlyZoneInfos objectAtIndex:row];
//            title = [NSString stringWithFormat:@"%lu", (unsigned long)infoObject.flyZoneID];
            if let infoObject = self.unlockedFlyZoneInfos?[row] {
                title = "\(infoObject.flyZoneID)"
            }
        } else if component == 1 {
            title = row == 0 ? "YES" : "NO"
        }
        return title
    }
//
    //MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        if (component == 0) {
//            if ([self.unlockedFlyZoneInfos count] > row) {
//                self.selectedFlyZoneInfo = [self.unlockedFlyZoneInfos objectAtIndex:row];
//            }
//        } else if (component == 1) {
//            self.isUnlockEnable = [pickerView selectedRowInComponent:1] == 0 ? YES: NO;
//        }
        if component == 0 {
            if self.unlockedFlyZoneInfos?.count ?? 0 > row {
                if let flyZoneInfoToSelect = self.unlockedFlyZoneInfos?[row] {
                    self.selectedFlyZoneInfo = flyZoneInfoToSelect
                }
            }
        } else if component == 1 {
            self.isUnlockEnable = pickerView.selectedRow(inComponent: 1) == 0
        }
        
    }

    func showFlyZoneIDInputView() {//TODO: super long method, break up...
        let alertController = UIAlertController(title: "", message: "Input ID", preferredStyle: .alert)
        alertController.addTextField { (textField:UITextField) in
            textField.placeholder = "Input"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let continueAction = UIAlertAction(title: "Continue", style: .default) { [weak self] (action:UIAlertAction) in
            if let flyZoneIdText = alertController.textFields?[0].text  {
                let flyZoneID = NSNumber(nonretainedObject: Int(flyZoneIdText))
                self?.unlockFlyZoneIDs.append(flyZoneID)
            }
            self?.showFlyZoneIDInputView()
        }

        let unlockAction = UIAlertAction(title: "Unlock", style: .default) { [weak self] (action:UIAlertAction) in
            guard let self = self else { return }
            if let content = alertController.textFields?[0].text {
//                int flyZoneID = [content intValue];
//                [target.unlockFlyZoneIDs addObject:@(flyZoneID)];
                if let idToUnlock = Int(content) {
                    self.unlockFlyZoneIDs.append(NSNumber(value: idToUnlock))
                }
            }
            
//            [[DJISDKManager flyZoneManager] unlockFlyZones:target.unlockFlyZoneIDs withCompletion:^(NSError * _Nullable error) {
//
//                [target.unlockFlyZoneIDs removeAllObjects];
//
//                if (error) {
//                    //ShowResult(@"unlock fly zones failed%@", error.description);
//                } else {
//                    [[DJISDKManager flyZoneManager] getUnlockedFlyZonesForAircraftWithCompletion:^(NSArray<DJIFlyZoneInformation *> * _Nullable infos, NSError * _Nullable error) {
//                        if (error) {
//                            //ShowResult(@"get unlocked fly zone failed:%@", error.description);
//                        } else {
//                            NSString* resultMessage = [NSString stringWithFormat:@"unlock zone: %tu ", [infos count]];
//                            for (int i = 0; i < infos.count; ++i) {
//                                DJIFlyZoneInformation* info = [infos objectAtIndex:i];
//                                resultMessage = [resultMessage stringByAppendingString:[NSString stringWithFormat:@"\n ID:%lu Name:%@ Begin:%@ End:%@\n", (unsigned long)info.flyZoneID, info.name, info.unlockStartTime, info.unlockEndTime]];
//                            }
//                            //ShowResult(resultMessage);
//                        }
//                    }];
//                }
//            }];
            DJISDKManager.flyZoneManager()?.unlockFlyZones(self.unlockFlyZoneIDs, withCompletion: { (error:Error?) in
                self.unlockFlyZoneIDs.removeAll()
                
                if let error = error {
                    DemoUtility.show(result: "unlock fly zones failed: \(error.localizedDescription)")
                    return
                }
                DJISDKManager.flyZoneManager()?.getUnlockedFlyZonesForAircraft(completion: { (infos:[DJIFlyZoneInformation]?, error:Error?) in
                    if let error = error {
                        DemoUtility.show(result: "get unlocked fly zones failed: \(error.localizedDescription)")
                        return
                    }
                    guard let infos = infos else { fatalError() } //Should return at least an empty array if no error
                    var resultMessage = "Unlock Zones: \(infos.count)"
                    for info in infos {
                        resultMessage = resultMessage + "\n ID:\(info.flyZoneID) Name:\(info.name) Begin:\(info.unlockStartTime) End:\(info.unlockEndTime)\n"
                    }
                    DemoUtility.show(result: resultMessage)
                })

            })
        }

        alertController.addAction(cancelAction)
        alertController.addAction(continueAction)
        alertController.addAction(unlockAction)
        self.present(alertController, animated: true, completion: nil)
    }

    @objc func onUpdateLoginState() {
//
//        DJIUserAccountState state = [DJISDKManager userAccountManager].userAccountState;
//        NSString* stateString = @"DJIUserAccountStatusUnknown";
        let state = DJISDKManager.userAccountManager().userAccountState
        var stateString = "DJIUserAccountStatusUnknown"
//
//        switch (state) {
//            case DJIUserAccountStateNotLoggedIn:
//                break;
//            case DJIUserAccountStateNotAuthorized:
//                stateString = @"DJIUserAccountStatusNotVerified";
//                break;
//            case DJIUserAccountStateAuthorized:
//                stateString = @"DJIUserAccountStatusSuccessful";
//                break;
//            case DJIUserAccountStateTokenOutOfDate:
//                stateString = @"DJIUserAccountStatusTokenOutOfDate";
//                break;
//            default:
//                break;
//        }
        
        switch state {
        case .notLoggedIn:
            stateString = "DJIUserAccountStatusNotLoggedIn"
        case .notAuthorized:
            stateString = "DJIUserAccountStatusNotVerified"
        case .authorized:
            stateString = "DJIUserAccountStatusSuccessful"
        case .tokenOutOfDate:
            stateString = "DJIUserAccountStatusNotLoggedIn"
        case .unknown:
            stateString = "DJIUserAccountStatusUnknown"
        }

        self.loginStateLabel.text = stateString
    }
    
    @objc func onUpdateFlyZoneInfo() {
        self.showFlyZoneMessageTableView.reloadData()
    }
    //MARK: - DJIFlyZoneDelegate Method
    func flyZoneManager(_ manager: DJIFlyZoneManager, didUpdate state: DJIFlyZoneState) {
        //        NSString* flyZoneStatusString = @"Unknown";
        //        switch (state) {
        //            case DJIFlyZoneStateClear:
        //                flyZoneStatusString = @"NoRestriction";
        //                break;
        //            case DJIFlyZoneStateInWarningZone:
        //                flyZoneStatusString = @"AlreadyInWarningArea";
        //                break;
        //            case DJIFlyZoneStateNearRestrictedZone:
        //                flyZoneStatusString = @"ApproachingRestrictedArea";
        //                break;
        //            case DJIFlyZoneStateInRestrictedZone:
        //                flyZoneStatusString = @"AlreadyInRestrictedArea";
        //                break;
        //            default:
        //                break;
        //        }
        //
        //        [self.flyZoneStatusLabel setText:flyZoneStatusString];
        var flyZoneStatusString = "Unknown"
        switch state {
        case .clear:
            flyZoneStatusString = "NoRestriction"
        case .inWarningZone:
            fallthrough
        case .inWarningZoneWithHeightLimitation:
            flyZoneStatusString = "AlreadyInWarningArea"
        case .nearRestrictedZone:
            flyZoneStatusString = "ApproachingRestrictedArea"
        case .inRestrictedZone:
            flyZoneStatusString = "AlreadyInRestrictedArea"
        case .unknown:
            fallthrough
        @unknown default:
            flyZoneStatusString = "Unknown"
        }
        self.flyZoneStatusLabel.text = flyZoneStatusString
    }
    
    //MARK: - DJIFlightControllerDelegate Method
    func flightController(_ fc: DJIFlightController, didUpdate state: DJIFlightControllerState) {
//        if (CLLocationCoordinate2DIsValid(state.aircraftLocation.coordinate)) {
//            double heading = RADIAN(state.attitude.yaw);
//            //[self.djiMapViewController updateAircraftLocation:state.aircraftLocation.coordinate withHeading:heading];
//            [self.djiMapViewController updateAircraftWithCoordinate:state.aircraftLocation.coordinate heading:heading];
//        }
        guard let aircraftCoordinate = state.aircraftLocation?.coordinate else { return }
        if CLLocationCoordinate2DIsValid(aircraftCoordinate) {
            // Convert degrees to radians
            let heading = Float(state.attitude.yaw * Double.pi / 180.0)
            self.mapViewController?.updateAircraft(coordinate: aircraftCoordinate,
                                                   heading: heading)
        }
    }

    //MARK: - UITableViewDelgete
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mapViewController?.flyZones.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var nullableCell = tableView.dequeueReusableCell(withIdentifier: "flyzone-id")
        var cell = nullableCell ?? UITableViewCell(style: .subtitle, reuseIdentifier: "flyzone-id")//TODO: I like this pattern for unwrapping all tableView cells
        
        //        DJIFlyZoneInformation* flyZoneInfo = self.djiMapViewController.flyZones[indexPath.row];
        //        cell.textLabel.text = [NSString stringWithFormat:@"%lu:%@:%@", (unsigned long)flyZoneInfo.flyZoneID, @(flyZoneInfo.category), flyZoneInfo.name];
        //        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        if let flyZoneInfo = self.mapViewController?.flyZones[indexPath.row] {
            cell.textLabel?.text = "\(flyZoneInfo.flyZoneID):\(flyZoneInfo.category):\(flyZoneInfo.name)"
            cell.textLabel?.adjustsFontSizeToFitWidth = true
        }
        return cell
    }

    func getFlyZoneString(for category: DJIFlyZoneCategory) -> String {
//        switch (category) {
//            case DJIFlyZoneCategoryWarning:
//                return @"Waring";
//            case DJIFlyZoneCategoryRestricted:
//                return @"Restricted";
//            case DJIFlyZoneCategoryAuthorization:
//                return @"Authorization";
//            case DJIFlyZoneCategoryEnhancedWarning:
//                return @"EnhancedWarning";
//            default:
//                break;
//        }
        switch category {
        case .warning:
            return "Warning"
        case .restricted:
            return "Restricted"
        case .authorization:
            return "Authorization"
        case .enhancedWarning:
            return "EnhancedWarning"
        case .unknown:
            fallthrough
        @unknown default:
            return "Unknown"
        }
    }
//
//    - (NSString*)formatSubFlyZoneInformtionString:(NSArray<DJISubFlyZoneInformation *> *)subFlyZoneInformations
    func string(for subFlyZoneInformations: [DJISubFlyZoneInformation]?) -> String? {//TODO: rename all names containing info, information
        guard let subFlyZoneInformations = subFlyZoneInformations else { return nil }
        var subInfoString = ""
        for subInformation in subFlyZoneInformations {
            subInfoString.append("-----------------\n")
            subInfoString.append("SubAreaID:\(subInformation.areaID)")
            subInfoString.append("Graphic:\( subInformation.shape == .cylinder ? "Circle": "Polygon")")
            subInfoString.append("MaximumFlightHeight:\(subInformation.maximumFlightHeight)")
//            [subInfoString appendString:[NSString stringWithFormat:@"Radius:%f\n", subInformation.radius]];
            subInfoString.append("Radius:\(subInformation.radius)")
//            [subInfoString appendString:[NSString stringWithFormat:@"Coordinate:(%f,%f)\n", subInformation.center.latitude, subInformation.center.longitude]];
            subInfoString.append("Coordinate:\(subInformation.center.latitude),\(subInformation.center.longitude)")
            for point in subInformation.vertices {
//                CLLocationCoordinate2D coordinate = [point MKCoordinateValue];
//                [subInfoString appendString:[NSString stringWithFormat:@"     (%f,%f)\n", coordinate.latitude, coordinate.longitude]];
                if let coordinate = point as? CLLocationCoordinate2D {
                    subInfoString.append("     \(coordinate.latitude),\(coordinate.longitude)\n")
                }
            }
            subInfoString.append("-----------------\n")

        }
        return subInfoString;
    }

//    - (NSString*)formatFlyZoneInformtionString:(DJIFlyZoneInformation*)information
    func string(for flyZoneInfo:DJIFlyZoneInformation) -> String {
//        NSMutableString* infoString = [[NSMutableString alloc] init];
//        if (information) {
//            [infoString appendString:[NSString stringWithFormat:@"ID:%lu\n", (unsigned long)information.flyZoneID]];
//            [infoString appendString:[NSString stringWithFormat:@"Name:%@\n", information.name]];
//            [infoString appendString:[NSString stringWithFormat:@"Radius:%f\n", information.radius]];

//        }
//        NSString *result = [NSString stringWithString:infoString];
//        return result;
        var infoString = ""
        infoString.append("ID:\(flyZoneInfo.flyZoneID)n")
        infoString.append("Name:\(flyZoneInfo.name)\n")
        //[infoString appendString:[NSString stringWithFormat:@"Coordinate:(%f,%f)\n", information.center.latitude, information.center.longitude]];
        infoString.append("Coordinate:(\(flyZoneInfo.center.latitude),\(flyZoneInfo.center.longitude)\n")
        infoString.append("Radius:\(flyZoneInfo.radius)\n")
        //            [infoString appendString:[NSString stringWithFormat:@"StartTime:%@, EndTime:%@\n", information.startTime, information.endTime]];
        infoString.append("StartTime:\(flyZoneInfo.startTime), EndTime:\(flyZoneInfo.endTime)\n")
        //            [infoString appendString:[NSString stringWithFormat:@"unlockStartTime:%@, unlockEndTime:%@\n", flyZoneInfo.unlockStartTime, flyZoneInfo.unlockEndTime]];
        infoString.append("unlockStartTime:\(flyZoneInfo.unlockStartTime), unlockEndTime:\(flyZoneInfo.unlockEndTime)\n")
        //            [infoString appendString:[NSString stringWithFormat:@"GEOZoneType:%d\n", flyZoneInfo.type]];
        infoString.append("GEOZoneType:\(flyZoneInfo.type)")
        //            [infoString appendString:[NSString stringWithFormat:@"FlyZoneType:%@\n", flyZoneInfo.shape == DJIFlyZoneShapeCylinder ? @"Cylinder" : @"Cone"]];
        infoString.append("FlyZoneType:\(flyZoneInfo.shape == .cylinder ? "Cylinder" : "Cone")")
        //            [infoString appendString:[NSString stringWithFormat:@"FlyZoneCategory:%@\n",[self getFlyZoneCategoryString:flyZoneInfo.category]]];
        infoString.append("FlyZoneCategory:\(self.getFlyZoneString(for: flyZoneInfo.category))\n")

        if flyZoneInfo.subFlyZones?.count ?? -1 > 0 {
//                NSString* subInfoString = [self formatSubFlyZoneInformtionString:information.subFlyZones];
//                [infoString appendString:subInfoString];
            if let subInfoString = self.string(for: flyZoneInfo.subFlyZones) {
                infoString.append(subInfoString)
            }
        }
        
        return infoString
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        self.flyZoneInfoView.hidden = NO;
        //        [self.flyZoneInfoView show];
        //        DJIFlyZoneInformation* information = self.djiMapViewController.flyZones[indexPath.row];
        //        [self.flyZoneInfoView writeWithStatus:[self formatFlyZoneInformtionString:information]];
        self.flyZoneInfoView?.isHidden = false
        self.flyZoneInfoView?.show()
        if let information = self.mapViewController?.flyZones[indexPath.row] {
            self.flyZoneInfoView?.write(status: NSString(string:self.string(for: information)))
        }
    }

    func flyZoneManager(_ manager: DJIFlyZoneManager, didUpdateBasicDatabaseUpgradeProgress progress: Float, andError error: Error?) {
        //TODO: unused?
    }
    
    func flyZoneManager(_ manager: DJIFlyZoneManager, didUpdateFlyZoneNotification notification: DJIFlySafeNotification) {
        //TODO: unused?
    }
}
