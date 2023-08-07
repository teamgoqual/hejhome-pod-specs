//
//  HejhomeCameraStatus.swift
//  HejhomeSDK
//
//  Created by Dasom Kim on 2023/07/26.
//

import Foundation

public enum HejhomeCameraStatus: Int, CustomStringConvertible {
    
    case LOAD_SUCCESS = 0
    case ENCRYPTED_CHANNEL = 1
    case PREVIEW_LOADING = 2
    case PLAYBACK_LOADING = 3
    case OFFLINE = 4
    case LOAD_FAIL = 99
    
    public var description: String {
        switch self {
        case .LOAD_SUCCESS:                 return "로딩 완료"
        case .ENCRYPTED_CHANNEL:            return "채널 암호화 중..."
        case .PREVIEW_LOADING:              return "화면 로딩 중..."
        case .PLAYBACK_LOADING:             return "녹화 화면 로딩 중..."
        case .OFFLINE:                      return "오프라인 상태"
        case .LOAD_FAIL:                    return "로딩 실패"
        
        }
    }
}

