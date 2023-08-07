//
//  CameraSettingModel.swift
//  HejhomeIpc
//
//  Created by Dasom Kim on 2023/05/24.
//

import Foundation
import ThingSmartCameraKit

public class CameraSettingModel: NSObject {
    public let isOnline: Bool
    
    public let basicIndicator: Bool?
    public let basicFlip: Bool?
    public let basicPrivate: Bool?
    public let basicNightvision: NightVision?
    public let motionSensitivity: MotionSensitivity?
    public let decibelSensitivity: DecibelSensitivity?

    public let battery: Int?
    public let batteryPowerMode: Bool?
    public let existChime: Bool?
    public let bellTone: BellTune?
    public let bellVolume: BellVolume?
    public let bellVolumeValue: Int?
    
    init(dic: [AnyHashable: Any], online: Bool) {
        isOnline = online
        basicIndicator = dic[CameraDps.basicIndicator.rawValue] as? Bool
        basicFlip = dic[CameraDps.basicFlip.rawValue] as? Bool
        basicPrivate = dic[CameraDps.basicPrivate.rawValue] as? Bool
        battery = dic[CameraDps.battery.rawValue] as? Int
        batteryPowerMode = getBoolValue(dic[CameraDps.powerMode.rawValue] as? String)
        existChime = getBoolValue(dic[CameraDps.existChime.rawValue] as? String)
        bellVolumeValue = dic[CameraDps.bellVolume.rawValue] as? Int
        
        if let val = dic[CameraDps.basicNightvision.rawValue] as? ThingSmartCameraNightvision {
            basicNightvision = NightVision(by: val)
        } else {
            basicNightvision = nil
        }
        
        if let val = dic[CameraDps.motionSensitivity.rawValue] as? ThingSmartCameraMotion {
            motionSensitivity = MotionSensitivity(by: val)
        } else {
            motionSensitivity = nil
        }
        
        if let val = dic[CameraDps.decibelSensitivity.rawValue] as? ThingSmartCameraDecibel {
            decibelSensitivity = DecibelSensitivity(by: val)
        } else {
            decibelSensitivity = nil
        }
        
        if let val = dic[CameraDps.bellTone.rawValue] as? String {
            bellTone = BellTune(by: val)
        } else {
            bellTone = nil
        }
        
        if let val = dic[CameraDps.bellVolume.rawValue] as? Int {
            bellVolume = BellVolume(by: val)
        } else {
            bellVolume = nil
        }
        
    }
}
