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
    static func saveLocation() {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.success)
        view.backgroundView.backgroundColor = UIColor.SuccessSave
        view.configureContent(title: "新增成功", body: "可至清單中查看紀錄")
        view.button?.isHidden = true
        SwiftMessages.show(view: view)
    }
    static func saveTravel() {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.success)
        view.backgroundView.backgroundColor = UIColor.SuccessSave
        view.configureContent(title: "新增成功", body: "恭喜你～可至個人日誌中閱覽唷")
        view.button?.isHidden = true
        SwiftMessages.show(view: view)
    }
    static func deleteSuccessfully() {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.success)
        view.backgroundView.backgroundColor = UIColor.SuccessDelete
        view.configureContent(title: "已刪除", body: "")
        view.bodyLabel?.isHidden = true
        view.button?.isHidden = true
        SwiftMessages.show(view: view)
    }
    static func giveUpTravel() {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.success)
        view.backgroundView.backgroundColor = UIColor.SuccessDelete
        view.configureContent(title: "已捨棄此趟旅程全部紀錄", body: "")
        view.bodyLabel?.isHidden = true
        view.button?.isHidden = true
        SwiftMessages.show(view: view)
    }

    static func updateSuccessfully() {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.success)
        view.backgroundView.backgroundColor = UIColor.SuccessSave
        view.configureContent(title: "更新成功", body: "")
        view.bodyLabel?.isHidden = true
        view.button?.isHidden = true
        SwiftMessages.show(view: view)
    }
}
