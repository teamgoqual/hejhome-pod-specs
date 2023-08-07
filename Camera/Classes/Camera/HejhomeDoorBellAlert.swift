//
//  HejhomeDoorBellAlert.swift
//  HejhomeIpc
//
//  Created by Dasom Kim on 2023/05/23.
//

import UIKit

open class HejhomeDoorBellAlert: UIViewController {
    
    var deviceId = ""
    var messageId = ""

    open override func viewDidLoad() {
        super.viewDidLoad()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        HejhomeDoorbellManager.shared.setData(deviceId: self.deviceId, messageId: self.messageId)
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        HejhomeDoorbellManager.shared.disconnect()
    }

}
