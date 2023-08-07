//
//  Device.swift
//  ThingCameraSDKSampleApp
//
//  Created by Dasom Kim on 2023/04/03.
//

import Foundation
import ThingSmartDeviceKit

// v1.0.9 미사용 - product id 는 업데이트 가능성 있어 api 로 관련 처리 변경
enum CameraProduct: String {
    case c1 = "tq765gwxwnie7vid"
    case c2 = "q3dhxbfn2qxyuapc"
    case c3 = "azgxfz2bqiwgxcf4"
    case c4 = "no4syopeedsswyat"
    case c5 = "p9pakmknriysibwn"
    case c6 = "avr7cttad41fykym"
    case c7 = "orjh5twn327yeyaj"
    case c8 = "goxlllmtaiuabwl8"
    case c9 = "ddicbhwjcuvfe2fp"
    case c10 = "idyonoduovx4pgwa"
    case c11 = "lgevr7s7pvgprvl1"
    case c12 = "rvd8fwbsrkt6qp1j"
    case c13 = "yrmctodrlfrdpqmq"
    case c14 = "55ce0vuibxa52dr0"
    case c15 = "chcmqzkvv4rvvvfh"
    case c16 = "jxaw8zzny9jcxtnx"
    case c17 = "joo5fxqzbiejgwnc"
}

public struct HejhomeDeviceModel: Codable {
    public var deviceId: String
    public var productId: String
    public var name: String
    public var homeId: Int64
}

struct Device {
    static var current: ThingSmartDeviceModel? {
        get {
            let defaults = UserDefaults.standard
            guard let deviceId = defaults.string(forKey: "CurrentDevice") else { return nil }
            return ThingSmartDevice(deviceId: deviceId)?.deviceModel
        }
        set {
            let defaults = UserDefaults.standard
            defaults.setValue(newValue?.devId, forKey: "CurrentDevice")
        }
    }
    
    static var deviceId: String {
        get {
            let defaults = UserDefaults.standard
            guard let deviceId = defaults.string(forKey: "CurrentDevice") else { return "" }
            return deviceId
        }
        set {
            let defaults = UserDefaults.standard
            defaults.setValue(newValue, forKey: "CurrentDevice")
        }
    }
    
    static var all: [HejhomeDeviceModel]? {
        get {
            let defaults = UserDefaults.standard
            guard let savedObject = defaults.object(forKey: "UserAllDevices") as? Data else { return nil }
            
            let decoder = JSONDecoder()
            guard let list = try? decoder.decode([HejhomeDeviceModel].self, from: savedObject) else { return nil }
            
            return list
            
        }
        set {
            let defaults = UserDefaults.standard
            let encoder = JSONEncoder()

            if let encoded = try? encoder.encode(newValue) {
                defaults.setValue(encoded, forKey: "UserAllDevices")
            }
        }
    }
}
