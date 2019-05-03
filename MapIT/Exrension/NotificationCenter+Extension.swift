//
//  NotificationCenter+Extension.swift
//  MapIT
//
//  Created by Mira on 2019/4/27.
//  Copyright © 2019 AppWork. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let reloadRecordList = Notification.Name("reloadRecordList")
    static let newTravel = Notification.Name("newTravel")
    static let addMark = Notification.Name("addMark")
    static let removeMark = Notification.Name("removeMark")
    static let reloadRouteTableView = Notification.Name("reloadRouteTableView")
}
