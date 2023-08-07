//
//  CameraMessageModel.swift
//  HejhomeIpc
//
//  Created by Dasom Kim on 2023/04/21.
//

import Foundation
import ThingSmartCameraKit

public class CameraMessagModel: NSObject {
    public var dateTime: Date?
    public var msgTypeContent: String = ""
    public var attachPic: String = ""
    public var msgSrcId: String = ""
    public var msgContent: String = ""
    public var msgTitle: String = ""
    public var msgId: String = ""
    public var msgCode: String = ""
    public var time: Int = 0
//    var attachVideos: []
//    var attachAudios: []
    
    init(model: ThingSmartCameraMessageModel) {
        super.init()
        self.dateTime = timestampToDate(model.time) //stringToDate(model.dateTime ?? "")
        self.msgTypeContent = model.msgTypeContent ?? ""
        self.attachPic = model.attachPic ?? ""
        self.msgSrcId = model.msgSrcId ?? ""
        self.msgContent = model.msgContent ?? ""
        self.msgTitle = model.msgTitle ?? ""
        self.msgId = model.msgId ?? ""
        self.msgCode = model.msgCode ?? ""
        self.time = model.time ?? 0
    }
}
