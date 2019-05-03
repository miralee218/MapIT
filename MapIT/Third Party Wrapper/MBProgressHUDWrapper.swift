//
//  MBProgressHUDWrapper.swift
//  MapIT
//
//  Created by Mira on 2019/4/6.
//  Copyright © 2019 AppWork. All rights reserved.
//

import MBProgressHUD

class MRUIProgressHUD: MBProgressHUD {
    override var areDefaultMotionEffectsEnabled: Bool {
        get {
            return false
        }
        set {
        }
    }
}

class MRProgressHUD {

    static func startRecord(view: UIView) {
        let popView = MRUIProgressHUD.showAdded(to: view, animated: true)
        popView.mode = MBProgressHUDMode.customView
        popView.customView = UIImageView(image: UIImage(named: ImageAsset.Icons_Walking.rawValue))
        popView.label.text = "開始紀錄"
        popView.label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        popView.bezelView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        popView.bezelView.alpha = 0.5
        popView.hide(animated: true, afterDelay: 1.5)
    }
    static func coutinueRecord(view: UIView) {
        let popView = MRUIProgressHUD.showAdded(to: view, animated: true)
        popView.mode = MBProgressHUDMode.customView
        popView.customView = UIImageView(image: UIImage(named: ImageAsset.Icons_Walking.rawValue))
        popView.label.text = "繼續紀錄"
        popView.label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        popView.bezelView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        popView.bezelView.alpha = 0.5
        popView.hide(animated: true, afterDelay: 1.5)
    }

    static func puase(view: UIView) {
        let popView = MRUIProgressHUD.showAdded(to: view, animated: true)
        popView.mode = MBProgressHUDMode.customView
        popView.customView = UIImageView(image: UIImage(named: ImageAsset.Icons_Pause_50.rawValue))
        popView.label.text = "暫停紀錄"
        popView.label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        popView.bezelView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
}
