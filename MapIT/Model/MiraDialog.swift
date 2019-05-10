//
//  MiraDialog.swift
//  MapIT
//
//  Created by Mira on 2019/5/8.
//  Copyright © 2019 AppWork. All rights reserved.
//

import Foundation
import PopupDialog

class MiraDialog {
    static func showDeleteDialog(animated: Bool = true, deleteHandler: @escaping (() -> Void), vc: UIViewController) {
        // Prepare the popup
        let title = "確定刪除?"
        let message = "若刪除紀錄，將無法再次回復唷QAQ"
        // Create the dialog
        let popup = PopupDialog(title: title,
                                message: message,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceUp,
                                tapGestureDismissal: true,
                                panGestureDismissal: true,
                                hideStatusBar: true) {
        }
        // Create first button
        let buttonOne = CancelButton(title: "取消") {
        }
        // Create second button
        let buttonTwo = DestructiveButton(title: "刪除") {
            deleteHandler()
        }
        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo])
        // Present dialog
        DispatchQueue.main.async {
            vc.present(popup, animated: animated, completion: nil)
        }
    }
    static func showDeleteTravelDialog(animated: Bool = true,
                                       deleteHandler: @escaping (() -> Void),
                                       vc: UIViewController) {
        // Prepare the popup
        let title = "確定捨棄紀錄?"
        let message = "若捨棄，你的心血都白費了喔QAQ"
        // Create the dialog
        let popup = PopupDialog(title: title,
                                message: message,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceUp,
                                tapGestureDismissal: true,
                                panGestureDismissal: true,
                                hideStatusBar: true) {
        }
        // Create first button
        let buttonOne = CancelButton(title: "取消") {
        }
        // Create second button
        let buttonTwo = DestructiveButton(title: "捨棄") {
            deleteHandler()
        }
        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo])
        // Present dialog
        DispatchQueue.main.async {
            vc.present(popup, animated: animated, completion: nil)
        }
    }
}
