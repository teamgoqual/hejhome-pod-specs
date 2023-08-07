//
//  CameraSetting.swift
//  ThingCameraSDKSampleApp
//
//  Created by Dasom Kim on 2023/04/10.
//

import Foundation
import ThingSmartCameraKit

public protocol HejhomeCameraSettingDelegate: AnyObject {
    func hejhomeSdcardStatus(_ status: SdCardStatus)
    func hejhomeSdcardFormatProgress(_ progress: Int)
}

public protocol HejhomeDoorbellSettingDelegate: AnyObject {
    func hejhomeDoorbellAwakeStatus(_ status: Bool)
}

public class HejhomeCameraSetting: NSObject {
    
    public weak var delegate: HejhomeCameraSettingDelegate?
    public weak var doorbellDelegate: HejhomeDoorbellSettingDelegate?
    
    var dpManager: ThingSmartCameraDPManager?
    var device: ThingSmartDevice?
    
    var indicatorOn: Bool?
    var flipOn: Bool?
    var privateOn: Bool?
    var nightvisionState: ThingSmartCameraNightvision?
    var pirState: ThingSmartCameraPIR?
    var motionDetectOn: Bool?
    var motionSensitivity: ThingSmartCameraMotion?
    var decibelDetectOn: Bool?
    var decibelSensitivity: ThingSmartCameraDecibel?
    var sdCardStatus: ThingSmartCameraSDCardStatus?
    var sdRecordOn: Bool?
    var recordMode: ThingSmartCameraRecordMode?
    var sdCardStorageTotal: Int?
    var sdCardStorageUsed: String?
    var sdCardStorageRemaining: String?
    var notification: Bool?
    
    var sdCardFormatSuccess:(() -> Void)?
    var sdCardFormatFailure:((Error?) -> Void)?
    
    var updateDp: String?
    var onDpUpdateSuccess:(() -> Void)?
    var onDpUpdateFailure:((Error?) -> Void)?
    
    var existChime: Bool = false
    var chimeOn: Bool = false
    var bellTone: String?
    var bellVolume: Int?
    var bellVolumeSaved: Int?
    var battery: Int?
    var batteryPowerMode: Bool?
    var signal: String?
    var lowBatteryAlarm: Int?
    var doorbellSensitivity: String?
    
    var isDoorbell: Bool = false
    var doorbellAwakeStatus: Bool = false
    var doorbellAwakeAction:(() -> Void)?
    
    override public init() {
        super.init()
        
        refreshDevice()
        refreshData()
        awake()
    }
    
    func refreshDevice() {
        guard let current = Device.current else { return }
        guard let devId = current.devId else { return }
        dpManager = ThingSmartCameraDPManager(deviceId: devId)
        dpManager?.addObserver(self)
        
        guard let _ = dpManager else { return }
        
        device = ThingSmartDevice(deviceId: devId)
        device?.getWifiSignalStrength(success: {
            //
        })
        device?.delegate = self
        CameraObject.shared.devId = devId
    }
    
    public func refreshData() {
        refreshDevice()
        checkDoorBell()
        getDeviceInfo()
    }
    
    public func awake() {
        if isDoorbell {
            CameraObject.shared.connect()
            self.device?.awake(success: {
                //
            })
        }
    }
    
    public func disconnect() {
        CameraObject.shared.disconnect()
    }
    
    func sdCardFormatResult(_ status: Bool) {
        if status {
            if let success = self.sdCardFormatSuccess {
                success()
                self.sdCardFormatSuccess = nil
            }
        } else {
            if let failure = self.sdCardFormatFailure {
                failure(nil)
                self.sdCardFormatFailure = nil
            }
        }
    }
    
    func checkStatus(status: ThingSmartCameraSDCardStatus) {
        switch status {
        case .exception:
            break
        case .formatting:
            break
        case .none:
            return
        default:
            self.getStorageInfo({})
        }
    }

    func formatSDCard() {
        guard let dpManager = dpManager else { return }
        
        dpManager.setValue(true, forDP: .sdCardFormatDPName, success: { [weak self] _ in
            self?.handleFormatting()
        }) { _ in
            // Network error
        }
    }

    func handleFormatting() {
        DispatchQueue.global().async {
            // Query the formatting progress, because some manufacturers' devices will not automatically report the progress
            let status = self.getFormatStatus()
            DispatchQueue.main.async {
                if status >= 0, status < 100 {
                    self.handleFormatting()
                }else if status == 100 {
                    // After formatting successfully, query the capacity information of the device
                    self.getStorageInfo {
                        self.sdCardFormatResult(true)
                    }
                }else {
                    // Formatting failed
                    if status != -9999 {
                        self.sdCardFormatResult(false)
                    }
                }
            }
        }
    }

    func getFormatStatus() -> Int {
        guard let dpManager = dpManager else { return 0 }
        
        let semaphore = DispatchSemaphore.init(value: 0)
        var status = -9999
        dpManager.value(forDP: .sdCardFormatStateDPName, success: { result in
            status = result as! Int
            semaphore.signal()
        }) { _ in
            semaphore.signal()
        }
        // timeout
        let _ = semaphore.wait(timeout: DispatchTime(uptimeNanoseconds: 300 * NSEC_PER_SEC))
        return status
    }

    func getStorageInfo(_ callback: @escaping () -> Void) {
        guard let dpManager = dpManager else { return }
        
        dpManager.value(forDP: .sdCardStorageDPName, success: { result in
            if let result = result as? String {
                self.storageInfoParsing(result, callback: callback)
            }
            
        }) { _ in
            // Network error
        }
    }
    
    private func storageInfoParsing(_ result: String, callback: () -> Void) {
        let components = result.split(separator: "|")
        guard components.count == 3 else {
            // Data invalid
            return
        }
        
        let total = Int(components[0])
        let used = Double(components[1]) ?? 0.0
        let left = Double(components[2]) ?? 0.0
        
        self.sdCardStorageTotal = total
        self.sdCardStorageUsed = String(format: "%.2fG", used / 1024.0 / 1024.0)
        self.sdCardStorageRemaining = String(format: "%.2fG", left / 1024.0 / 1024.0)
        
        callback()
    }

    func changeToEventRecordMode() {
        guard let dpManager = dpManager else { return }
        
        guard dpManager.isSupportDP(.sdCardRecordDPName) else {
            return
        }
        let isRecordOn = dpManager.value(forDP: .sdCardRecordDPName) as! Bool
        guard dpManager.isSupportDP(.recordModeDPName), isRecordOn else {
            return
        }

        let recordMode = dpManager.value(forDP: .recordModeDPName) as! String
        if recordMode == ThingSmartCameraRecordMode.always.rawValue {
            dpManager.setValue(ThingSmartCameraRecordMode.event.rawValue, forDP: .recordModeDPName, success: { result in
                print("current recording mode is ", result as! String)
            }) { _ in
                // Network error
            }
        }

    }
    
    func callDpUpdateCallback(_ status: Bool, error: Error? = nil) {
        switch status {
        case true:
            if let success = self.onDpUpdateSuccess {
                success()
            }
            break
        case false:
            if let fail = self.onDpUpdateFailure {
                fail(error)
            }
            break
        }
        
        self.onDpUpdateSuccess = nil
        self.onDpUpdateFailure = nil
    }
    
    func setRecordStatus(_ status: Bool, value: Any) {
        guard let dpManager = dpManager else { return }
        dpManager.setValue(status, forDP: .sdCardRecordDPName, success: { result in
//            print("current recording mode is ", result as! String)
            
            if status {
                dpManager.setValue(value, forDP: .recordModeDPName) { result in
//                    print("Setting - success")
                    self.callDpUpdateCallback(true)
                    
                } failure: { error in
                    self.callDpUpdateCallback(false, error: error)
                }
            } else {
                self.callDpUpdateCallback(true)
            }
            
        }) { _ in
            // Network error
            self.callDpUpdateCallback(false, error: nil)
        }
    }

}

extension HejhomeCameraSetting {
    
    public func getSettingData(menu: HejhomeCameraSettingMenu) -> Any {
        guard let current = Device.current else { return "" }
        
        switch menu {
        case .deviceName:
            return current.name ?? ""
        case .room:
            return Home.current!.name ?? ""
        case .notification:
            return notification ?? false
        case .basicIndicator:
            return indicatorOn ?? false
        case .basicFlip:
            return flipOn ?? false
        case .basicPrivate:
            return privateOn ?? false
        case .basicNightvision:
            return NightVision(by: nightvisionState).value.label
        case .basicPIR:
            return BasicPIR(by: pirState).value.label
        case .motionDetect:
            return motionDetectOn ?? false
        case .motionSensitivity:
            return MotionSensitivity(by: motionSensitivity).value.label
        case .decibelDetect:
            return decibelDetectOn ?? false
        case .decibelSensitivity:
            return DecibelSensitivity(by: decibelSensitivity).value.label
        case .sdCardRecordMode:
            return (sdRecordOn ?? false) ? SdCardRecordMode(by: recordMode).value.label : SdCardRecordMode.off.value.label
        case .sdCardRecordOn:
            return sdRecordOn ?? false
        case .unpair:
            return ""
        case .sdCardStatus:
            return SdCardStatus(by: sdCardStatus).value.label
        case .sdCardStorageUsed:
            return sdCardStorageUsed ?? ""
        case .sdCardStorageRemaining:
            return sdCardStorageRemaining ?? ""
        case .sdCardFormat:
            return ""
        case .existChime:
            return chimeOn
        case .bellTone:
            return BellTune(by: bellTone).value.label
        case .bellVolume:
            return bellVolume ?? 0
        case .battery:
            let power = batteryPowerMode ?? false
            return "\(battery ?? 0)%\(power ? " 충전중" : "")"
        case .signalStrength:
            return signal ?? "-"
        case .addChimeBell, .deleteBell:
            return ""
        case .lowBatteryAlarm:
            return lowBatteryAlarm ?? 0
        case .doorbellSensitivity:
            return DoorbellSensitivity(by: doorbellSensitivity).value.label
        }
    }
    
    public func getSettingOptionArray(menu: HejhomeCameraSettingMenu) -> [(String, String)] {
        switch menu {
        case .basicNightvision:
            var arr: [(String, String)] = []
            for c in NightVision.allCases {
                arr.append((c.value.label, c.value.key))
            }
            return arr
        case .basicPIR:
            var arr: [(String, String)] = []
            for c in BasicPIR.allCases {
                arr.append((c.value.label, c.value.key))
            }
            return arr
        case .motionSensitivity:
            var arr: [(String, String)] = []
            for c in MotionSensitivity.allCases {
                arr.append((c.value.label, c.value.key))
            }
            return arr
        case .decibelSensitivity:
            var arr: [(String, String)] = []
            for c in DecibelSensitivity.allCases {
                arr.append((c.value.label, c.value.key))
            }
            return arr
        case .sdCardRecordMode:
            var arr: [(String, String)] = []
            for c in SdCardRecordMode.allCases {
                arr.append((c.value.label, c.value.key))
            }
            return arr
        case .bellTone:
            var arr: [(String, String)] = []
            for c in BellTune.allCases {
                arr.append((c.value.label, c.value.key))
            }
            return arr
        case .bellVolume:
            var arr: [(String, String)] = []
            for c in BellVolume.allCases {
                arr.append((c.value.label, c.value.key))
            }
            return arr
        case .doorbellSensitivity:
            var arr: [(String, String)] = []
            for c in DoorbellSensitivity.allCases {
                arr.append((c.value.label, c.value.key))
            }
            return arr
        default:
            return []
        }
    }
    
    public func getSettingSliderRange(menu: HejhomeCameraSettingMenu) -> (Float, Float) {
        switch menu {
        case .lowBatteryAlarm:
            return (10, 50)
        case .bellVolume:
            return (0, 100)
        default:
            return (0, 100)
        }
    }
    
    
    public func checkEnable(menu: HejhomeCameraSettingMenu) -> Bool {
        guard let dpManager = dpManager else { return false }
        
        switch menu {
        case .deviceName, .room, .notification, .unpair, .signalStrength:
            return true
        case .basicIndicator:
            return dpManager.isSupportDP(.basicIndicatorDPName)
        case .basicFlip:
            return dpManager.isSupportDP(.basicFlipDPName)
        case .basicPrivate:
            return dpManager.isSupportDP(.basicPrivateDPName)
        case .basicNightvision:
            return dpManager.isSupportDP(.basicNightvisionDPName)
        case .basicPIR:
            return dpManager.isSupportDP(.basicPIRDPName)
        case .motionDetect:
            return dpManager.isSupportDP(.motionDetectDPName)
        case .motionSensitivity:
            return dpManager.isSupportDP(.motionSensitivityDPName)
        case .decibelDetect:
            return dpManager.isSupportDP(.decibelDetectDPName)
        case .decibelSensitivity:
            return dpManager.isSupportDP(.decibelSensitivityDPName)
        case .sdCardStatus:
            return dpManager.isSupportDP(.sdCardStatusDPName)
        case .sdCardRecordOn:
            return dpManager.isSupportDP(.sdCardRecordDPName)
        case .sdCardRecordMode:
            return dpManager.isSupportDP(.recordModeDPName)
        case .sdCardStorageUsed, .sdCardStorageRemaining:
            return dpManager.isSupportDP(.sdCardStorageDPName)
        case .sdCardFormat:
            return dpManager.isSupportDP(.sdCardFormatDPName)
        case .battery, .lowBatteryAlarm, .doorbellSensitivity:
            return isDoorbell
        case .existChime, .bellTone, .bellVolume, .deleteBell:
            return isDoorbell && existChime
        case .addChimeBell:
            return isDoorbell && !existChime
        }
    }
    
    private func checkDoorBell() {
        
        if let isBell = self.device?.deviceModel.isLowPowerDevice(), isBell {
            getDoorBellValues()
            isDoorbell = true
        } else {
            isDoorbell = false
        }
    }
    
    private func getDoorBellValues() {
        let exist = getDpData(CameraSettingDpId.doorbellRingExist.rawValue) as? String
        let tune = getDpData(CameraSettingDpId.chimeRingTune.rawValue) as? String
        let volume = getDpData(CameraSettingDpId.chimeRingVolume.rawValue) as? Int ?? 0
        let bat = getDpData(CameraSettingDpId.battery.rawValue) as? Int ?? 0
        let power = getDpData(CameraSettingDpId.batteryPowerMode.rawValue) as? String
        let low = getDpData(CameraSettingDpId.lowBatteryAlarm.rawValue) as? Int ?? 0
        let sensitivity = getDpData(CameraSettingDpId.doorbellSensitivity.rawValue) as? String
        
        existChime = (exist == "1")
        chimeOn = existChime && volume > 0
        setChimeOn(chimeOn)
        bellTone = tune
        bellVolume = volume
        battery = bat
        lowBatteryAlarm = low
        batteryPowerMode = (power == "1")
        doorbellSensitivity = sensitivity
        
    }
    
    private func setChimeOn(_ value: Bool) {
        let defaults = UserDefaults.standard
        defaults.setValue(value, forKey: "HejhomeChimeOn")
    }
    
    private func getChimeOn() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "HejhomeChimeOn")

    }
    
    private func publishBasicDp(key: String, value: Any, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
        device?.publishDps([key:value], success: {
            onSuccess()
        }, failure: { error in
            onFailure(error)
        })
    }
    
    public func setSettingData(menu: HejhomeCameraSettingMenu, value: Any? = nil, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
        
        if isDoorbell, !doorbellAwakeStatus {
            self.device?.awake(success: {
            })
            self.doorbellAwakeAction = { self.setSettingData(menu: menu, value: value, onSuccess: onSuccess, onFailure: onFailure) }
            return
        }
        
        enum ActionType {
            case cameraDpSwitch
            case cameraDpOption
            case basicDp
            case none
        }
        
        var type = ActionType.none
        var dp: Any?
        var settingValue: Any?
        
        onDpUpdateSuccess = onSuccess
        onDpUpdateFailure = onFailure
        
        switch menu {
        // 일반형
        case .sdCardFormat:
            self.sdCardFormatSuccess = onSuccess
            self.sdCardFormatFailure = onFailure
            formatSDCard()
            break
        case .deleteBell:
            type = .basicDp
            dp = CameraSettingDpId.doorbellRingExist.rawValue
            settingValue = "0"
            
        case .addChimeBell:
            type = .basicDp
            dp = CameraSettingDpId.doorbellRingExist.rawValue
            settingValue = "1"
            
            break
        
        // 스위치형
        case .basicIndicator:
            type = .cameraDpSwitch
            dp = ThingSmartCameraDPKey.basicIndicatorDPName
            break
            
        case .basicFlip:
            type = .cameraDpSwitch
            dp = ThingSmartCameraDPKey.basicFlipDPName
            break
            
        case .basicPrivate:
            type = .cameraDpSwitch
            dp = ThingSmartCameraDPKey.basicPrivateDPName
            break
            
        case .motionDetect:
            type = .cameraDpSwitch
            dp = ThingSmartCameraDPKey.motionDetectDPName
            break
            
        case .decibelDetect:
            type = .cameraDpSwitch
            dp = ThingSmartCameraDPKey.decibelDetectDPName
            break
            
        case .notification:
            guard let value = value as? Bool else { return }
            setPushStatus(value)
            break
            
        case .existChime:
            type = .basicDp
            let on = getChimeOn()
            let volume = on ? 0 : bellVolumeSaved ?? 20
            bellVolumeSaved = on ? bellVolume : nil
            
            dp = CameraSettingDpId.chimeRingVolume.rawValue
            settingValue = volume
            self.setChimeOn(!on)
            break
        
        // 옵션형
        case .basicNightvision:
            type = .cameraDpOption
            dp = ThingSmartCameraDPKey.basicNightvisionDPName
            break
            
        case .basicPIR:
            type = .cameraDpOption
            dp = ThingSmartCameraDPKey.basicPIRDPName
            break
            
        case .motionSensitivity:
            type = .cameraDpOption
            dp = ThingSmartCameraDPKey.motionSensitivityDPName
            break
            
        case .decibelSensitivity:
            type = .cameraDpOption
            dp = ThingSmartCameraDPKey.decibelSensitivityDPName
            break
            
        case .sdCardRecordMode:
            guard let value = value else { return }
            setRecordStatus(value as! String != "0", value: value)
            break
            
        case .bellTone:
            type = .basicDp
            dp = CameraSettingDpId.chimeRingTune.rawValue
            settingValue = value
            break
            
        case .doorbellSensitivity:
            type = .basicDp
            dp = CameraSettingDpId.doorbellSensitivity.rawValue
            settingValue = value
            break
            
        // 슬라이드형
        case .bellVolume:
            type = .basicDp
            dp = CameraSettingDpId.chimeRingVolume.rawValue
            settingValue = value
            break
        case .lowBatteryAlarm:
            type = .basicDp
            dp = CameraSettingDpId.lowBatteryAlarm.rawValue
            settingValue = value
            break
            
        //
        case .unpair:
            device?.remove({
                onSuccess()
            }, failure: { error in
                onFailure(error)
            })
            break
        default:
            break
        }
        
        updateDp = dp as? String
        
        switch type {
        case .basicDp:
            guard let dp = dp as? String else { return }
            guard let settingValue = settingValue else { return }
            self.device?.publishDps([dp : settingValue], success: {
                //                onSuccess()
            }, failure: { error in
                onFailure(error)
            })
            break
        case .cameraDpSwitch:
            guard let dp = dp as? ThingSmartCameraDPKey else { return }
            guard let value = value as? Bool else { return }
            guard let dpManager = dpManager else { return }
            
            updateDp = dp.rawValue
            dpManager.setValue(value, forDP: dp) { result in
                //                onSuccess()
            } failure: { error in
                onFailure(error)
            }
            break
        case .cameraDpOption:
            guard let dp = dp as? ThingSmartCameraDPKey else { return }
            guard let value = value else { return }
            guard let dpManager = dpManager else { return }
            
            updateDp = dp.rawValue
            dpManager.setValue(value, forDP: dp) { result in
                //                onSuccess()
            } failure: { error in
                onFailure(error)
            }
            break
        case .none:
            break
        }
        
        
        
        
    }
    
    private func afterCheckDoorBell(_ success: @escaping () -> ()) {
        if isDoorbell {
            self.device?.awake(success: success, failure: { error in
            })
        } else {
            success()
        }
    }
    
    
    func getDeviceInfo() {
        guard let dpManager = dpManager else { return }
        
        if dpManager.isSupportDP(.basicIndicatorDPName) {
            indicatorOn = dpManager.value(forDP: .basicIndicatorDPName) as? Bool ?? false
        }
        
        if dpManager.isSupportDP(.basicFlipDPName) {
            flipOn = dpManager.value(forDP: .basicFlipDPName) as? Bool ?? false
        }
        
        if dpManager.isSupportDP(.basicPrivateDPName) {
            privateOn = dpManager.value(forDP: .basicPrivateDPName) as? Bool ?? false
        }
        
        if dpManager.isSupportDP(.basicNightvisionDPName) {
            nightvisionState = dpManager.value(forDP: .basicNightvisionDPName) as? ThingSmartCameraNightvision ?? .auto
        }
        
        if dpManager.isSupportDP(.basicPIRDPName) {
            pirState = dpManager.value(forDP: .basicPIRDPName) as? ThingSmartCameraPIR ?? .stateOff
        }
        
        if dpManager.isSupportDP(.motionDetectDPName) {
            motionDetectOn = dpManager.value(forDP: .motionDetectDPName) as? Bool ?? false
        }
        
        if dpManager.isSupportDP(.motionSensitivityDPName) {
            motionSensitivity = dpManager.value(forDP: .motionSensitivityDPName) as? ThingSmartCameraMotion ?? .low
        }
        
        if dpManager.isSupportDP(.decibelDetectDPName) {
            decibelDetectOn = dpManager.value(forDP: .decibelDetectDPName) as? Bool ?? false
        }
        
        if dpManager.isSupportDP(.decibelSensitivityDPName) {
            decibelSensitivity = dpManager.value(forDP: .decibelSensitivityDPName) as? ThingSmartCameraDecibel ?? .low
        }
        
        if dpManager.isSupportDP(.recordModeDPName) {
            recordMode = dpManager.value(forDP: .recordModeDPName) as? ThingSmartCameraRecordMode ?? .event
        }
        
        if dpManager.isSupportDP(.sdCardRecordDPName) {
            sdRecordOn = dpManager.value(forDP: .sdCardRecordDPName) as? Bool ?? false
        }
        
        if dpManager.isSupportDP(.sdCardStorageDPName) {
            getStorageInfo({})
        }
        
        if dpManager.isSupportDP(.sdCardStatusDPName) {
            
            sdCardStatus = ThingSmartCameraSDCardStatus(rawValue: dpManager.value(forDP: .sdCardStatusDPName) as? UInt ?? 5)
            
            let status = SdCardStatus(by: ThingSmartCameraSDCardStatus(rawValue: sdCardStatus?.rawValue ?? 5))
            delegate?.hejhomeSdcardStatus(status)
            checkStatus(status: sdCardStatus!)
        } else {
            delegate?.hejhomeSdcardStatus(SdCardStatus.none)
        }
        
        getPushStatus()
    }
}

extension HejhomeCameraSetting {
    func getPushStatus() {
        ThingSmartSDK.sharedInstance().getPushStatus { status in
            self.notification = status
        }
    }
    
    func setPushStatus(_ status: Bool) {
        ThingSmartSDK.sharedInstance().setPushStatusWithStatus(status) {
            self.notification = status
            print("success!")
        }
    }
}

extension HejhomeCameraSetting: ThingSmartCameraDPObserver {
    public func cameraDPDidUpdate(_ manager: ThingSmartCameraDPManager!, dps dpsData: [AnyHashable : Any]!) {

        if let data = dpsData[ThingSmartCameraDPKey.sdCardStatusDPName] as? Int {
            let status = SdCardStatus(by: ThingSmartCameraSDCardStatus(rawValue: UInt(data)))
            
            print("HejHomeSDK::: sdCardStatus \(status.value.label)")
            delegate?.hejhomeSdcardStatus(status)
        }
        
        if let result = dpsData[ThingSmartCameraDPKey.sdCardStorageDPName] as? String {
            self.storageInfoParsing(result, callback: {
                if let total = sdCardStorageTotal, total > 0 {
                    print("HejHomeSDK::: sdCardStorage \(result)")
                }
            })
        }
        
        if let status = dpsData[ThingSmartCameraDPKey.wirelessAwakeDPName] as? Bool {
            self.doorbellAwakeStatus = status
            if let action = self.doorbellAwakeAction, status {
                action()
                self.doorbellAwakeAction = nil
            }
            
            doorbellDelegate?.hejhomeDoorbellAwakeStatus(status)
        }
        
        if let progress = dpsData[ThingSmartCameraDPKey.sdCardFormatStateDPName] as? Int {
            
            if progress == 100 {
                self.getStorageInfo {
                    self.sdCardFormatResult(true)
                }
            }
            if progress < 0, progress != -9999 {
                self.sdCardFormatResult(false)
            }

            print("HejHomeSDK::: sdCardFormat \(progress)%")
            delegate?.hejhomeSdcardFormatProgress(progress)
        }
    }
}

extension HejhomeCameraSetting {
    func getDpData(_ dp: String) -> Any? {
        guard let dic = self.device?.deviceModel.dps as? [String: AnyHashable] else { return nil }
        
        return dic[dp]
    }
}

extension HejhomeCameraSetting: ThingSmartDeviceDelegate {
    public func device(_ device: ThingSmartDevice, dpsUpdate dps: [AnyHashable : Any]) {
        //
        
        self.device = device
        for key in dps.keys {
            self.device?.deviceModel.dps[key] = dps[key]
            if let dp = updateDp, let keyString = key as? String, keyString == dp, let success = onDpUpdateSuccess {
                success()
                refreshData()
                onDpUpdateSuccess = nil
                onDpUpdateFailure = nil
            }
            
            if let key = key as? String, let dp = CameraDps(rawValue: key) {
                let model = CameraSettingModel.init(dic: device.deviceModel.dps, online: device.deviceModel.isOnline)
                print("HejHomeSDK::: Device dpsUpdate \(dp)")
                
                self.refreshData()
                
                break
//                delegate?.cameraInfoUpdate(model)
            }
        }
        
    }

    public func device(_ device: ThingSmartDevice, signal: String) {
        //
        print("HejHomeSDK::: Device Signal Stength \(signal)")
        self.signal = signal
    }
}
