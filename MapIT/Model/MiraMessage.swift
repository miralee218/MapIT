//
//  MiraMessage.swift
//  MapIT
//
//  Created by Mira on 2019/5/6.
//  Copyright © 2019 AppWork. All rights reserved.
//

import Foundation
import UIKit
import SwiftMessages

class MiraMessage {
    class func contentOfMessage(title: String,
                                body: String,
                                color: UIColor?,
                                layout: MessageView.Layout,
                                theme: Theme) {
        let view = MessageView.viewFromNib(layout: layout)
        view.configureTheme(theme)
        view.backgroundView.backgroundColor = color
        view.configureContent(title: title, body: body)
        if body == "" {
            view.bodyLabel?.isHidden = true
        } else {
            view.bodyLabel?.isHidden = false
        }
        view.button?.isHidden = true
        SwiftMessages.show(view: view)
    }
    static func saveLocation() {
        contentOfMessage(title: "新增成功",
                         body: "可至清單中查看紀錄",
                         color: UIColor.SuccessSave,
                         layout: .cardView,
                         theme: .success)
    }
    static func saveTravel() {
        contentOfMessage(title: "新增成功",
                         body: "恭喜你～可至個人日誌中閱覽唷",
                         color: UIColor.SuccessSave,
                         layout: .cardView,
                         theme: .success)
    }
    static func shareSuccess() {
        contentOfMessage(title: "分享成功",
                         body: "",
                         color: UIColor.SuccessSave,
                         layout: .centeredView,
                         theme: .success)
    }
    static func shareFail() {
        contentOfMessage(title: "分享失敗",
                         body: "",
                         color: UIColor.SuccessDelete,
                         layout: .centeredView,
                         theme: .warning)
    }
    static func deleteSuccessfully() {
        contentOfMessage(title: "已刪除",
                         body: "",
                         color: UIColor.SuccessDelete,
                         layout: .centeredView,
                         theme: .success)
    }
    static func giveUpTravel() {
        contentOfMessage(title: "已捨棄此趟旅程全部紀錄",
                         body: "",
                         color: UIColor.SuccessDelete,
                         layout: .centeredView,
                         theme: .success)
    }

    static func updateSuccessfully() {
        contentOfMessage(title: "更新成功",
                         body: "",
                         color: UIColor.SuccessSave,
                         layout: .centeredView,
                         theme: .success)
    }
    static func noRouteRecord() {
        contentOfMessage(title: "提醒你",
                         body: "這趟旅程未錄製到任何路程喔！你想存還還是可以存啦...",
                         color: UIColor.SuccessDelete,
                         layout: .statusLine, theme: .success)
    }
}
