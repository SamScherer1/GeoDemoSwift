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
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var loginStateLabel: UILabel!
    @IBOutlet weak var unlockBtn: UIButton!
    @IBOutlet weak var flyZoneStatusLabel: UILabel!
    @IBOutlet weak var getUnlockButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var customUnlockButton: UIButton!
    @IBOutlet weak var showFlyZoneMessageTableView: UITableView!

    var mapController: MapController?
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
        }

        self.updateLoginStateTimer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(onUpdateLoginState), userInfo: nil, repeats: true)
        self.updateFlyZoneDataTimer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(onUpdateFlyZoneInfo), userInfo: nil, repeats: true)
        
        self.mapController?.updateFlyZonesInSurroundingArea()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
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
        self.title = "DJI GEO Demo"
        
        self.mapController = MapController(map: self.mapView)
        self.unlockFlyZoneIDs = [NSNumber]()
        self.unlockedFlyZoneInfos = [DJIFlyZoneInformation]()
        self.flyZoneInfoView = DJIScrollView.viewWith(viewController: self)//TODO: make this an init method?
        self.flyZoneInfoView?.isHidden = true
        self.flyZoneInfoView?.setDefaultSize()
    }

    //MARK: IBAction Methods
    @IBAction func onLoginButtonClicked(_ sender: Any) {
        DJISDKManager.userAccountManager().logIntoDJIUserAccount(withAuthorizationRequired: true) { (_:DJIUserAccountState, error:Error?) in
            if let error = error {
                DemoUtility.show(result: "GEO Login Error: \(error.localizedDescription)")
            } else {
                DemoUtility.show(result: "GEO Login Success")
            }
        }
    }
    
    @IBAction func onLogoutButtonClicked(_ sender: Any) {
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
        DJISDKManager.flyZoneManager()?.getUnlockedFlyZonesForAircraft(completion: { [weak self] (infos:[DJIFlyZoneInformation]?, error:Error?) in
            if let error = error {
                DemoUtility.show(result: "Get Unlock Error: \(error.localizedDescription)")
            } else {
                guard let infos = infos else { fatalError() }
                guard let self = self else { return }
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
        guard let flightController = DemoUtility.fetchFlightController() else { return }

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
            //TODO: remove when done testing...
            //textField.text = "-82.6222"
            //textField.text = "-82.7851948"
            textField.text = "-122.236164"
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        let startAction = UIAlertAction(title: "Start", style: .default) { (action:UIAlertAction) in
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
                    self?.mapController?.refreshMapViewRegion()
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

    @IBAction func conformButtonAction(_ sender: Any) {//TODO: rename appropriately... enableUnlockConfirmAction?
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
                if let idToUnlock = Int(content) {
                    self.unlockFlyZoneIDs.append(NSNumber(value: idToUnlock))
                }
            }
            
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
        let state = DJISDKManager.userAccountManager().userAccountState
        var stateString = "DJIUserAccountStatusUnknown"
        
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
            fallthrough
        @unknown default:
            stateString = "DJIUserAccountStatusUnknown"
        }

        self.loginStateLabel.text = stateString
    }
    
    @objc func onUpdateFlyZoneInfo() {
        self.showFlyZoneMessageTableView.reloadData()
    }
    //MARK: - DJIFlyZoneDelegate Method
    func flyZoneManager(_ manager: DJIFlyZoneManager, didUpdate state: DJIFlyZoneState) {
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
        guard let aircraftCoordinate = state.aircraftLocation?.coordinate else { return }
        if CLLocationCoordinate2DIsValid(aircraftCoordinate) {
            // Convert degrees to radians
            let heading = Float(state.attitude.yaw * Double.pi / 180.0)
            self.mapController?.updateAircraft(coordinate: aircraftCoordinate,
                                                   heading: heading)
        }
    }

    //MARK: - UITableViewDelgete
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mapController?.flyZones.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nullableCell = tableView.dequeueReusableCell(withIdentifier: "flyzone-id")
        let cell = nullableCell ?? UITableViewCell(style: .subtitle, reuseIdentifier: "flyzone-id")//TODO: I like this pattern for unwrapping all tableView cells

        if let flyZoneInfo = self.mapController?.flyZones[indexPath.row] {
            cell.textLabel?.text = "\(flyZoneInfo.flyZoneID):\(flyZoneInfo.category):\(flyZoneInfo.name)"
            cell.textLabel?.adjustsFontSizeToFitWidth = true
        }
        return cell
    }

    func getFlyZoneString(for category: DJIFlyZoneCategory) -> String {
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

    func string(for subFlyZoneInformations: [DJISubFlyZoneInformation]?) -> String? {//TODO: rename all names containing info, information
        guard let subFlyZoneInformations = subFlyZoneInformations else { return nil }
        var subInfoString = ""
        for subInformation in subFlyZoneInformations {
            subInfoString.append("-----------------\n")
            subInfoString.append("SubAreaID:\(subInformation.areaID)")
            subInfoString.append("Graphic:\( subInformation.shape == .cylinder ? "Circle": "Polygon")")
            subInfoString.append("MaximumFlightHeight:\(subInformation.maximumFlightHeight)")
            subInfoString.append("Radius:\(subInformation.radius)")
            subInfoString.append("Coordinate:\(subInformation.center.latitude),\(subInformation.center.longitude)")
            for point in subInformation.vertices {
                if let coordinate = point as? CLLocationCoordinate2D {
                    subInfoString.append("     \(coordinate.latitude),\(coordinate.longitude)\n")
                }
            }
            subInfoString.append("-----------------\n")
        }
        return subInfoString;
    }

    func string(for flyZoneInfo:DJIFlyZoneInformation) -> String {
        var infoString = ""
        infoString.append("ID:\(flyZoneInfo.flyZoneID)n")
        infoString.append("Name:\(flyZoneInfo.name)\n")
        infoString.append("Coordinate:(\(flyZoneInfo.center.latitude),\(flyZoneInfo.center.longitude)\n")
        infoString.append("Radius:\(flyZoneInfo.radius)\n")
        infoString.append("StartTime:\(flyZoneInfo.startTime), EndTime:\(flyZoneInfo.endTime)\n")
        infoString.append("unlockStartTime:\(flyZoneInfo.unlockStartTime), unlockEndTime:\(flyZoneInfo.unlockEndTime)\n")
        infoString.append("GEOZoneType:\(flyZoneInfo.type)")
        infoString.append("FlyZoneType:\(flyZoneInfo.shape == .cylinder ? "Cylinder" : "Cone")")
        infoString.append("FlyZoneCategory:\(self.getFlyZoneString(for: flyZoneInfo.category))\n")

        if flyZoneInfo.subFlyZones?.count ?? -1 > 0 {
            if let subInfoString = self.string(for: flyZoneInfo.subFlyZones) {
                infoString.append(subInfoString)
            }
        }
        
        return infoString
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.flyZoneInfoView?.isHidden = false
        self.flyZoneInfoView?.show()
        if let selectedFlyZone = self.mapController?.flyZones[indexPath.row] {
            self.flyZoneInfoView?.write(status: NSString(string:self.string(for: selectedFlyZone)))
        }
    }

    func flyZoneManager(_ manager: DJIFlyZoneManager,
                        didUpdateBasicDatabaseUpgradeProgress progress: Float,
                        andError error: Error?) { }
    
    func flyZoneManager(_ manager: DJIFlyZoneManager,
                        didUpdateFlyZoneNotification notification: DJIFlySafeNotification) { }
}
