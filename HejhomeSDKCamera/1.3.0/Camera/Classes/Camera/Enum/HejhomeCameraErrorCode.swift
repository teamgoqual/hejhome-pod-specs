//
//  HejhomeCameraErrorCode.swift
//  HejhomeSDK
//
//  Created by Dasom Kim on 2023/07/17.
//

import Foundation

public enum HejhomeCameraErrorCode: Int, CustomStringConvertible {
    
    case CONNECT_FAILED = 1
    case CONNECT_DISCONNECT = 2
    case ENTER_PLAYBACK_FAILED = 3
    case START_PREVIEW_FAILED = 4
    case START_PLAYBACK_FAILED = 5
    case PAUSE_PLAYBACK_FAILED = 6
    case RESUME_PLAYBACK_FAILED = 7
    case ENABLE_MUTE_FAILED = 8
    case START_TALK_FAILED = 9
    case SNAPSHOOT_FAILED = 10
    case RECORD_FAILED = 11
    case ENABLE_HD_FAILED = 12
    case GET_HD_FAILED = 13
    case QUERY_RECORD_DAY_FAILED = 14
    case QUERY_TIMESLICE_FAILED = 15
    case QUERY_EVENTLIST_SIFT_FAILED = 16
    case SET_PLAYBACK_SPEED_FAILED = 17
    
    case DOORBELL_AWAKE_FAIL = 81
    
    case UNKNOWN = 99
    
    
    
    public var description: String {
        switch self {
        case .CONNECT_FAILED:               return "connect failed"
        case .CONNECT_DISCONNECT:           return "connect did disconnected"
        case .ENTER_PLAYBACK_FAILED:        return "connect playback channel failed"
        case .START_PREVIEW_FAILED:         return "preview failed"
        case .START_PLAYBACK_FAILED:        return "playback failed"
        case .PAUSE_PLAYBACK_FAILED:        return "pause playabck failed"
        case .RESUME_PLAYBACK_FAILED:       return "resume playabck failed"
        case .ENABLE_MUTE_FAILED:           return "mute failed"
        case .START_TALK_FAILED:            return "start talk to device failed"
        case .SNAPSHOOT_FAILED:             return "get screenshot failed"
        case .RECORD_FAILED:                return "record video failed"
        case .ENABLE_HD_FAILED:             return "set definition state failed"
        case .GET_HD_FAILED:                return "get definition state failed"
        case .QUERY_RECORD_DAY_FAILED:      return " query video record date failed"
        case .QUERY_TIMESLICE_FAILED:       return "query video record slice failed"
        case .QUERY_EVENTLIST_SIFT_FAILED:  return "query video event sift failed"
        case .SET_PLAYBACK_SPEED_FAILED:    return "set playabck speed failed"
            
        case .DOORBELL_AWAKE_FAIL:          return "Doorbell awake failure"
            
        case .UNKNOWN:                      return "Unknown Error"
        }
    }
}

