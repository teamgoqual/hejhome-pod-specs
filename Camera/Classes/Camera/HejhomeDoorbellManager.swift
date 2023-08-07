//
//  HejhomeDoorbellAlertView.swift
//  HejhomeIpc
//
//  Created by Dasom Kim on 2023/05/23.
//

import Foundation
import ThingSmartDeviceKit
import ThingSmartCameraKit
import ThingSmartCameraBase

public protocol HejhomeDoorbellObserver: AnyObject {
    func doorBellCall(_ deviceId: String, messageId: String)
}

public protocol HejhomeDoorbellDelegate: AnyObject {
    func doorBellCallDidAnswered(_ isMe: Bool)
    func doorBellCallDidCanceled()
    func cameraDidConnected()
    func cameraDidBeginPreview()
    func cameraPreviewFail(_ error: HejhomeCameraErrorCode)
    func cameraPreviewStatus(_ status: HejhomeCameraStatus)
}

public class HejhomeDoorbellManager: NSObject {
    
    public static let shared = HejhomeDoorbellManager()
    
    var parentVc: HejhomeDoorBellAlert?
    var parentView: UIView?
    weak var delegate: HejhomeDoorbellDelegate?
    weak var observer: HejhomeDoorbellObserver?
    
    private var device: ThingSmartDevice?
    private var videoView: CameraVideoView?
    private var cameraType: ThingSmartCameraType?
    
    open var isPlaying = false
    
    var connecting = false
    var connected = false
    var muted = true
    var talking = false
    
    var backMute = true
    var backTalk = false
    
    private var deviceId = ""
    private var messageId = ""
    
    let manager = ThingSmartDoorBellManager.sharedInstance()
    
    override init() {
        super.init()
        
        guard let manager = manager else { return }
        
        manager.ignoreWhenCalling = true
        manager.doorbellRingTimeOut = 30
    }
    
    public func setView(_ view: UIView, delegate: HejhomeDoorbellDelegate) {
        
        self.parentView = view
        self.delegate = delegate
    }
    
    public func setData(deviceId: String, messageId: String) {
        self.deviceId = deviceId
        self.messageId = messageId
        
        self.retry()
    }
    
    private func cameraInit() {
        if let current = Device.current, let devId = current.devId {
            device = ThingSmartDevice(deviceId: devId)

            afterCheckDoorBell {
                self.setCamara()
            }
        }
    }
    
    private func setCamara() {
        cameraType = ThingSmartCameraFactory.camera(withP2PType: device?.deviceModel.p2pType(), deviceId: device?.deviceModel.devId, delegate: self)

        videoView = CameraVideoView(frame: CGRectZero)

        if let device = device, !device.deviceModel.isOnline {
            delegate?.cameraPreviewStatus(.OFFLINE)
        }
        
        if let v = videoView {
            v.renderView = cameraType?.videoView()
            connect()
        }
        setCameraView()
    }
    
    private func setCameraView() {
        guard let videoView = videoView else { return }
        guard let parentView = parentView else { return }
        
        videoView.transform = CGAffineTransform.identity
        videoView.removeFromSuperview()

        parentView.addSubview(videoView)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            videoView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 0),
            videoView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: 0),
            videoView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 0),
            videoView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: 0),
        ])
    }
    
    
    public func retry() {
        cameraType?.destory()
        cameraInit()
    }
    
    public func connect() {
        guard let cameraType = cameraType, !connected, !connecting else { return }

        delegate?.cameraPreviewStatus(.ENCRYPTED_CHANNEL)
        connecting = true
        cameraType.connect?(with: .auto)
    }
    
    public func disconnect() {
        guard let cameraType = cameraType else { return }
        _stop()

        cameraType.disConnect()
        connected = false
        connecting = false
    }
    
    public func pause() {
        backMute = muted
        backTalk = talking
        disconnect()
    }
    
    public func play() {
        connect()
    }

    func _play() {

        guard isPlaying == false else { return }

        delegate?.cameraPreviewStatus(.PREVIEW_LOADING)
        cameraType?.startPreview()

        enableMute(backMute)
        setTalk(backTalk)
    }

    public func stop() {
        disconnect()
    }

    func _stop() {
        stopTalk()

        isPlaying = false
        cameraType?.stopPreview()
    }
    
    func setTalk(_ status: Bool) {
        if status {
            startTalk()
        } else {
            stopTalk()
        }
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
        muted = isMute
        cameraType?.enableMute(isMute, for: .preview)
    }
    
    public func addObserver(_ vc: HejhomeDoorBellAlert, delegate: HejhomeDoorbellObserver) {
        parentVc = vc
        observer = delegate
        ThingSmartDoorBellManager.sharedInstance().add(self)
    }
    
    public func removeDoorbellObserver() {
        ThingSmartDoorBellManager.sharedInstance().remove(self)
    }
    
    public func hangupDoorBellCall() {
        guard !self.messageId.isEmpty else { return }
        ThingSmartDoorBellManager.sharedInstance().hangupDoorBellCall(self.messageId)
        disconnect()
    }
    
    public func refuseDoorBellCall() {
        if !self.messageId.isEmpty {
            ThingSmartDoorBellManager.sharedInstance().refuseDoorBellCall(self.messageId)
        }
        disconnect()
        cameraType?.disConnect()
        cameraType?.destory()
    }
    
    public func answerDoorBellCall() {
        
        cameraType?.getHD()
        cameraType?.enableMute(false, for: .preview)
        startTalk()
        
        ThingSmartDoorBellManager.sharedInstance().answerDoorBellCall(self.messageId)
    }
}

extension HejhomeDoorbellManager {
    
    private func checkDoorBell() -> Bool {
        if let isBell = self.device?.deviceModel.isLowPowerDevice(), isBell {
            return true
        } else {
            return false
        }
    }
    
    private func afterCheckDoorBell(_ success: @escaping () -> ()) {
        if checkDoorBell() {
            self.device?.awake(success: success, failure: { error in
                //
                self.delegate?.cameraPreviewFail(HejhomeCameraErrorCode.DOORBELL_AWAKE_FAIL)
            })
        } else {
            success()
        }
    }
    
    public func showAlert(_ devId: String, messageId: String) {
        self.messageId = messageId
        
        guard let parentVc = parentVc else { return }
        
        parentVc.deviceId = devId
        parentVc.messageId = messageId
        
        getMostTopViewController()?.present(parentVc, animated: false)
    }
}

extension HejhomeDoorbellManager: ThingSmartCameraDelegate {
    public func cameraDidConnected(_ camera: ThingSmartCameraType!) {
        
        connecting = false
        connected = true
        _play()
        //
        print("HejHomeSDK::: cameraDidConnected")
        delegate?.cameraDidConnected()

    }
    
    public func camera(_ camera: ThingSmartCameraType!, didOccurredErrorAtStep errStepCode: ThingCameraErrorCode, specificErrorCode errorCode: Int) {
        delegate?.cameraPreviewStatus(.LOAD_FAIL)
        delegate?.cameraPreviewFail(HejhomeCameraErrorCode(rawValue: Int(errStepCode.rawValue)) ?? .UNKNOWN)
        
        switch errStepCode {
        case Thing_ERROR_CONNECT_FAILED, Thing_ERROR_CONNECT_DISCONNECT:
            connecting = false
            connected = false
            break
        case Thing_ERROR_START_TALK_FAILED:
            talking = false
            break
        case Thing_ERROR_SNAPSHOOT_FAILED, Thing_ERROR_RECORD_FAILED:
            break
        default:
            break
        }

        isPlaying = false
        
        delegate?.cameraPreviewStatus(.LOAD_FAIL)
        delegate?.cameraPreviewFail(HejhomeCameraErrorCode(rawValue: Int(errStepCode.rawValue)) ?? .UNKNOWN)
        print("HejHomeSDK::: didOccurredErrorAtStep\(errorCode)")
    }
    
    public func cameraDisconnected(_ camera: ThingSmartCameraType!, specificErrorCode errorCode: Int) {
        
        print("HejHomeSDK::: cameraDisconnected")
        connecting = false
        connected = false
    }
    
    public func cameraDidBeginPreview(_ camera: ThingSmartCameraType!) {
        
        delegate?.cameraDidBeginPreview()
        delegate?.cameraPreviewStatus(.LOAD_SUCCESS)
        isPlaying = true
    }
    
    public func cameraDidStopTalk(_ camera: ThingSmartCameraType!) {
        talking = false
    }

}

extension HejhomeDoorbellManager: ThingSmartDoorBellObserver {
    public func doorBellCall(_ callModel: ThingSmartDoorBellCallModel!, didReceivedFromDevice deviceModel: ThingSmartDeviceModel!) {
        observer?.doorBellCall(callModel.devId, messageId: callModel.messageId)
    }
    
    public func doorBellCallDidAnswered(_ callModel: ThingSmartDoorBellCallModel!) {
        delegate?.doorBellCallDidAnswered(true)
    }
    
    public func doorBellCallDidRefuse(_ callModel: ThingSmartDoorBellCallModel!) {
        isPlaying = false
    }
    
    public func doorBellCallDidHangUp(_ callModel: ThingSmartDoorBellCallModel!) {
        isPlaying = false
    }
    
    public func doorBellCallDidAnswered(byOther callModel: ThingSmartDoorBellCallModel!) {
        delegate?.doorBellCallDidAnswered(false)
    }
    
    public func doorBellCallDidonPreviewSuccess(_ callModel: ThingSmartDoorBellCallModel!) {
        delegate?.cameraDidBeginPreview()
    }
    
    public func doorBellCallDidCanceled(_ callModel: ThingSmartDoorBellCallModel!, timeOut isTimeOut: Bool) {
        isPlaying = false
        delegate?.doorBellCallDidCanceled()
    }
}

