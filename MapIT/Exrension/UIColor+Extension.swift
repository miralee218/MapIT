//
//  UIColor+Extension.swift
//  MapIT
//
//  Created by Mira on 2019/4/3.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

private enum MIColor: String {
    
    case StartPink
    
    case EndYellow
    

}

extension UIColor {
    
    static let StartPink = MIColor(.StartPink)
    
    static let EndYellow = MIColor(.EndYellow)
    
    static let mainColor = MIColor2(.StartPink, .EndYellow)
    
    private static func MIColor(_ color: MIColor) -> UIColor? {
        
        return UIColor(named: color.rawValue)
    }
    
    private static func MIColor2(_ startColor: MIColor, _ endColor: MIColor) -> [UIColor?] {
        
        return [MIColor(startColor), MIColor(endColor)]
    }
    
    
    static func hexStringToUIColor(hex:String) -> UIColor {
        
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

