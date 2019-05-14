//
//  LaunchScreen.swift
//  MapIT
//
//  Created by Mira on 2019/5/8.
//  Copyright © 2019 AppWork. All rights reserved.
//

import Foundation
import UIKit

class LaunchScreen {
    static func launchAnimation() {
        let vc = (UIStoryboard(name: "LaunchScreen",
                               bundle: nil).instantiateViewController(withIdentifier: "LaunchScreen")
        )
        let launchView = vc.view
        let delegate = UIApplication.shared.delegate
        delegate?.window??.addSubview(launchView!)
        UIView.animate(withDuration: 1, delay: 0.5, options: .beginFromCurrentState,
                       animations: {
                        launchView?.alpha = 0.0
                        let transform = CATransform3DScale(CATransform3DIdentity, 1.5, 1.5, 1.5)
                        launchView?.layer.transform = transform
        }) { finished in
            launchView?.removeFromSuperview()
        }
    }
}
