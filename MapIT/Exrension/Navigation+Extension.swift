//
//  Navigation+Extension.swift
//  MapIT
//
//  Created by Mira on 2019/4/3.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

extension UINavigationBar {
    func setGradientBackground(colors: [UIColor], startPoint: CAGradientLayer.Point = .bottomLeft , endPoint: CAGradientLayer.Point = .topRight) {
        var updatedFrame = bounds
        updatedFrame.size.height += self.frame.origin.y
        let gradientLayer = CAGradientLayer(frame: updatedFrame, colors: colors, startPoint: startPoint, endPoint: endPoint)
        setBackgroundImage(gradientLayer.createGradientImage(), for: UIBarMetrics.default)
    }
}
