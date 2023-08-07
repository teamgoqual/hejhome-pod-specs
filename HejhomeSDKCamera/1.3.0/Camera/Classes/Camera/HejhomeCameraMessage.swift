//
//  CameraMessage.swift
//  HejhomeIpc
//
//  Created by Dasom Kim on 2023/04/21.
//

import Foundation
import ThingSmartCameraKit

public protocol HejhomeCameraMessageDelegate: AnyObject {
    func receivedCameraMessages(list: [CameraMessagModel], requestedDate: Date)
}

public class HejhomeCameraMessage: NSObject {
    var message = ThingSmartCameraMessage()
    var schemeModels: [ThingSmartCameraMessageSchemeModel] = []
    
    // delete
    var savedMessageList: [CameraMessagModel] = []
    var removeDateList: [Date] = []
    var deleteSuccessCallback: (() -> Void)?
    var deleteFailureCallback: ((Error?) -> Void)?

    weak var delegate: HejhomeCameraMessageDelegate?
    
    public init(delegate: HejhomeCameraMessageDelegate, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
        super.init()
        _init(delegate: delegate, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    public func getDetectedMessageList(date: Date?, offset: Int = 0, limit: Int = 100) {
        _getDetectedMessageList(date: date, offset: offset, limit: limit)
    }
    
    public func removeMessageList(_ list: [CameraMessagModel], onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
        _removeMessageList(list, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    public func removeAllMessageList(dates: [Date], onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
        savedMessageList = []
        removeDateList = dates
        deleteSuccessCallback = onSuccess
        deleteFailureCallback = onFailure
        
        for date in dates {
            _getDetectedAllMessageList(date: date)
        }
    }
    
}

extension HejhomeCameraMessage {
    private func _init(delegate: HejhomeCameraMessageDelegate, onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
        guard let current = Device.current else { return }
        guard let devId = current.devId else { return }
        
        self.delegate = delegate
        message = ThingSmartCameraMessage(deviceId: devId, timeZone: .current)
        
        message.getSchemes { arr in
            guard let arr = arr, arr.count > 0 else { return }
            self.schemeModels = arr
            onSuccess()

        } failure: { error in
            onFailure(error)
        }
    }
    
    private func _loadedAllData() {
//        print(savedMessageList.count);
        guard let success = deleteSuccessCallback, let failure = deleteFailureCallback else {
            return
        }
        
        _removeMessageList(savedMessageList, onSuccess: success, onFailure: failure)
        
    }
    
    private func _getDetectedAllMessageList(date: Date, offset: Int = 0, limit: Int = 100) {
        guard !schemeModels.isEmpty else { return }
        
        // 현재 캘린더와 타임존을 가져옴
        let calendar = Calendar.current
        let timeZone = TimeZone.current

        // 시작 시간: 주어진 날짜의 0시 0분 0초
        let startDate = calendar.startOfDay(for: date)

        // 끝 시간: 주어진 날짜의 23시 59분 59초
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let endDate = calendar.date(byAdding: components, to: startDate)!

        message.messages(withMessageCodes: schemeModels.first!.msgCodes, offset: offset, limit: limit, startTime: Int(startDate.timeIntervalSince1970), endTime: Int(endDate.timeIntervalSince1970)) { arr in
            guard let arr = arr, arr.count > 0 else {
                self.removeDateList.removeAll { $0 == date }
                if self.removeDateList.isEmpty {
                    self._loadedAllData()
                }
                return
            }
            
            let result = arr.map { CameraMessagModel(model: $0) }
            self.savedMessageList.append(contentsOf: result)
            self._getDetectedAllMessageList(date: date, offset: offset + limit, limit: limit)
            
        } failure: { error in
            //
        }
    }
    
    private func _getDetectedMessageList(date: Date?, offset: Int = 0, limit: Int = 100) {
        guard !schemeModels.isEmpty else { return }
        
        // 현재 캘린더와 타임존을 가져옴
        let calendar = Calendar.current
        let timeZone = TimeZone.current
        
        let selectedStartDate = date ?? Date(timeIntervalSince1970: 0)
        let selectedEndDate = date ?? Date()

        // 시작 시간: 주어진 날짜의 0시 0분 0초
        let startDate = calendar.startOfDay(for: selectedStartDate)

        // 끝 시간: 주어진 날짜의 23시 59분 59초
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let endDate = calendar.date(byAdding: components, to: startDate)!

        message.messages(withMessageCodes: schemeModels.first!.msgCodes, offset: offset, limit: limit, startTime: Int(startDate.timeIntervalSince1970), endTime: Int(endDate.timeIntervalSince1970)) { arr in
            guard let arr = arr, arr.count > 0 else {
                self.delegate?.receivedCameraMessages(list: [], requestedDate: startDate)
                return
            }
            
            let result = arr.map { CameraMessagModel(model: $0) }
            self.delegate?.receivedCameraMessages(list: result, requestedDate: startDate)
            
        } failure: { error in
            //
        }
    }
    
    private func _removeMessageList(_ list: [CameraMessagModel], onSuccess: @escaping () -> Void, onFailure: @escaping (Error?) -> Void) {
        let msgIdList: [String] = list.map { $0.msgId }
        
        savedMessageList = []
        deleteSuccessCallback = nil
        deleteFailureCallback = nil
        
        message.removeMessages(withMessageIds: msgIdList) {
            let delayInSeconds: Double = 2.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
                onSuccess()
            }
        } failure: { error in
            onFailure(error)
        }

    }
}
