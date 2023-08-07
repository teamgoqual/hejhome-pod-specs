//
//  Home.swift
//  ThingCameraSDKSampleApp
//
//  Created by Dasom Kim on 2023/04/03.
//

import Foundation
import ThingSmartDeviceKit

struct Home {
    static var current: ThingSmartHomeModel? {
        get {
            let defaults = UserDefaults.standard
            guard let homeID = defaults.string(forKey: "CurrentHome") else { return nil }
            guard let id = Int64(homeID)  else { return nil }
            return ThingSmartHome.init(homeId: id)?.homeModel
        }
        set {
            let defaults = UserDefaults.standard
            defaults.setValue(newValue?.homeId, forKey: "CurrentHome")
        }
    }
    
    static var homeId: Int64? {
        get {
            let defaults = UserDefaults.standard
            guard let homeId = defaults.string(forKey: "CurrentHome") else { return nil }
            guard let id = Int64(homeId)  else { return nil }
            return id
        }
        set {
            let defaults = UserDefaults.standard
            defaults.setValue(newValue, forKey: "CurrentHome")
        }
    }
}
