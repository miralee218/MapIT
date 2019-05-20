//
//  UIColor+Extension.swift
//  MapIT
//
//  Created by Mira on 2019/4/3.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

private enum MIColor: String {
    // swiftlint:disable identifier_name
    case StartPink

    case EndYellow

    case B1

    case B2

    case B3

    case B4

    case B5

    case B6

    case MiraBlue

    case SuccessSave

    case SuccessDelete

}

extension UIColor {

    static let StartPink = MIColor(.StartPink)

    static let EndYellow = MIColor(.EndYellow)

    static let mainColor = MIColor2(.StartPink, .EndYellow)

    static let B1 = MIColor(.B1)

    static let B2 = MIColor(.B2)

    static let B4 = MIColor(.B4)

    static let B5 = MIColor(.B6)

    static let MiraBlue = MIColor(.MiraBlue)

    static let SuccessSave = MIColor(.SuccessSave)

    static let SuccessDelete = MIColor(.SuccessDelete)

    private static func MIColor(_ color: MIColor) -> UIColor? {

        return UIColor(named: color.rawValue)
    }

    private static func MIColor2(_ startColor: MIColor, _ endColor: MIColor) -> [UIColor] {

        guard let startColor = MIColor(startColor),
              let endColor = MIColor(endColor)
        else {
            return []
        }
        return [startColor, endColor]
    }

    static func hexStringToUIColor(hex: String) -> UIColor {

        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count) != 6 {
            return UIColor.gray
        }

        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
// swiftlint:enable identifier_name
