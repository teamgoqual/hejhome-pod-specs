//
//  TimelineViewSetting.swift
//  HejhomeIpc
//
//  Created by Dasom Kim on 2023/05/24.
//

import Foundation

public class TimelineViewSetting: NSObject {
    
    public override init() {
        super.init()
    }
    
    public var headerHeight:CGFloat = 24
    public var spacePerUnit:CGFloat = 90
    public var timeLabelTopMargin:CGFloat = 6
    public var timeLabelFontSize:CGFloat = 9
    public var timeLabelColor:UIColor = .lightGray
    public var backgroundColor: UIColor = .white
    public var contentColor: UIColor = .lightGray
    public var tickBarColor: UIColor = .darkGray
    public var midLineColor: UIColor = .red
    public var viewHeight:CGFloat = 100
}
