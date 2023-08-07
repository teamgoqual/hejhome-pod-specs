//
//  CameraDps.swift
//  HejhomeIpc
//
//  Created by Dasom Kim on 2023/05/24.
//

import Foundation

enum CameraDps: String {
    case basicIndicator = "101"
    case basicFlip = "103"
    case basicPrivate = "105"
    case basicNightvision = "108"
    case motionSensitivity = "106"
    case decibelSensitivity = "140"
    
    case battery = "145"
    case powerMode = "146"
    case existChime = "155"
    case bellTone = "156"
    case bellVolume = "157"
    
    case lowBatteryAlarm = "147"
    case doorbellSensitivity = "152"
    
    case awake = "149"

//    case basicOsd = "104"
//    case sd_storge = "109"
//    case sd_status = "110"
//    case sd_format = "111"
//    case motion_record = "113"
//    case movement_detect_pic = "115"
//    case ptz_stop = "116"
//    case sd_format_state = "117"
//    case ptz_control = "119"
//    case motion_switch = "134"
//    case decibelDetect = "139"
//    case decibel_upload = "141"
//    case record_switch = "150"
//    case record_mode = "151"
//    case alarm_message = "185"
//    case ipc_mute_record = "197"
//    case initiative_message = "212"
}
