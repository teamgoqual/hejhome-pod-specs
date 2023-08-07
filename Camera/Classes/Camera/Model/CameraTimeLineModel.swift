//
//  CameraTimeLineModel.swift
//  ThingCameraSDKSampleApp
//
//  Created by Dasom Kim on 2023/04/10.
//

import Foundation
import ThingCameraUIKit

class CameraTimeLineModel: NSObject, ThingTimelineViewSource {
    
    var startTime: Double
    var endTime: Double
    
    init(startTime: Double, endTime: Double) {
        self.startTime = startTime
        self.endTime = endTime
    }


    func containsPlayTime(_ time: Double) -> Bool {
        return time >= startTime && time < endTime
    }
    
    func startDate() -> Date {
        return Date.init(timeIntervalSince1970: startTime)
    }
    
    func endDate() -> Date {
        return Date.init(timeIntervalSince1970: endTime)
    }
    
    func startTimeInterval(since date: Date!) -> TimeInterval {
        return startDate().timeIntervalSince(date)
    }
    
    func stopTimeInterval(since date: Date!) -> TimeInterval {
        return endDate().timeIntervalSince(date)
    }
}
