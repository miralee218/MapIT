//
//  UIImage+Extension.swift
//  MapIT
//
//  Created by Mira on 2019/4/3.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

enum ImageAsset: String {

    // Profile tab - Tab
    // swiftlint:disable identifier_name
    case Icons_Home_Unselected
    case Icons_Home_Selected
    case Icons_Notification_Unselected
    case Icons_Notification_Selected
    case Icons_Mapping_Selected
    case Icons_StartRecord
    case Icons_Mapping_Unselected
    case Icons_Mapit_Selected
    case Icons_Mapit_Unselected
    case Icons_Book_Unselected
    case Icons_Book_Selected
    case Icons_Album_Selected
    case Icons_Album_Unselected
    case Icons_User_Unselected
    case Icons_User_Selected

    case Icons_Checkin
    case Icons_Puase
    case Icons_Play
    case Icons_Stop
    case Icons_List

    case Icons_Pause_50
    case Icons_Go
    case Icons_Walking

    case Icons_Calendar_Selected
    case Icons_Calendar_Unselected
    case Icons_Search_Selected
    case Icons_Search_Unselected

    case Icons_RoutePoint
    case Icons_Archive
    case Icons_Photos
    case Icons_Setting
    case Image_SignUp_Selected
    case Image_SignUp_Unselected
    case Image_Login_Selected
    case Image_Login_Unselected
    case Icons_radio_Seleted
    case Icons_radio_Unseleted
    case Icons_cursor

    case Icons_horizontalCell
    case Icons_verticalCell
}
// swiftlint:enable identifier_name

extension UIImage {

    static func asset(_ asset: ImageAsset) -> UIImage? {

        return UIImage(named: asset.rawValue)
    }
}
extension UIImage {
    // convenience function in UIImage extension to resize a given image
    func convert(toSize size: CGSize, scale: CGFloat) -> UIImage {
        let imgRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        self.draw(in: imgRect)
        let copied = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return copied!
    }
}
