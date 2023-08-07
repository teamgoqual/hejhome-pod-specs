//
//  SettingList.swift
//  ThingCameraSDKSampleApp
//
//  Created by Dasom Kim on 2023/04/10.
//

import Foundation
import ThingSmartCameraKit

public enum HejhomeCameraSettingMenu {
    case deviceName
    case room
    case notification
    case basicIndicator
    case basicFlip
    case basicPrivate
    case basicNightvision
    case basicPIR
    case motionDetect
    case motionSensitivity
    case decibelDetect
    case decibelSensitivity
    case doorbellSensitivity
    
    case sdCardStatus
    case sdCardRecordOn
    case sdCardRecordMode
    case sdCardStorageUsed
    case sdCardStorageRemaining
    case sdCardFormat
    
    case unpair
    
    case battery
    case lowBatteryAlarm
    case addChimeBell
    case existChime
    case bellTone
    case bellVolume
    case deleteBell
    
    case signalStrength
}

enum CameraSettingDpId: String {
    case doorbellRingExist = "155"
    case chimeRingTune = "156"
    case chimeRingVolume = "157"
    case battery = "145"
    case batteryPowerMode = "146"
    
    case lowBatteryAlarm = "147"
    case doorbellSensitivity = "152"
}

struct SettingProperty {
    var label: String
    var key: String
}

public enum NightVision: CaseIterable {
    case auto
    case off
    case on
    
    var value: SettingProperty {
        switch self {
        case .auto:
            return SettingProperty(label: "Auto", key: "0")
        case .off:
            return SettingProperty(label: "OFF", key: "1")
        case .on:
            return SettingProperty(label: "ON", key: "2")
        }
    }
    
    init(by: ThingSmartCameraNightvision?) {
        guard let ty = by else { self = .auto; return }
        
        switch ty {
        case .auto:
            self = .auto
        case .off:
            self = .off
        case .on:
            self = .on
        default:
            self = .auto
        }
    }
}

public enum BasicPIR: CaseIterable {
    case off
    case low
    case medium
    case high
    
    var value: SettingProperty {
        switch self {
        case .off:
            return SettingProperty(label: "OFF", key: "0")
        case .low:
            return SettingProperty(label: "Low", key: "1")
        case .medium:
            return SettingProperty(label: "Medium", key: "2")
        case .high:
            return SettingProperty(label: "High", key: "3")
        }
    }
    
    init(by: ThingSmartCameraPIR?) {
        guard let ty = by else { self = .off; return }
        
        switch ty {
        case .stateOff:
            self = .off
        case .stateLow:
            self = .low
        case .stateMedium:
            self = .medium
        case .stateHigh:
            self = .high
        default:
            self = .off
        }
    }
}

public enum MotionSensitivity : CaseIterable {
    case low
    case medium
    case high
    
    var value: SettingProperty {
        switch self {
        case .low:
            return SettingProperty(label: "낮음", key: "0")
        case .medium:
            return SettingProperty(label: "중간", key: "1")
        case .high:
            return SettingProperty(label: "높음", key: "2")
        }
    }
    
    init(by: ThingSmartCameraMotion?) {
        guard let ty = by else { self = .low; return }
        
        switch ty {
        case .low:
            self = .low
        case .medium:
            self = .medium
        case .high:
            self = .high
        default:
            self = .low
        }
    }
}

public enum DecibelSensitivity : CaseIterable {
    case low
    case high
    
    var value: SettingProperty {
        switch self {
        case .low:
            return SettingProperty(label: "낮음", key: "0")
        case .high:
            return SettingProperty(label: "높음", key: "1")
        }
    }
    
    init(by: ThingSmartCameraDecibel?) {
        guard let ty = by else { self = .low; return }
        
        switch ty {
        case .low:
            self = .low
        case .high:
            self = .high
        default:
            self = .low
        }
    }
}

public enum SdCardRecordMode : CaseIterable {
    case off
    case always
    case event
    
    var value: SettingProperty {
        switch self {
        case .off:
            return SettingProperty(label: "녹화 끄기", key: "0")
        case .event:
            return SettingProperty(label: "이벤트 녹화", key: "1")
        case .always:
            return SettingProperty(label: "연속 녹화", key: "2")
        
        }
    }
    
    init(by: ThingSmartCameraRecordMode?) {
        guard let ty = by else { self = .off; return }
        
        switch ty {
        case .always:
            self = .always
        case .event:
            self = .event
        default:
            self = .off
        }
    }
}


public enum BellTune : CaseIterable {
    case bell1
    case bell2
    case bell3
    case bell4
    
    var value: SettingProperty {
        switch self {
        case .bell1:
            return SettingProperty(label: "벨소리 1", key: "1")
        case .bell2:
            return SettingProperty(label: "벨소리 2", key: "2")
        case .bell3:
            return SettingProperty(label: "벨소리 3", key: "3")
        case .bell4:
            return SettingProperty(label: "벨소리 4", key: "4")
        
        }
    }
    
    init(by: String?) {
        guard let ty = by else { self = .bell1; return }
        
        switch ty {
        case "1":
            self = .bell1
        case "2":
            self = .bell2
        case "3":
            self = .bell3
        case "4":
            self = .bell4
        default:
            self = .bell1
        }
    }
}


public enum BellVolume : CaseIterable {
    case low
    case medium
    case high
    
    var value: SettingProperty {
        switch self {
        case .low:
            return SettingProperty(label: "작게", key: "10")
        case .medium:
            return SettingProperty(label: "보통", key: "20")
        case .high:
            return SettingProperty(label: "크게", key: "30")
        
        }
    }
    
    init(by: Int?) {
        guard let ty = by else { self = .medium; return }
        
        switch ty {
        case ...10:
            self = .low
        case 10...20:
            self = .medium
        default:
            self = .high
        }
    }
}

public enum DoorbellSensitivity : CaseIterable {
    case off
    case low
    case high
    
    var value: SettingProperty {
        switch self {
        case .off:
            return SettingProperty(label: "꺼짐", key: "0")
        case .low:
            return SettingProperty(label: "낮음", key: "1")
        case .high:
            return SettingProperty(label: "높음", key: "3")
        }
    }
    
    init(by: String?) {
        guard let ty = by else { self = .off; return }
        
        switch ty {
        case "1":
            self = .low
        case "3":
            self = .high
        default:
            self = .off
        }
    }
}

public enum SdCardStatus: CaseIterable {
    case normal
    case exception
    case memoryLow
    case formatting
    case none
    
    var value: SettingProperty {
        switch self {
        case .normal:
            return SettingProperty(label: "Normal", key: "1")
        case .exception:
            return SettingProperty(label: "Exception", key: "2")
        case .memoryLow:
            return SettingProperty(label: "Memory Low", key: "3")
        case .formatting:
            return SettingProperty(label: "Formatting", key: "4")
        case .none:
            return SettingProperty(label: "None", key: "5")
        }
    }
    
    init(by: ThingSmartCameraSDCardStatus?) {
        guard let ty = by else { self = .none; return }
        
        switch ty {
        case .normal:
            self = .normal
        case .exception:
            self = .exception
        case .memoryLow:
            self = .memoryLow
        case .formatting:
            self = .formatting
        case .none:
            self = .none
        default:
            self = .none
        }
    }
}


