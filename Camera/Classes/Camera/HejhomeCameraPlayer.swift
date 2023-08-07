//
//  CameraPlayer.swift
//  ThingCameraSDKSampleApp
//
//  Created by Dasom Kim on 2023/04/10.
//

import Foundation
import ThingSmartDeviceKit
import ThingSmartCameraKit
import ThingSmartCameraBase

public protocol HejhomeCameraPlayerDelegate: AnyObject {
    func cameraInfoUpdate(_ setting: CameraSettingModel)
    func cameraDidConnected()
    func cameraDidBeginPreview()
    func cameraCaptureSuccess()
    func cameraDidStartRecord()
    func cameraDidStopRecord()
    func cameraPreviewFail(_ error: HejhomeCameraErrorCode)
    func cameraPreviewStatus(_ status: HejhomeCameraStatus)
}

public class HejhomeCameraPlayer: NSObject {

    public enum PtzDirection: UInt {
        case top = 0
        case right = 2
        case bottom = 4
        case left = 6
    }

    var parentView: UIView?
    private var videoView: CameraVideoView?
    private var ptzManager = ThingSmartPTZManager()
    var fullButton = UIButton(type: .system)
    var oriButton = UIButton(type: .system)

    var fullCustomView: UIView?


    weak var delegate: HejhomeCameraPlayerDelegate?

    private var device: ThingSmartDevice?
    private var cameraType: ThingSmartCameraType?

    open var isPlaying = false


    var connecting = false
    var connected = false
    var previewing = false
    var muted = true
    var talking = false
    var recording = false
    var hd = false

    public init(_ view: UIView, delegate: HejhomeCameraPlayerDelegate, fullView: UIView?) {
        super.init()

        self.parentView = view
        self.delegate = delegate
        self.fullCustomView = fullView

        cameraInit()
    }

    private func cameraInit() {
        if let current = Device.current, let devId = current.devId {
            device = ThingSmartDevice(deviceId: devId)
            device?.delegate = self

            afterCheckDoorBell {
                self.setCamara()
            }
        }
    }

    private func setCamara() {
        let model = CameraSettingModel.init(dic: device?.deviceModel.dps ?? [:], online: device?.deviceModel.isOnline ?? false)
        delegate?.cameraInfoUpdate(model)

        cameraType = ThingSmartCameraFactory.camera(withP2PType: device?.deviceModel.p2pType(), deviceId: device?.deviceModel.devId, delegate: self)

        ptzManager = ThingSmartPTZManager(deviceId: device?.deviceModel.devId ?? "")
        ptzManager.delegate = self

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

    private func checkDoorBell() -> Bool {
        if let isBell = self.device?.deviceModel.isLowPowerDevice(), isBell {
            return true
        } else {
            return false
        }
    }

    private func setCameraView() {
        setOriCameraView()
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
}

extension HejhomeCameraPlayer {

    public func isPTZControl() -> Bool {
        return ptzManager.isSupportPTZControl() == true
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

    public func play() {
        connect()
    }

    func _play() {

        guard isPlaying == false else { return }

        delegate?.cameraPreviewStatus(.PREVIEW_LOADING)
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

    public func startPtz(_ direction: PtzDirection) {
        guard ptzManager.isSupportPTZControl() == true else { return }

        let direction = ThingSmartPTZControlDirection(rawValue: direction.rawValue)
        ptzManager.startPTZ(with: direction!) { result in
            //
        } failure: { error in
            //
        }
    }

    public func stopPtz() {
        guard ptzManager.isSupportPTZControl() == true else { return }

        ptzManager.stopPTZ(success: { result in
            //
        }) { error in
            //
        }
    }

    public func fullView() {
        setFullsizeCameraView()
    }

    public func originalView() {
        setOriginalCameraView()
    }

    func stopPlayback() {
        if recording {
            cameraType?.stopRecord()
        }
        cameraType?.stopPlayback()
    }


    // 버튼 액션 함수
    @objc private func setOriCameraView() {
        setOriginalCameraView()
    }

    private func setOriginalCameraView() {
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

        guard let full = fullCustomView else { return }

        full.removeFromSuperview()
    }

    @objc private func setFullCameraView() {
        setFullsizeCameraView()
    }

    private func setFullsizeCameraView() {
        guard let videoView = videoView else { return }

        videoView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        videoView.removeFromSuperview()

        let window = UIApplication.shared.keyWindow!


        window.addSubview(videoView)
        videoView.frame = UIScreen.main.bounds
        videoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        videoView.translatesAutoresizingMaskIntoConstraints = true

        guard let full = fullCustomView else { return }

        full.translatesAutoresizingMaskIntoConstraints = false
        videoView.addSubview(full)

        NSLayoutConstraint.activate([
            full.centerXAnchor.constraint(equalTo: videoView.centerXAnchor),
            full.centerYAnchor.constraint(equalTo: videoView.centerYAnchor),
            full.widthAnchor.constraint(equalToConstant: videoView.bounds.width),
            full.heightAnchor.constraint(equalToConstant: videoView.bounds.height)
        ])
    }

}

extension HejhomeCameraPlayer: ThingSmartCameraDelegate {
    public func cameraDidConnected(_ camera: ThingSmartCameraType!) {

        connecting = false
        connected = true
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
            break
        case Thing_ERROR_START_PREVIEW_FAILED:
            previewing = false
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
        print("HejHomeSDK::: cameraDidBeginPreview")
        delegate?.cameraDidBeginPreview()
        delegate?.cameraPreviewStatus(.LOAD_SUCCESS)
        isPlaying = true
    }

    public func cameraDidStopPreview(_ camera: ThingSmartCameraType!) {
        previewing = false
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
        //
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

extension HejhomeCameraPlayer: ThingSmartDeviceDelegate {
    public func device(_ device: ThingSmartDevice, dpsUpdate dps: [AnyHashable : Any]) {
        //
        for key in dps.keys {
            if let key = key as? String, let dp = CameraDps(rawValue: key) {
                let model = CameraSettingModel.init(dic: device.deviceModel.dps, online: device.deviceModel.isOnline)
                print("HejHomeSDK::: Device dpsUpdate \(dp)")

                delegate?.cameraInfoUpdate(model)
            }
        }
    }
}



extension HejhomeCameraPlayer: ThingSmartPTZManagerDeletate {

}

