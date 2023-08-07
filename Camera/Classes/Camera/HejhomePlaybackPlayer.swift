//
//  PlaybackPlayer.swift
//  ThingCameraSDKSampleApp
//
//  Created by Dasom Kim on 2023/04/10.
//

import Foundation
import ThingSmartDeviceKit
import ThingSmartCameraKit
import ThingSmartCameraBase
import ThingCameraUIKit
import YYModel

public protocol HejhomePlaybackPlayerDelegate: AnyObject {
    func cameraDidConnected()
    func cameraDidBeginPreview()
    func cameraCaptureSuccess()
    func cameraDidStartRecord()
    func cameraDidStopRecord()
    func cameraPlaybackAvailableDays(_ days: [NSNumber])
    func cameraPlaybackFail(_ error: HejhomeCameraErrorCode)
    func cameraPlaybackStatus(_ status: HejhomeCameraStatus)
    func cameraPlaybackDataBlank()
}

public class HejhomePlaybackPlayer: NSObject {
    
    var timelineView: ThingTimelineView?
    var timeLineLabel: ThingCameraTimeLabel?
    
    var parentView: UIView?
    var timelineWrapperView: UIView?
    weak var delegate: HejhomePlaybackPlayerDelegate?
    
    private var device: ThingSmartDevice?
    private var videoView: CameraVideoView?
    private var cameraType: ThingSmartCameraType?
    private var currentTimeLine: CameraTimeLineModel?
    
    var playTime: Double = 0
    
    // 타임라인 설정
    var timelineSetting = TimelineViewSetting()
    
    var fullCustomView: UIView?
    
    open var isPlaying = false
    
    var connecting = false
    var connected = false
    var playbacking = false
    var playbackPaused = false
    var muted = true
    var recording = false
    
    public init(_ view: UIView, timeline: UIView, timelineSetting: TimelineViewSetting? = nil, delegate: HejhomePlaybackPlayerDelegate, fullView: UIView?) {
        super.init()
        
        self.parentView = view
        self.timelineWrapperView = timeline
        if let timelineSetting = timelineSetting {
            self.timelineSetting = timelineSetting
        }
        self.delegate = delegate
        self.fullCustomView = fullView
        
        cameraInit()
    }
    
    @objc open func cameraInit() {
        
        if let current = Device.current, let devId = current.devId {
            device = ThingSmartDevice(deviceId: devId)
            cameraType = ThingSmartCameraFactory.camera(withP2PType: device?.deviceModel.p2pType(), deviceId: device?.deviceModel.devId, delegate: self)
            videoView = CameraVideoView(frame: CGRectZero)
            
            timeLineViewInit()
            
            if let device = device, !device.deviceModel.isOnline {
                delegate?.cameraPlaybackStatus(.OFFLINE)
            }
            
            if let v = videoView {
                v.renderView = cameraType?.videoView()
                connect()
            }
            
            setCameraView()

        }
    }
    
    public func retry() {
        disconnect()
        cameraType?.destory()
        cameraInit()
    }
    
    public func connect() {
        guard let cameraType = cameraType, !connected, !connecting else { return }

        delegate?.cameraPlaybackStatus(.ENCRYPTED_CHANNEL)
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
        guard isPlaying == false else { return }
        guard let timelineView = timelineView else { return }
        
        cameraType?.resumePlayback()
        timelineView.setCurrentTime(playTime, animated: true)
    }
    
    public func pause() {
        stopRecord()
        
        cameraType?.pausePlayback()
        
        isPlaying = false
    }
    
    func _stop() {
        stopRecord()

        isPlaying = false
        cameraType?.stopPlayback()
    }
    
    public func enableMute(_ isMute: Bool) {
        cameraType?.enableMute(isMute, for: .playback)
    }
    
    public func record() {
        if recording {
            return
        }
        if playbacking {
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
    
    public func playback() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)

        let components = dateString.components(separatedBy: "-")
        let year = UInt(components[0]) ?? 0
        let month = UInt(components[1]) ?? 0
        let day = UInt(components[2]) ?? 0
        
//        cameraType?.queryRecordDays(withYear: year, month: month)
        
        playback(year: year, month: month, day: day)
    }
    
    @objc open func getAvailableDays(year: UInt, month: UInt) {
        cameraType?.queryRecordDays(withYear: year, month: month)
    }
    
    @objc open func playback(year: UInt, month: UInt, day: UInt) {
        cameraType?.queryRecordTimeSlice(withYear: year, month: month, day: day)
    }
    
    @objc open func movePlayBackToPrevious30s() {
        guard let timelineView = timelineView else { return }
        
        var time = playTime - 30.0
        time = time < 0 ? 0 : time
        timelineView.setCurrentTime(time, animated: true)
    }
    
    @objc open func movePlayBackToNext30s() {
        guard let timelineView = timelineView else { return }
        
        var time = playTime + 30.0
        timelineView.setCurrentTime(time, animated: true)
    }
    
    
    func playback(_ time: TimeInterval, model: CameraTimeLineModel) {
        playTime = model.containsPlayTime(time) ? time : model.startTime
        cameraType?.startPlayback(Int(playTime), startTime: Int(model.startTime), stopTime: Int(model.endTime))
        playbacking = true
    }
    
    
}

extension HejhomePlaybackPlayer {
    
    public func fullView() {
        setFullsizeCameraView()
    }
    
    public func originalView() {
        setOriginalCameraView()
    }
    
    private func setCameraView() {
        
        setOriCameraView()
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

extension HejhomePlaybackPlayer {
    func timeLineViewInit() {
        guard let timelineWrapperView = timelineWrapperView else { return }
        
        timelineView = ThingTimelineView.init(frame: CGRectZero)
        
        guard let timelineView = timelineView else { return }
        timelineView.timeHeaderHeight = timelineSetting.headerHeight
        timelineView.showShortMark = true
        timelineView.spacePerUnit = timelineSetting.spacePerUnit
        timelineView.timeTextTop = timelineSetting.timeLabelTopMargin
        timelineView.delegate = self
        
        timelineView.backgroundColor = timelineSetting.backgroundColor
        timelineView.backgroundGradientColors = []
        timelineView.contentGradientColors = [timelineSetting.contentColor.cgColor]
//        timelineView.contentGradientLocations = [(0.0), (1.0)]
        timelineView.timeStringAttributes = [kCTFontAttributeName: UIFont.systemFont(ofSize: timelineSetting.timeLabelFontSize), kCTForegroundColorAttributeName: timelineSetting.timeLabelColor]
        timelineView.tickMarkColor = timelineSetting.tickBarColor
        timelineView.midLineColor = timelineSetting.midLineColor
        timelineView.timeZone = TimeZone.current
        
        timelineView.isMultipleTouchEnabled = true
        timelineView.isUserInteractionEnabled = true
        timelineWrapperView.addSubview(timelineView)
        
        timelineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timelineView.leadingAnchor.constraint(equalTo: timelineWrapperView.leadingAnchor, constant: 0),
            timelineView.trailingAnchor.constraint(equalTo: timelineWrapperView.trailingAnchor, constant: 0),
            timelineView.heightAnchor.constraint(equalToConstant: timelineSetting.viewHeight),
            timelineView.bottomAnchor.constraint(equalTo: timelineWrapperView.bottomAnchor, constant: 0),
        ])
        
        timeLineLabel = ThingCameraTimeLabel.init(frame: CGRect(x: Int(timelineView.bounds.size.width), y: Int(timelineView.frame.minY), width: 74, height: 22))
        timeLineLabel?.position = 2
        timeLineLabel?.isHidden = true
        timeLineLabel?.thing_backgroundColor = .black
        timeLineLabel?.textColor = .white
    }
}

extension HejhomePlaybackPlayer: ThingSmartCameraDelegate {
    public func cameraDidConnected(_ camera: ThingSmartCameraType!) {
        connecting = false
        connected = true
        
        delegate?.cameraPlaybackStatus(.PLAYBACK_LOADING)
        cameraType?.enterPlayback()
        
        delegate?.cameraDidConnected()
    }
    
    public func camera(_ camera: ThingSmartCameraType!, didOccurredErrorAtStep errStepCode: ThingCameraErrorCode, specificErrorCode errorCode: Int) {
        print("HejHomeSDK::: didOccurredErrorAtStep\(errorCode)")
        
        switch errStepCode {
        case Thing_ERROR_CONNECT_FAILED, Thing_ERROR_CONNECT_DISCONNECT:
            connecting = false
            connected = false

            break
        case Thing_ERROR_START_PLAYBACK_FAILED:
            playbacking = false
            break
        case Thing_ERROR_RECORD_FAILED:
            recording = false
            break
        case Thing_ERROR_SNAPSHOOT_FAILED, Thing_ERROR_RECORD_FAILED:
            break
        default:
            break
        }
        
        delegate?.cameraPlaybackStatus(.LOAD_FAIL)
        delegate?.cameraPlaybackFail(HejhomeCameraErrorCode(rawValue: Int(errStepCode.rawValue)) ?? .UNKNOWN)
    }
    
    public func cameraDisconnected(_ camera: ThingSmartCameraType!, specificErrorCode errorCode: Int) {
        print("HejHomeSDK::: cameraDisconnected")
        connecting = false
        connected = false
    }
    
    public func cameraDidBeginPlayback(_ camera: ThingSmartCameraType!) {
        isPlaying = true
        playbackPaused = false
        delegate?.cameraPlaybackStatus(.LOAD_SUCCESS)
        delegate?.cameraDidBeginPreview()
    }
    
    public func cameraPlaybackDidFinished(_ camera: ThingSmartCameraType!) {
        playbacking = false
        playbackPaused = false
    }
    
    public func cameraDidStopPlayback(_ camera: ThingSmartCameraType!) {
        //
        playbacking = false
        playbackPaused = false
    }
    
    public func cameraDidPausePlayback(_ camera: ThingSmartCameraType!) {
        //
        playbackPaused = true
    }
    
    public func cameraDidResumePlayback(_ camera: ThingSmartCameraType!) {
        //
        playbackPaused = false
    }
    
    public func cameraDidConnectPlaybackChannel(_ camera: ThingSmartCameraType!) {
        //
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
        delegate?.cameraPlaybackAvailableDays(days)
    }
    
    public func camera(_ camera: ThingSmartCameraType!, didReceiveTimeSliceQueryData timeSlices: [[AnyHashable : Any]]!) {
        //
        guard timeSlices.count > 0 else {
            delegate?.cameraPlaybackDataBlank()
            return
        }
        guard let timelineView = timelineView else { return }
        
        guard let datas = timeSlices as? [[String : Any]] else { return }
        
        var models:[CameraTimeLineModel] = []
        for data in datas {
            if let startTime = data["startTime"] as? Double, let endTime = data["endTime"] as? Double {
                let model = CameraTimeLineModel(startTime: startTime, endTime: endTime)
                models.append(model)
            }
        }
        
        timelineView.sourceModels = models
        timelineView.setCurrentTime(0, animated: true)
    }
    
    public func camera(_ camera: ThingSmartCameraType!, thing_didReceiveVideoFrame sampleBuffer: CMSampleBuffer!, frameInfo: ThingSmartVideoFrameInfo) {
        if playTime != Double(frameInfo.nTimeStamp) {
            playTime = Double(frameInfo.nTimeStamp)
            
            guard let timelineView = timelineView else { return }
            if !timelineView.isDecelerating, !timelineView.isDragging {
//                timelineView.setCurrentTime(self.playTime, animated: true)
            }
        }
    }
}

extension HejhomePlaybackPlayer: ThingTimelineViewDelegate {
    public func timelineViewDidScroll(_ timeLineView: ThingTimelineView!, time timeInterval: TimeInterval, isDragging: Bool) {
        timeLineLabel?.isHidden = false
        timeLineLabel?.timeStr = NSDate.thingsdk_timeString(withTimeInterval: timeInterval, timeZone: TimeZone.current)
    }
    
    public func timelineView(_ timeLineView: ThingTimelineView!, didEndScrollingAtTime timeInterval: TimeInterval, in source: ThingTimelineViewSource!) {
        guard let source = source else { return }
        timeLineLabel?.isHidden = true
        playback(timeInterval, model: source as! CameraTimeLineModel)
    }
}
