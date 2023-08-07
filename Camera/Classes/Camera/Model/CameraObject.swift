//
//  CameraObject.swift
//  HejhomeSDK
//
//  Created by Dasom Kim on 2023/07/21.
//

import Foundation
import ThingSmartDeviceKit
import ThingSmartCameraKit
import ThingSmartCameraBase

@objc protocol HejhomeCameraDelegate: AnyObject {
    
    func cameraDidConnected()
    func cameraDidBeginPreview()
    func cameraCaptureSuccess()
    func cameraDidStartRecord()
    func cameraDidStopRecord()
    
    @objc optional func cameraInfoUpdate(_ setting: CameraSettingModel)
    @objc optional func cameraPreviewFail(_ error: Int, description: String)
    
    @objc optional func cameraPlaybackAvailableDays(_ days: [NSNumber])
    @objc optional func cameraPlaybackFail(_ error: Int, description: String)
    @objc optional func cameraPlaybackDataBlank()
}

class CameraObject: NSObject {
    static let shared = CameraObject()
    weak var delegate: HejhomeCameraDelegate?

    var device: ThingSmartDevice?
    var devId = Device.current?.devId {
        didSet {
            self.cameraInit()
        }
    }
    
    var cameraType: ThingSmartCameraType?
    
    var connecting = false
    var connected = false
    var previewing = false
    var muted = true
    var talking = false
    var recording = false
    var playbacking = false
    var playbackPaused = false
    
    public var isPlaying = false

    private func cameraInit() {
        if let current = Device.current, let devId = current.devId {
            device = ThingSmartDevice(deviceId: devId)
            device?.delegate = self

            afterCheckDoorBell {
                self.cameraType = ThingSmartCameraFactory.camera(withP2PType: self.device?.deviceModel.p2pType(), deviceId: self.device?.deviceModel.devId, delegate: self)
            }
        }
    }
}

// 도어벨 관련
extension CameraObject {
    private func afterCheckDoorBell(_ success: @escaping () -> ()) {
        if checkDoorBell() {
            self.device?.awake(success: success, failure: { error in
                self.delegate?.cameraPreviewFail?(HejhomeCameraErrorCode.DOORBELL_AWAKE_FAIL.rawValue, description: HejhomeCameraErrorCode.DOORBELL_AWAKE_FAIL.description)
            })
        } else {
            success()
        }
    }
    
    private func checkDoorBell() -> Bool {
        if let isBell = self.device?.deviceModel.isLowPowerDevice(), isBell {
            return true
        } else {
            return false
        }
    }

}

// 카메라 액션
extension CameraObject {
    
    public func retry() {
        afterCheckDoorBell {
            self.connect()
        }
    }
    
    public func connect() {
        guard let cameraType = self.cameraType, !connected, !connecting else { return }
        
        connecting = true
        cameraType.connect?(with: .auto)
    }
    
    public func disconnect() {
        guard let cameraType = cameraType else { return }
        _stop()
        
        stopPlayback()
        cameraType.disConnect()
        connected = false
        connecting = false
    }
    
    public func play() {
        connect()
    }
    
    func _play() {
        
        guard isPlaying == false else { return }
        
        cameraType?.startPreview()
        previewing = true
        
        enableMute(muted)
    }
    
    public func stop() {
        disconnect()
    }
    
    func _stop() {
        stopRecord()
        stopTalk()
        
        isPlaying = false
        cameraType?.stopPreview()
    }
    
    public func startTalk() {
        if !talking {
            cameraType?.startTalk()
            talking = true
        }
    }
    
    public func stopTalk() {
        if talking {
            cameraType?.stopTalk()
            talking = false
        }
    }
    
    public func enableMute(_ isMute: Bool) {
        cameraType?.enableMute(isMute, for: .preview)
    }
    
    public func record() {
        if recording {
            return
        }
        if previewing {
            cameraType?.startRecord()
            recording = true
        }
    }
    
    public func stopRecord() {
        if recording {
            cameraType?.stopRecord()
        }
    }
    
    public func capture() {
        cameraType?.snapShoot()
    }
    
    public func startPlayback() {

        //
    }
    
    public func stopPlayback() {
        if recording {
            cameraType?.stopRecord()
        }
        cameraType?.stopPlayback()
    }
}

// 디바이스 델리게이트
extension CameraObject: ThingSmartDeviceDelegate {
    public func device(_ device: ThingSmartDevice, dpsUpdate dps: [AnyHashable : Any]) {
        //
        for key in dps.keys {
            if let key = key as? String, let dp = CameraDps(rawValue: key) {
                let model = CameraSettingModel.init(dic: device.deviceModel.dps, online: device.deviceModel.isOnline)
                print("HejHomeSDK::: Device dpsUpdate \(dp)")
                
                delegate?.cameraInfoUpdate?(model)
            }
        }
    }
}

// 카메라 델리게이트
extension CameraObject: ThingSmartCameraDelegate {
    public func cameraDidConnected(_ camera: ThingSmartCameraType!) {
        
        connecting = false
        connected = true
        cameraType?.enterPlayback()
        _play()
        //
        print("HejHomeSDK::: cameraDidConnected")
        delegate?.cameraDidConnected()
    }
    
    public func camera(_ camera: ThingSmartCameraType!, didOccurredErrorAtStep errStepCode: ThingCameraErrorCode, specificErrorCode errorCode: Int) {
        //
        switch errStepCode {
        case Thing_ERROR_CONNECT_FAILED, Thing_ERROR_CONNECT_DISCONNECT:
            connecting = false
            connected = false
            
            cameraType?.destory()
            cameraInit()
            
            break
        case Thing_ERROR_START_PREVIEW_FAILED:
            previewing = false
            retry()
            break
        case Thing_ERROR_START_TALK_FAILED:
            talking = false
            break
        case Thing_ERROR_SNAPSHOOT_FAILED, Thing_ERROR_RECORD_FAILED:
            break
        default:
            if errorCode == -3 {
                connect()
            }
            break
        }
        
        isPlaying = false
        delegate?.cameraPreviewFail?(Int(errStepCode.rawValue), description: HejhomeCameraErrorCode(rawValue: Int(errStepCode.rawValue))?.description ?? "")
        print("HejHomeSDK::: didOccurredErrorAtStep\(errorCode)")
    }
    
    public func cameraDisconnected(_ camera: ThingSmartCameraType!, specificErrorCode errorCode: Int) {
        print("HejHomeSDK::: cameraDisconnected")
        connecting = false
        connected = false
    }
    
    public func cameraDidBeginPreview(_ camera: ThingSmartCameraType!) {
        print("HejHomeSDK::: cameraDidBeginPreview")
        delegate?.cameraDidBeginPreview()
        isPlaying = true
    }
    
    public func cameraDidStopPreview(_ camera: ThingSmartCameraType!) {
        previewing = false
    }
    
    
    public func cameraDidBeginPlayback(_ camera: ThingSmartCameraType!) {
        isPlaying = true
        playbackPaused = false
        delegate?.cameraDidBeginPreview()
    }
    
    public func cameraPlaybackDidFinished(_ camera: ThingSmartCameraType!) {
        playbacking = false
        playbackPaused = false
    }
    
    public func cameraDidStopPlayback(_ camera: ThingSmartCameraType!) {
        playbacking = false
        playbackPaused = false
    }
    
    public func cameraDidPausePlayback(_ camera: ThingSmartCameraType!) {
        playbackPaused = true
    }
    
    public func cameraDidResumePlayback(_ camera: ThingSmartCameraType!) {
        playbackPaused = false
    }
    
    public func cameraDidConnectPlaybackChannel(_ camera: ThingSmartCameraType!) {
        //
    }
    
    public func cameraDidBeginTalk(_ camera: ThingSmartCameraType!) {
        //
    }
    
    public func cameraDidStopTalk(_ camera: ThingSmartCameraType!) {
        talking = false
    }
    
    public func cameraSnapShootSuccess(_ camera: ThingSmartCameraType!) {
        //
        delegate?.cameraCaptureSuccess()
    }
    
    public func cameraDidStartRecord(_ camera: ThingSmartCameraType!) {
        //
        delegate?.cameraDidStartRecord()
    }
    
    public func cameraDidStopRecord(_ camera: ThingSmartCameraType!) {
        //
        recording = false
        delegate?.cameraDidStopRecord()
    }
    
    public func camera(_ camera: ThingSmartCameraType!, didReceiveRecordDayQueryData days: [NSNumber]!) {
        delegate?.cameraPlaybackAvailableDays?(days)
    }
    
    public func camera(_ camera: ThingSmartCameraType!, didReceiveTimeSliceQueryData timeSlices: [[AnyHashable : Any]]!) {
        //
        guard timeSlices.count > 0 else { return }
    }
    
    public func camera(_ camera: ThingSmartCameraType!, didReceiveMuteState isMute: Bool, playMode: ThingSmartCameraPlayMode) {
        if playMode == .preview {
            muted = isMute
        }
    }
}
